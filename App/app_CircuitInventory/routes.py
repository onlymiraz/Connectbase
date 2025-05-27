from . import circuit_inventory_bp
from flask import render_template, send_file, abort, request, after_this_request, current_app, flash, redirect, url_for
import pyodbc
import pandas as pd
import os
import logging
from datetime import datetime
from pathlib import Path
from logging.handlers import RotatingFileHandler
import uuid
from io import BytesIO

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_sql_server_connection():
    """
    Establish a connection to SQL Server with timeout and retry logic
    """
    connection_string = (
        'DRIVER={SQL Server};'
        'SERVER=WADINFWWAPV02;'
        'DATABASE=WAD_PRD_Integration;'
        'UID=tsql_wad;'
        'PWD=1QwKdb79!;'
        'Connection Timeout=30;' 
        'Query Timeout=30;'
    )
    
    try:
        conn = pyodbc.connect(connection_string)
        conn.timeout = 30
        return conn
    except pyodbc.Error as e:
        logger.error(f"Failed to connect to database: {str(e)}")
        raise

def fetch_views_info(schema_name):
    views_info = []
    conn = get_sql_server_connection()
    cursor = conn.cursor()
    
    query = """
    SELECT 
        v.TABLE_NAME,
        (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
         WHERE TABLE_NAME = v.TABLE_NAME 
         AND TABLE_SCHEMA = ?) as column_count,
        (SELECT TOP 1 p.rows FROM sys.indexes AS i
         INNER JOIN sys.partitions AS p ON p.object_id = i.object_id AND p.index_id = i.index_id
         INNER JOIN sys.tables AS t ON t.object_id = i.object_id
         INNER JOIN sys.schemas AS s ON s.schema_id = t.schema_id
         WHERE t.name = v.TABLE_NAME AND s.name = ? AND i.index_id < 2) as row_count
    FROM INFORMATION_SCHEMA.VIEWS v
    WHERE v.TABLE_SCHEMA = ?
    """
    
    cursor.execute(query, (schema_name, schema_name, schema_name))
    views = cursor.fetchall()
    
    for view in views:
        view_name, col_count, row_count = view
        views_info.append({
            'name': view_name,
            'columns': col_count,
            'rows': "{:,}".format(row_count) if row_count is not None else "N/A"
        })
    
    conn.close()
    return views_info

@circuit_inventory_bp.route('/', methods=['GET', 'POST'])
def circuit_inventory():
    schema_name = 'LZ_Py_CircuitInventory'
    views_info = fetch_views_info(schema_name)
    
    selected_view = request.form.get('selected_view') or request.args.get('selected_view')
    page = request.args.get('page', 1, type=int)
    per_page = 100
    
    if selected_view:
        # Process filters
        filters = {}
        for key, value in request.form.items():
            if key.startswith('filter_') and value:
                filters[key] = value
        
        view_data = fetch_view_data(schema_name, selected_view, page, per_page, filters)
        
        return render_template(
            'app_CircuitInventory/circuit_inventory.html',
            views_info=views_info,
            selected_view=selected_view,
            view_data=view_data
        )
    
    return render_template(
        'app_CircuitInventory/circuit_inventory.html',
        views_info=views_info
    )
      
@circuit_inventory_bp.route('/health')
def health_check():
    try:
        conn = get_sql_server_connection()
        conn.close()
        return jsonify({"status": "healthy"}), 200
    except:
        return jsonify({"status": "unhealthy"}), 500

def fetch_view_data(schema_name, view_name, page=1, per_page=100, filters=None):
    conn = get_sql_server_connection()
    
    base_query = f"SELECT * FROM {schema_name}.{view_name}"
    where_clauses = []
    
    if filters:
        for key, value in filters.items():
            # Remove 'filter_' prefix from column names
            column_name = key.replace('filter_', '')
            if value:
                where_clauses.append(f"{column_name} LIKE '%{value}%'")
    
    if where_clauses:
        base_query += " WHERE " + " AND ".join(where_clauses)
    
    paginated_query = f"""
    WITH NumberedRows AS (
        SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM ({base_query}) AS BaseQuery
    )
    SELECT * FROM NumberedRows 
    WHERE RowNum > {(page - 1) * per_page} 
    AND RowNum <= {page * per_page}
    """
    
    df = pd.read_sql(paginated_query, conn)
    
    # Get total count
    count_query = f"SELECT COUNT(*) FROM ({base_query}) AS CountQuery"
    total_count = pd.read_sql(count_query, conn).iloc[0, 0]
    
    conn.close()
    
    # Remove RowNum column from results
    if 'RowNum' in df.columns:
        df = df.drop('RowNum', axis=1)
    
    return {
        'df': df,
        'total_count': total_count,
        'page': page,
        'per_page': per_page
    }

@circuit_inventory_bp.route('/filter/<view_name>', methods=['POST'])
def filter_view(view_name):
    schema_name = 'LZ_Py_CircuitInventory'
    filters = []
    for key, value in request.form.items():
        if value and key != 'csrf_token':
            filters.append(f"{key} LIKE '%{value}%'")
    
    view_data = fetch_view_data(schema_name, view_name, filters)
    return render_template(
        'app_CircuitInventory/view_data.html',
        view_data=view_data,
        view_name=view_name
    )

# Set up logging
def setup_logger():
    # Create logger
    logger = logging.getLogger('circuit_inventory')
    logger.setLevel(logging.DEBUG)
    
    # Ensure debug directory exists
    Path('debug').mkdir(exist_ok=True)
    
    # Create rotating file handler
    file_handler = RotatingFileHandler(
        'debug/circuit_inventory_debug.log',
        maxBytes=5*1024*1024,
        backupCount=5,
        encoding='utf-8'
    )
    file_handler.setLevel(logging.DEBUG)
    
    # Create console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    
    # Create formatters
    file_formatter = logging.Formatter(
        '%(asctime)s | %(levelname)s | %(funcName)s:%(lineno)d | %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console_formatter = logging.Formatter(
        '%(asctime)s | %(levelname)s | %(message)s'
    )
    
    # Add formatters to handlers
    file_handler.setFormatter(file_formatter)
    console_handler.setFormatter(console_formatter)
    
    # Add handlers to logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    
    # Prevent log propagation to root logger
    logger.propagate = False
    
    return logger

@circuit_inventory_bp.route('/download/<view_name>', endpoint='download_view_excel')
def download_view(view_name):
    schema_name = 'LZ_Py_CircuitInventory'
    logger.info(f"Download request initiated for view: {view_name}")
    
    try:
        # Get filters from the form submission
        filters = []
        for key, value in request.args.items():
            if key.startswith('filter_') and value:
                column_name = key.replace('filter_', '')
                clean_value = value.replace("'", "''")
                filters.append(f"{column_name} = '{clean_value}'")
                logger.info(f"Filter applied: {column_name} = '{clean_value}'")

        # Build query
        query = f"SELECT * FROM {schema_name}.{view_name}"
        if filters:
            where_clause = " AND ".join(filters)
            query += f" WHERE {where_clause}"
        
        logger.info(f"Executing query: {query}")
        
        # Execute query
        conn = get_sql_server_connection()
        df = pd.read_sql(query, conn)
        conn.close()
        
        logger.info(f"Query returned {len(df)} rows")
        
        # Create Excel in memory
        output = BytesIO()
        try:
            with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
                df.to_excel(writer, sheet_name='Data', index=False)
        except ImportError:
            logger.info("Falling back to openpyxl engine")
            with pd.ExcelWriter(output, engine='openpyxl') as writer:
                df.to_excel(writer, sheet_name='Data', index=False)
        
        output.seek(0)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"{view_name}_filtered_{timestamp}.xlsx"
        
        logger.info(f"Excel file created: {filename}")
        
        return send_file(
            output,
            mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            as_attachment=True,
            download_name=filename
        )
        
    except Exception as e:
        logger.error(f"Error in download_view: {str(e)}", exc_info=True)
        flash(f"Failed to download view {view_name}: {str(e)}")
        return redirect(url_for('circuit_inventory.circuit_inventory'))
