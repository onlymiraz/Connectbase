# tools/gather_project_code.py

import os
import datetime

ROOT_PATH = "./"
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
    "devops",
    "archive",
    "tests",
    "venv_CB_AI"
}

VALID_EXTENSIONS = {
    ".py", ".json", ".yml", ".yaml", ".sql", ".md", ".html", ".js", ".css"
}

def gather_structure_and_code(root_path=ROOT_PATH, exclude_dirs=EXCLUDE_DIRS, valid_extensions=VALID_EXTENSIONS):
    timestamp = datetime.datetime.now().strftime(DATETIME_FORMAT)
    output_file = os.path.join("tools", f"all_project_code_{timestamp}.txt")
    if os.path.exists(output_file):
        os.remove(output_file)

    code_blocks = []
    structure_lines = []

    for current_dir, dirs, files in os.walk(root_path):
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        rel_dir = os.path.relpath(current_dir, root_path)
        indent_level = rel_dir.count(os.sep)
        indent = "│   " * indent_level
        structure_lines.append(f"{indent}{os.path.basename(current_dir)}/")

        for f in files:
            _, ext = os.path.splitext(f)
            structure_lines.append(f"{indent}    {f}")
            if ext.lower() in valid_extensions:
                file_path = os.path.join(current_dir, f)
                try:
                    with open(file_path, "r", encoding="utf-8") as src:
                        content = src.read()
                except Exception as e:
                    content = f"[ERROR reading file: {e}]"
                rel_path = os.path.relpath(file_path, root_path)
                code_blocks.append((rel_path, content))

    with open(output_file, "w", encoding="utf-8") as out:
        out.write("========== PROJECT STRUCTURE ==========\n")
        for line in structure_lines:
            out.write(line + "\n")

        out.write("\n\n========== FILE CONTENTS ==========\n")
        for path, content in code_blocks:
            out.write(f"\n\n########## FILE: {path} ##########\n")
            out.write(content)

    print(f"[DONE] Created: {output_file}")

if __name__ == "__main__":
    gather_structure_and_code()

# Optional legacy DB configs (not needed for Connectbase):
# SCHEMA_LIST = [
#     {"server": "...", "database": "...", "schema": "...", "nickname": "STG"},
#     {"server": "...", "database": "...", "schema": "...", "nickname": "PRD"},
#     {"server": "...", "database": "...", "schema": "...", "nickname": "OLD"}
# ]
