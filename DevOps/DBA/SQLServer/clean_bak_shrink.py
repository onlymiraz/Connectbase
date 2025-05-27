import pyodbc
import os
import socket
import getpass
from datetime import datetime
import glob
import time
import shutil

def get_databases(connection):
    query = """
    SELECT name 
    FROM master.sys.databases 
    WHERE name NOT IN ('tempdb')
    AND state = 0 -- database is online
    AND is_in_standby = 0 -- database is not read only for log shipping
    """
    cursor = connection.cursor()
    cursor.execute(query)
    databases = [row[0] for row in cursor.fetchall()]
    cursor.close()
    return databases

def get_free_space(path):
    """Return the free space of the given path in bytes."""
    total, used, free = shutil.disk_usage(path)
    return free

def delete_old_backup_files(root_path, target_free_space):
    start_time = time.time()
    files = glob.glob(os.path.join(root_path, '**', '*.bak'), recursive=True)
    files = sorted(files, key=lambda x: os.path.getmtime(x))

    if not files:
        print("No .bak files found for deletion.")
        return

    total_size = sum(os.path.getsize(file) for file in files)
    current_free_space = get_free_space(root_path)
    
    if current_free_space >= target_free_space:
        print(f"Current free space ({current_free_space / (1024**4):.2f} TB) is already greater than or equal to the target free space ({target_free_space / (1024**4):.2f} TB). No deletion needed.")
        return

    freed_space = 0
    files_deleted = 0

    for file in files:
        current_free_space = get_free_space(root_path)
        if current_free_space >= target_free_space:
            break
        file_size = os.path.getsize(file)
        try:
            os.remove(file)
            freed_space += file_size
            files_deleted += 1
            print(f"Deleted {file}, size: {file_size / (1024**3):.2f} GB")
        except FileNotFoundError:
            print(f"File {file} not found for deletion.")

    duration = time.time() - start_time
    print(f"Freed {(freed_space / (1024**3)):.2f} GB by deleting {files_deleted} old .bak files to maintain {target_free_space / (1024**4):.2f} TB free space.")
    print(f"Total size of backup files before deletion: {total_size / (1024**3):.2f} GB")
    print(f"Time taken for deletion: {duration:.2f} seconds")

def shrink_database(connection, database_name):
    start_time = time.time()
    shrink_query = f"""
    DBCC SHRINKDATABASE(N'{database_name}')
    """
    cursor = connection.cursor()
    connection.autocommit = True  # Ensure autocommit is on
    try:
        cursor.execute(shrink_query)
        cursor.close()
        connection.autocommit = False  # Reset autocommit to False after each shrink operation
        duration = time.time() - start_time
        print(f"Shrink operation for database {database_name} completed. Time taken: {duration:.2f} seconds")
    except pyodbc.Error as e:
        print(f"Error during shrinking of database {database_name}: {e}")
        for err in e.args:
            print(f"SQL Error: {err}")
        connection.autocommit = False  # Ensure autocommit is reset in case of error

def main():
    overall_start_time = time.time()

    # Dynamically get the current node (hostname)
    node = socket.gethostname()

    backup_root_path = r'\\nspinfwcipp01.corp.pvt\WAD\Backup\DB'
    delete_root_path = r'\\nspinfwcipp01.corp.pvt\WAD'
    backup_path = os.path.join(backup_root_path, node)
    target_free_space = 1 * 1024**4  # 1 TB in bytes

    # Log system details
    print(f"Running on node: {node}")
    print(f"Current user: {getpass.getuser()}")
    print(f"Backup path: {backup_path}")
    print(f"Target free space: {target_free_space / (1024**4):.2f} TB")

    # Ensure backup directory exists
    if not os.path.exists(backup_path):
        os.makedirs(backup_path)

    # Connect to SQL Server
    connection_string = (
        'DRIVER={ODBC Driver 17 for SQL Server};'
        'SERVER=' + node + ';'
        'Trusted_Connection=yes;'
    )
    connection = pyodbc.connect(connection_string)

    try:
        # Step 1: Delete old backup files
        delete_old_backup_files(delete_root_path, target_free_space)

        # Step 2: Shrink databases
        databases = get_databases(connection)
        print(f"Found {len(databases)} databases.")
        for db in databases:
            shrink_database(connection, db)
    finally:
        connection.close()

    overall_duration = time.time() - overall_start_time
    print(f"Total time taken for the entire operation: {overall_duration / 60:.2f} minutes")

if __name__ == "__main__":
    main()
