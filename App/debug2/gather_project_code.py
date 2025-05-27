# /debug2/gather_project_code.py
#!/usr/bin/env python3
"""
gather_project_code.py
======================
Scans this entire project, gathering:

1) Directory structure (minus excluded dirs).
2) Python code => detect imports, build a local "import graph".
3) Flask routes => detect endpoints from @app.route(...) or app.add_url_rule(...).
4) HTML templates => detect url_for('some_endpoint') usage.
5) Then enumerates *all* objects (tables, views, procs, triggers, etc.)
   from the STG and PRD "ADDRESS_BILLING" schema, plus the deprecated
   "addressbilling" schema in Playground:
   - For tables & views => partial DDL, row counts, indexes
   - For procs, triggers, etc. => attempt OBJECT_DEFINITION if available
6) **New**: For UI_LZ / UI_LZ_Archive / Fuzzymatch_Output / Fuzzymatch_Output_Archive,
   we also show distinct batch_id counts and distinct address counts.
7) Writes all code & metadata into a timestamped output file.

Usage:
    python gather_project_code.py
"""

import os
import re
import ast
import datetime
import pyodbc

##############################################################################
# CONFIGURATIONS
##############################################################################

ROOT_PATH = "../"  # Adjust if needed; typically "../" from debug2 => project root
DATETIME_FORMAT = "%Y%m%d_%H%M%S"

EXCLUDE_DIRS = {
    "__pycache__",
    "venv",
    "env",
    ".git",
    ".idea",
    "node_modules",
    "uploads",
    "temp_downloads",
    "logs",
    "shell_IIS_archived",
    "archive",
    "devops",
    "tests",  # add or remove as needed
}

VALID_EXTENSIONS = {
    ".py",
    ".ps1",
    ".html",
    ".htm",
    ".css",
    ".js",
    ".json",
    ".yml",
    ".yaml",
    ".sh",
    ".sql",
    # ".txt",
}

# If some HTML files are huge (like large map HTML), skip to keep the output short:
LARGE_HTML_FILES = {
    "all_locations_map.html",
    "all_locations_map_v2.html",
}

# The three schemas we care about for "full enumeration":
# 1) STG => WADINFWWDDV01, DB=WAD_STG_Integration, SCHEMA=ADDRESS_BILLING
# 2) PRD => WADINFWWAPV02, DB=WAD_PRD_Integration, SCHEMA=ADDRESS_BILLING
# 3) Deprecated => WADINFWWDDV01, DB=Playground, SCHEMA=addressbilling
SCHEMA_LIST = [
    {
        "server": "WADINFWWDDV01",
        "database": "WAD_STG_Integration",
        "schema":   "ADDRESS_BILLING",
        "nickname": "STG"
    },
    {
        "server": "WADINFWWAPV02",
        "database": "WAD_PRD_Integration",
        "schema":   "ADDRESS_BILLING",
        "nickname": "PRD"
    },
    {
        "server": "WADINFWWDDV01",
        "database": "Playground",
        "schema":   "addressbilling",
        "nickname": "DEPRECATED"
    }
]

##############################################################################
# 1) Parse imports in Python
##############################################################################

def parse_python_imports(file_content):
    """
    Return a set of import references found in .py code,
    e.g. 'os', 'pandas', 'flask', 'app_AddressBilling.orchestration', etc.
    """
    try:
        tree = ast.parse(file_content)
    except SyntaxError:
        return set()
    imports_found = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imports_found.add(alias.name)
        elif isinstance(node, ast.ImportFrom):
            if node.module:
                imports_found.add(node.module)
    return imports_found

##############################################################################
# 2) Parse Flask routes from Python code
##############################################################################

def parse_flask_routes(file_content):
    """
    Attempt to find:
      @app.route('/something', endpoint='myendpoint')
      or
      app.add_url_rule('/something', 'myendpoint', ...)

    Returns a dict => { 'myendpoint': True, ... }
    """
    routes = {}
    # pattern A: @app.route('/x', endpoint='some_endpoint')
    pattern_decorator = re.compile(
        r"@(?:[\w_\.]+)\.route\s*\(\s*[^)]*endpoint\s*=\s*['\"]([^'\"]+)['\"]"
    )
    # pattern B: app.add_url_rule('/x', 'some_endpoint', ...)
    pattern_addrule = re.compile(
        r"[\w_\.]+\.add_url_rule\s*\([^,]+,\s*['\"]([^'\"]+)['\"]"
    )
    for line in file_content.splitlines():
        line = line.strip()
        m1 = pattern_decorator.search(line)
        if m1:
            endpoint = m1.group(1)
            routes[endpoint] = True
        m2 = pattern_addrule.search(line)
        if m2:
            endpoint = m2.group(1)
            routes[endpoint] = True
    return routes

##############################################################################
# 3) Parse HTML templates => find url_for('some_endpoint')
##############################################################################

def parse_html_url_for(file_content):
    """
    Return a set of endpoints found in url_for('endpoint_name') calls
    inside .html code.
    """
    pattern = re.compile(r"url_for\(\s*['\"]([^'\"]+)['\"]")
    return set(pattern.findall(file_content))

##############################################################################
# 4) DB HELPER: Connect and retrieve objects
##############################################################################

def get_pyodbc_connection(server, database):
    """
    Trusted conn => server=..., db=...
    """
    conn_str = (
        f"DRIVER={{SQL Server}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
    )
    return pyodbc.connect(conn_str)

def get_all_schema_objects(server, database, schema):
    """
    Return a list of (object_name, object_type_desc, object_id)
    from sys.objects for a given schema.
    We skip 'INTERNAL_TABLE' or 'SERVICE_QUEUE' or ephemeral stuff, but
    do retrieve TABLE, VIEW, SQL_STORED_PROCEDURE, SQL_TRIGGER, etc.
    """
    conn = get_pyodbc_connection(server, database)
    cur = conn.cursor()
    sql = """
    SELECT
      o.name AS object_name,
      o.type_desc,
      o.object_id
    FROM sys.objects o
    JOIN sys.schemas s
      ON o.schema_id = s.schema_id
    WHERE s.name = ?
      AND o.is_ms_shipped=0
      AND o.type_desc NOT IN ('INTERNAL_TABLE','SERVICE_QUEUE','SYSTEM_TABLE')
    ORDER BY o.type_desc, o.name
    """
    cur.execute(sql, (schema,))
    rows = cur.fetchall()
    results = []
    for row in rows:
        results.append((row.object_name, row.type_desc, row.object_id))
    conn.close()
    return results

def get_table_column_definitions(server, database, schema, table_name):
    """
    Return a list of (col_name, data_type, max_length, is_nullable)
    from INFORMATION_SCHEMA.COLUMNS for a table or view.
    """
    conn = get_pyodbc_connection(server, database)
    cur = conn.cursor()
    sql = """
    SELECT
      COLUMN_NAME,
      DATA_TYPE,
      CHARACTER_MAXIMUM_LENGTH,
      IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA=? AND TABLE_NAME=?
    ORDER BY ORDINAL_POSITION
    """
    cur.execute(sql, (schema, table_name))
    rows = cur.fetchall()
    colinfo = []
    for r in rows:
        colinfo.append((r.COLUMN_NAME, r.DATA_TYPE, r.CHARACTER_MAXIMUM_LENGTH, r.IS_NULLABLE))
    conn.close()
    return colinfo

def get_table_row_count(server, database, schema, table_name):
    """
    Return integer rowcount for a table or view, or a string "Error => ..." on failure.
    """
    conn = get_pyodbc_connection(server, database)
    cur = conn.cursor()
    q = f"SELECT COUNT(*) FROM [{schema}].[{table_name}]"
    try:
        cur.execute(q)
        rc = cur.fetchone()[0]
    except Exception as ex:
        rc = f"Error => {ex}"
    conn.close()
    return rc

##############################################################################
# New function: get_extra_stats
# If the table is UI_LZ, UI_LZ_Archive, Fuzzymatch_Output, or Fuzzymatch_Output_Archive,
# we'll fetch distinct batch_id count, and distinct addresses, etc.
##############################################################################

def get_extra_stats(server, database, schema, table_name):
    """
    Return a dict with 'distinct_batch_count' and 'distinct_address_count'
    if this table is recognized. Otherwise return {}.
    We assume:
     - UI_LZ + UI_LZ_Archive => distinct 'batch_id', distinct 'Address1'
     - Fuzzymatch_Output + Fuzzymatch_Output_Archive => distinct 'batch_id', distinct 'Input_Address'
    """
    lower_name = table_name.lower()
    recognized_tables = {
        'ui_lz':        ('batch_id','Address1'),
        'ui_lz_archive':('batch_id','Address1'),
        'fuzzymatch_output':('batch_id','Input_Address'),
        'fuzzymatch_output_archive':('batch_id','Input_Address')
    }
    if lower_name not in recognized_tables:
        return {}

    (batchcol, addrcol) = recognized_tables[lower_name]
    # Build a quick query
    # We'll gracefully handle if the columns might not exist, ignoring errors.
    query = f"""
    SELECT 
      COUNT(DISTINCT [{batchcol}]) AS distinct_batch_count,
      COUNT(DISTINCT [{addrcol}]) AS distinct_addr_count
    FROM [{schema}].[{table_name}]
    """
    conn = get_pyodbc_connection(server, database)
    cur = conn.cursor()
    try:
        cur.execute(query)
        row = cur.fetchone()
        if row:
            return {
                'distinct_batch_count': row.distinct_batch_count,
                'distinct_addr_count': row.distinct_addr_count
            }
        else:
            return {}
    except Exception as ex:
        # e.g. if Input_Address doesn't exist or other error => just skip
        return {"error": f"{ex}"}
    finally:
        cur.close()
        conn.close()

def get_table_indexes(server, database, schema, table_name):
    """
    Return a list of (index_name, [col1, col2, ...]) from sys.indexes+sys.index_columns
    for the given table. If none, returns [].
    """
    from collections import defaultdict
    conn = get_pyodbc_connection(server, database)
    cur = conn.cursor()
    sql = """
    SELECT i.name AS index_name,
           c.name AS column_name,
           ic.index_column_id
    FROM sys.indexes i
    JOIN sys.index_columns ic
        ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    JOIN sys.columns c
        ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    JOIN sys.tables t
        ON i.object_id = t.object_id
    JOIN sys.schemas s
        ON t.schema_id = s.schema_id
    WHERE s.name = ?
      AND t.name = ?
      AND i.is_hypothetical=0
      AND i.name IS NOT NULL
    ORDER BY i.name, ic.index_column_id;
    """
    cur.execute(sql, (schema, table_name))
    rows = cur.fetchall()
    idx_map = defaultdict(list)
    for (idx_name, col_name, idx_col_id) in rows:
        idx_map[idx_name].append((idx_col_id, col_name))
    cur.close()
    conn.close()

    results = []
    for idx_name, col_pairs in idx_map.items():
        sorted_by_id = sorted(col_pairs, key=lambda x: x[0])
        col_list = [cp[1] for cp in sorted_by_id]
        results.append((idx_name, col_list))
    return results

def get_object_definition(server, database, object_id):
    """
    For procedures, triggers, views, etc., return the text from OBJECT_DEFINITION(object_id).
    If it's a table, object_definition() is typically null. So we might get None.
    """
    conn = get_pyodbc_connection(server, database)
    cur = conn.cursor()
    sql = "SELECT OBJECT_DEFINITION(?) AS definition"
    cur.execute(sql, (object_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()
    if row and row.definition:
        return row.definition
    return None

##############################################################################
# 5) MAIN: gather_structure_and_code => write to timestamped .txt
##############################################################################

def gather_structure_and_code(
    root_path=ROOT_PATH,
    exclude_dirs=EXCLUDE_DIRS,
    valid_extensions=VALID_EXTENSIONS,
    large_html_files=LARGE_HTML_FILES,
    schema_list=SCHEMA_LIST
):
    timestamp = datetime.datetime.now().strftime(DATETIME_FORMAT)
    output_file = f"all_project_code_{timestamp}.txt"
    if os.path.exists(output_file):
        os.remove(output_file)

    ########################################################################
    # A) GATHER DIRECTORY STRUCTURE
    ########################################################################
    structure_lines = []
    for current_dir, dirs, files in os.walk(root_path):
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        rel_dir = os.path.relpath(current_dir, root_path)
        if rel_dir == ".":
            rel_dir = os.path.basename(os.path.abspath(root_path)) or "."

        indent_level = rel_dir.count(os.sep)
        indent = "│   " * indent_level
        structure_lines.append(f"{indent}{os.path.basename(current_dir)}/")

        for f in files:
            structure_lines.append(f"{indent}    {f}")

    ########################################################################
    # B) COLLECT CODE FILES & PARSE
    ########################################################################
    code_blocks = []
    py_import_graph = {}
    route_definitions = {}
    template_url_for_map = {}

    # We'll attempt a file->module mapping for .py but it's optional:
    path_to_module = {}

    # B1: gather .py => map to potential module name
    for current_dir, dirs, files in os.walk(root_path):
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        for f in files:
            _, ext = os.path.splitext(f)
            if ext.lower() == ".py":
                full_path = os.path.join(current_dir, f)
                rel_path = os.path.relpath(full_path, root_path)
                mod_name = rel_path.replace(".py", "").replace("\\", ".").replace("/", ".")
                path_to_module[rel_path] = mod_name

    # B2: read each file, parse
    for current_dir, dirs, files in os.walk(root_path):
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        for f in files:
            _, ext = os.path.splitext(f)
            if ext.lower() in valid_extensions:
                # skip large HTML if in our "skip" set
                if f in large_html_files:
                    continue
                full_path = os.path.join(current_dir, f)
                rel_path = os.path.relpath(full_path, root_path)
                try:
                    with open(full_path, "r", encoding="utf-8") as src:
                        content = src.read()
                except Exception as e:
                    content = f"[ERROR reading file: {e}]"
                code_blocks.append((rel_path, content))

                # If it's .py => parse imports + routes
                if ext.lower() == ".py":
                    imports_found = parse_python_imports(content)
                    py_import_graph.setdefault(rel_path, set()).update(imports_found)

                    routes_found = parse_flask_routes(content)
                    for endpoint in routes_found:
                        route_definitions[endpoint] = rel_path

                # If .html => parse url_for
                elif ext.lower() in (".html", ".htm"):
                    endpoints = parse_html_url_for(content)
                    if endpoints:
                        template_url_for_map.setdefault(rel_path, set()).update(endpoints)

    # Build final dependency info: file -> set(files it depends on)
    # We'll do only local .py => .py. For each import "mod", see if that mod
    # is in path_to_module => we can link them.
    final_deps = {}
    for py_file, imports in py_import_graph.items():
        final_deps.setdefault(py_file, set())
        for mod in imports:
            # see if mod is local
            for candidate_path, candidate_mod in path_to_module.items():
                if candidate_mod == mod:
                    final_deps[py_file].add(candidate_path)

    # Also link HTML -> route definitions
    for htmlf, endpoints in template_url_for_map.items():
        final_deps.setdefault(htmlf, set())
        for ep in endpoints:
            if ep in route_definitions:
                final_deps[htmlf].add(route_definitions[ep])

    ########################################################################
    # WRITE OUTPUT
    ########################################################################
    with open(output_file, "w", encoding="utf-8") as out:

        # 1) PROJECT STRUCTURE
        out.write("========== PROJECT STRUCTURE ==========\n")
        for line in structure_lines:
            out.write(line + "\n")

        # 2) DEPENDENCY GRAPH
        out.write("\n\n========== ADVANCED DEPENDENCY GRAPH ==========\n")
        if not final_deps:
            out.write("(No local dependencies found.)\n")
        else:
            for file_path in sorted(final_deps.keys()):
                deps = final_deps[file_path]
                out.write(f"\n{file_path}:\n")
                if not deps:
                    out.write("  -> None\n")
                else:
                    for d in sorted(deps):
                        out.write(f"  -> {d}\n")

        # 3) FLASK ROUTES
        out.write("\n\n========== FLASK ROUTES DETECTED ==========\n")
        if not route_definitions:
            out.write("(No @app.route or add_url_rule found.)\n")
        else:
            for endpoint, pyfile in sorted(route_definitions.items()):
                out.write(f"Endpoint '{endpoint}' is defined in: {pyfile}\n")

        # 4) TEMPLATES => url_for references
        out.write("\n\n========== TEMPLATES -> url_for REFERENCES ==========\n")
        if not template_url_for_map:
            out.write("(No url_for calls found in HTML.)\n")
        else:
            for htmlf, endpoints in sorted(template_url_for_map.items()):
                out.write(f"\n{htmlf} calls endpoints: {sorted(endpoints)}\n")

        # 5) CODE FILES
        out.write("\n\n========== GATHERED CODE FILES ==========\n")
        for rel_path, content in code_blocks:
            out.write(f"\n\n########## FILE: {rel_path} ##########\n")
            out.write(content)

        # 6) NOW ENUMERATE ALL OBJECTS FOR THE SPECIFIED SCHEMAS
        out.write("\n\n========== ALL OBJECTS IN STG/PRD/DEPRECATED SCHEMAS ==========\n")
        for info in schema_list:
            srv   = info["server"]
            db    = info["database"]
            sch   = info["schema"]
            nick  = info["nickname"]

            out.write(f"\n~~~~ [{nick}] => {srv}.{db}.{sch} ~~~~\n\n")

            # get all objects
            all_objs = get_all_schema_objects(srv, db, sch)
            if not all_objs:
                out.write(f"(No objects found in schema {sch} on {db} / {srv}?)\n")
                continue

            for (obj_name, obj_type_desc, obj_id) in all_objs:
                out.write(f"---- OBJECT: [{sch}].[{obj_name}] | Type: {obj_type_desc} ----\n\n")

                # If it's a table or view => partial DDL from columns
                if obj_type_desc in ("USER_TABLE", "VIEW"):
                    colinfo = get_table_column_definitions(srv, db, sch, obj_name)
                    rowcount = get_table_row_count(srv, db, sch, obj_name)
                    index_list = []
                    if obj_type_desc == "USER_TABLE":
                        index_list = get_table_indexes(srv, db, sch, obj_name)

                    # Show rowcount
                    out.write(f"-- RowCount: {rowcount}\n")

                    # **NEW**: If this is UI_LZ, UI_LZ_Archive, Fuzzymatch_Output, or Fuzzymatch_Output_Archive,
                    #   show distinct batch/address counts
                    extra = get_extra_stats(srv, db, sch, obj_name)
                    if extra:
                        if 'error' in extra:
                            out.write(f"-- Extra Stats Error: {extra['error']}\n")
                        else:
                            out.write(f"-- Distinct batch_id: {extra['distinct_batch_count']}\n")
                            out.write(f"-- Distinct addresses: {extra['distinct_addr_count']}\n")

                    # Build a "CREATE TABLE" or "CREATE VIEW"-ish snippet:
                    col_lines = []
                    for (cname, ctype, cmax, cnull) in colinfo:
                        if cmax and ctype.lower() in ("varchar","nvarchar","char","nchar"):
                            col_lines.append(f"  [{cname}] [{ctype}]({cmax}) {'NULL' if cnull=='YES' else 'NOT NULL'}")
                        else:
                            col_lines.append(f"  [{cname}] [{ctype}] {'NULL' if cnull=='YES' else 'NOT NULL'}")

                    if obj_type_desc == "USER_TABLE":
                        out.write(f"CREATE TABLE [{sch}].[{obj_name}](\n")
                        if col_lines:
                            out.write(",\n".join(col_lines) + "\n")
                        out.write(") ON [PRIMARY];\n\n")
                        if index_list:
                            out.write("-- Indexes:\n")
                            for (ix_name, ix_cols) in index_list:
                                col_join = ", ".join(ix_cols)
                                out.write(f"   {ix_name} on ({col_join})\n")
                    else:
                        # It's a VIEW => attempt the full definition
                        out.write(f"-- Columns found: {len(colinfo)}\n")
                        out.write("-- We'll also attempt the full definition:\n")
                        definition = get_object_definition(srv, db, obj_id)
                        if definition:
                            out.write(f"{definition}\n\n")
                        else:
                            out.write("-- No definition or not a T-SQL view.\n\n")

                else:
                    # It's a proc, function, trigger, constraint, etc.
                    definition = get_object_definition(srv, db, obj_id)
                    if definition:
                        out.write("-- Source code / definition:\n")
                        out.write(definition + "\n\n")
                    else:
                        out.write("-- (No definition returned / possibly a constraint or no code to show)\n\n")

                out.write("\n")  # line break after each object

        # 7) RECOMMENDATIONS
        out.write("========== RECOMMENDATIONS / NEXT STEPS ==========\n")
        out.write(
            "1) In the DEPRECATED environment (Playground.addressbilling), consider dropping or\n"
            "   migrating old objects if they are truly no longer needed.\n"
            "2) Review rowcounts & indexes for large STG/PRD tables to confirm whether any\n"
            "   indexes can be removed or consolidated.\n"
            "3) Evaluate constraints, triggers, etc. for relevancy.\n"
            "4) Confirm your code references the new STG/PRD objects, not leftover dev schemas.\n"
        )

    print(f"[DONE] Created '{output_file}' in your current folder.\n"
          "It includes:\n"
          " • Full project structure\n"
          " • A local code dependency graph (imports, route definitions, template references)\n"
          " • All code in relevant files\n"
          " • Comprehensive listing of all objects (tables, views, procs, triggers, etc.)\n"
          "   from STG (WAD_STG_Integration.ADDRESS_BILLING),\n"
          "   PRD (WAD_PRD_Integration.ADDRESS_BILLING), and\n"
          "   DEPRECATED (Playground.addressbilling).\n"
          " • Basic partial DDL for tables/views, rowcounts, indexes, plus\n"
          "   object definitions (if available) for stored procs/triggers.\n"
          " • **Distinct batch/address** counts for UI_LZ, UI_LZ_Archive, Fuzzymatch_Output,\n"
          "   and Fuzzymatch_Output_Archive.\n"
          " • Recommendations for cleanup steps at the end."
    )

##############################################################################
# 6) MAIN
##############################################################################

if __name__ == "__main__":
    gather_structure_and_code()
