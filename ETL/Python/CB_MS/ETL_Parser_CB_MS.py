import os
import pandas as pd
import pyodbc
import re
import socket
import time
import logging
import csv
import shutil
from datetime import timedelta, datetime

# Configure logging
logging.basicConfig(filename='combined_log.txt', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')


# Function to sanitize and truncate file names and column names
def sanitize_name(name):
    sanitized = re.sub(r'\W+', '_', name)
    return sanitized[:128]  # Truncate to a maximum of 128 characters


# Function to abbreviate long column names to ensure uniqueness
def abbreviate_column_name(col_name, existing_columns):
    abbreviations = {
        "ID": "ID",
        "LOGIN": "LOGIN",
        "ROUTE": "ROUTE",
        "REQUESTING": "REQUESTING",
        "COMPANY": "COMPANY",
        "ADDRESS": "ADDRESS",
        "CITY": "CITY",
        "STATE": "STATE",
        "ZIP": "ZIP",
        "COUNTY": "COUNTY",
        "COUNTRY": "COUNTRY",
        "USER": "USER",
        "TARGET": "TARGET"
    }

    parts = col_name.split('_')
    abbreviated = "_".join([abbreviations.get(part, part) for part in parts])
    truncated = abbreviated[:128]

    # Ensure uniqueness by appending a number if necessary
    counter = 1
    original_truncated = truncated
    while truncated in existing_columns:
        truncated = f"{original_truncated}_{counter}"
        truncated = truncated[:128]  # Ensure the truncated name does not exceed the length limit
        counter += 1

    existing_columns.add(truncated)
    return truncated


# Define the output directory
script_directory = os.path.dirname(os.path.abspath(__file__))  # Directory where the script is running
output_directory = os.path.join(script_directory, 'copied_files')  # New folder for copied files

# Ensure the output directory exists
os.makedirs(output_directory, exist_ok=True)

# Get the current node
current_node = socket.gethostname().upper()

# Define the source directory to search for files recursively, including the current node name
source_directory = fr'\\{current_node}\d\lz\IT_Data_Transmission'

# Mapping of nodes to databases
node_db_mapping = {
    'WADINFWWAPV02': 'WAD_PRD_Integration',
    'WADINFWWDDV01': 'WAD_STG_Integration'
    # Add other nodes and their corresponding databases here
}

# Get the corresponding database name
database_name = node_db_mapping.get(current_node, 'Playground')  # Default to 'Playground' if node not found

# SQL Server connection settings
connection_string = (
    f"Driver={{ODBC Driver 17 for SQL Server}};"
    f"Server={current_node};"
    f"Database={database_name};"
    "Trusted_Connection=yes;"
)

# Specify the target schema
schema_name = 'LZ_Py'


def connect_to_sql_server():
    return pyodbc.connect(connection_string)


def ensure_schema_exists():
    conn = connect_to_sql_server()
    cursor = conn.cursor()
    cursor.execute(f"""
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{schema_name}')
    BEGIN
        EXEC('CREATE SCHEMA [{schema_name}]')
    END
    """)
    conn.commit()
    conn.close()


# List to collect summary statistics
ingestion_summary = []


def log_time_step(step_name, start_time, end_time):
    duration = timedelta(seconds=end_time - start_time)
    logging.info(f"{step_name} started at {time.strftime('%H:%M:%S', time.localtime(start_time))}, "
                 f"ended at {time.strftime('%H:%M:%S', time.localtime(end_time))}, "
                 f"duration {str(duration)}")
    print(f"{step_name} started at {time.strftime('%H:%M:%S', time.localtime(start_time))}, "
          f"ended at {time.strftime('%H:%M:%S', time.localtime(end_time))}, "
          f"duration {str(duration)}")


def estimate_time_remaining(elapsed_time, progress, total_steps):
    estimated_total_time = (elapsed_time / progress) * total_steps
    return estimated_total_time - elapsed_time


def detect_delimiter(file_path):
    with open(file_path, 'r', errors='ignore') as file:
        sample = file.read(1024)
        sniffer = csv.Sniffer()
        try:
            dialect = sniffer.sniff(sample)
            return dialect.delimiter
        except csv.Error:
            logging.warning(f"Could not determine delimiter for file {file_path}. Using default delimiter ','")
            return ','


def process_file(file_path):
    try:
        start_time = time.time()
        file_extension = os.path.splitext(file_path)[1].lower()

        logging.info(f"Processing file: {file_path} with extension: {file_extension}")

        if file_extension in ['.xls', '.xlsx']:
            xls = pd.ExcelFile(file_path)
            for sheet_name in xls.sheet_names:
                df = pd.read_excel(xls, sheet_name=sheet_name, dtype=str)
                logging.info(f"Original columns: {df.columns.tolist()}")
                existing_columns = set()
                df.columns = [abbreviate_column_name(sanitize_name(col), existing_columns) for col in df.columns]
                logging.info(f"Sanitized columns: {df.columns.tolist()}")
                table_name = sanitize_name(f"{os.path.splitext(os.path.basename(file_path))[0]}_{sheet_name}")
                insert_data_to_sql_server(df, table_name)
                log_summary(file_path, sheet_name, table_name, file_extension, df)
        else:
            df = None
            sheet_name = None
            if file_extension == '.csv':
                if 'CB_FRONTIER_DEMAND_ENGINE_ACTIVITIES' in os.path.basename(file_path):
                    df = pd.read_csv(file_path, delimiter='|', dtype=str, on_bad_lines='skip')
                else:
                    delimiter = detect_delimiter(file_path)
                    df = pd.read_csv(file_path, delimiter=delimiter, dtype=str, on_bad_lines='skip')
            elif file_extension == '.txt':
                delimiter = detect_delimiter(file_path)
                df = pd.read_csv(file_path, delimiter=delimiter, dtype=str, on_bad_lines='skip')
            else:
                logging.warning(f"Unsupported file extension: {file_extension}")
                print(f"Unsupported file extension: {file_extension}")
                return

            if df is not None:
                logging.info(f"Original columns: {df.columns.tolist()}")
                existing_columns = set()
                df.columns = [abbreviate_column_name(sanitize_name(col), existing_columns) for col in df.columns]
                logging.info(f"Sanitized columns: {df.columns.tolist()}")
                table_name = sanitize_name(os.path.splitext(os.path.basename(file_path))[0])
                insert_data_to_sql_server(df, table_name)
                log_summary(file_path, sheet_name, table_name, file_extension, df)

    except Exception as e:
        logging.error(f"Error processing file {file_path}: {e}")
        print(f"Error processing file {file_path}: {e}")
    finally:
        end_time = time.time()
        log_time_step("File processing", start_time, end_time)


def log_summary(file_path, sheet_name, table_name, file_extension, df):
    try:
        conn = connect_to_sql_server()
        cursor = conn.cursor()
        cursor.execute(f"SELECT COUNT(*) FROM [{schema_name}].[{table_name}]")
        row_count = cursor.fetchone()[0]
        conn.close()

        source_path_with_sheet = f"{file_path} - {sheet_name}" if sheet_name else file_path

        summary = {
            'source_file_path': source_path_with_sheet,
            'target_table_name': f"{schema_name}.{table_name}",
            'file_extension': file_extension,
            'num_rows_source': len(df),
            'num_columns_source': len(df.columns),
            'num_rows_target': row_count
        }
        ingestion_summary.append(summary)
        print(f"Logged summary for {table_name}")
    except Exception as e:
        logging.error(f"Error logging summary for table {table_name}: {e}")
        print(f"Error logging summary for table {table_name}: {e}")


def insert_data_to_sql_server(df, table_name):
    full_table_name = f"{schema_name}.{table_name}"
    retries = 3  # Number of retry attempts for lock timeouts
    batch_size = 1000  # Number of rows per batch
    log_interval = 100000  # Log every 100k rows
    total_rows_inserted = 0

    while retries > 0:
        try:
            conn = connect_to_sql_server()
            cursor = conn.cursor()
            ddl = f"CREATE TABLE [{schema_name}].[{table_name}] (" + ", ".join(
                [f"[{col}] NVARCHAR(MAX)" for col in df.columns]) + ")"

            try:
                cursor.execute(f"DROP TABLE IF EXISTS [{schema_name}].[{table_name}]")
                logging.info(f"Table {schema_name}.{table_name} dropped successfully.")
                print(f"Table {schema_name}.{table_name} dropped successfully.")
            except pyodbc.DatabaseError as e:
                logging.error(f"Error dropping table {schema_name}.{table_name}: {e}")
                print(f"Error dropping table {schema_name}.{table_name}: {e}")

            try:
                cursor.execute(ddl)
                logging.info(f"Table {schema_name}.{table_name} created successfully.")
                print(f"Table {schema_name}.{table_name} created successfully.")
            except pyodbc.DatabaseError as e:
                logging.error(f"Error creating table {schema_name}.{table_name}: {e}")
                print(f"Error creating table {schema_name}.{table_name}: {e}")
                return

            cursor.execute(
                f"SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '{schema_name}' AND TABLE_NAME = '{table_name}'")
            if cursor.fetchone() is None:
                raise ValueError(f"Table {schema_name}.{table_name} does not exist after creation attempt.")

            columns = ", ".join([f"[{col}]" for col in df.columns])
            values = ", ".join(['?' for _ in df.columns])
            insert_sql = f"INSERT INTO [{schema_name}].[{table_name}] ({columns}) VALUES ({values})"

            df = df.where(pd.notnull(df), None)

            # Insert data in batches
            for start in range(0, len(df), batch_size):
                batch_df = df.iloc[start:start + batch_size]
                try:
                    cursor.executemany(insert_sql, batch_df.values.tolist())
                    conn.commit()
                    total_rows_inserted += len(batch_df)
                    if total_rows_inserted % log_interval == 0:
                        logging.info(f"{total_rows_inserted} rows inserted into {schema_name}.{table_name}.")
                        print(f"{total_rows_inserted} rows inserted into {schema_name}.{table_name}.")
                except pyodbc.DatabaseError as e:
                    logging.error(f"Error inserting batch into table {schema_name}.{table_name}: {e}")
                    print(f"Error inserting batch into table {schema_name}.{table_name}: {e}")
                    raise

            conn.close()
            break
        except pyodbc.DatabaseError as e:
            logging.error(f"Error in insert_data_to_sql_server for table {schema_name}.{table_name}: {e}")
            print(f"Error in insert_data_to_sql_server for table {schema_name}.{table_name}: {e}")
            if 'Lock request time out period exceeded' in str(e):
                retries -= 1
                logging.info(f"Retrying... ({3 - retries} attempts left)")
                print(f"Retrying... ({3 - retries} attempts left)")
                time.sleep(5)  # Wait before retrying
            else:
                break


def write_summary_to_csv(summary, output_file):
    if summary:
        keys = summary[0].keys()
        with open(output_file, 'w', newline='') as output_csv:
            dict_writer = csv.DictWriter(output_csv, fieldnames=keys)
            dict_writer.writeheader()
            dict_writer.writerows(summary)


def clear_output_directory(directory):
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            logging.error(f"Failed to delete {file_path}. Reason: {e}")
            print(f"Failed to delete {file_path}. Reason: {e}")


def copy_files_to_output_directory(src_directory, dest_directory):
    copied_files = []
    for root, _, files in os.walk(src_directory):
        for file in files:
            file_path = os.path.join(root, file)
            dest_path = os.path.join(dest_directory, file)
            shutil.copy(file_path, dest_path)
            copied_files.append(dest_path)
            logging.info(f"Copied file: {file_path} to {dest_path}")
            print(f"Copied file: {file_path} to {dest_path}")
    return copied_files


def process_files_in_directory(directory):
    files = [os.path.join(root, file) for root, _, files in os.walk(directory) for file in files]
    total_files = len(files)
    for index, file_path in enumerate(files, start=1):
        start_time = time.time()
        process_file(file_path)
        end_time = time.time()
        elapsed_time = end_time - start_time
        remaining_time = estimate_time_remaining(elapsed_time, index, total_files)
        eta = datetime.now() + timedelta(seconds=remaining_time)
        print(
            f"Processed file {index}/{total_files} in {timedelta(seconds=elapsed_time)}, ETA: {eta.strftime('%H:%M:%S')}")


# Ensure schema exists
ensure_schema_exists()

# Step 1: Clear the output directory
start_time = time.time()
logging.info(f"Clearing the output directory: {output_directory}")
print(f"Clearing the output directory: {output_directory}")
clear_output_directory(output_directory)
end_time = time.time()
log_time_step("Clear output directory", start_time, end_time)

# Step 2: Copy files to the output directory
start_time = time.time()
logging.info(f"Copying files from directory: {source_directory} to {output_directory}")
print(f"Copying files from directory: {source_directory} to {output_directory}")
copied_files = copy_files_to_output_directory(source_directory, output_directory)
end_time = time.time()
log_time_step("Copy files to output directory", start_time, end_time)

if not copied_files:
    logging.warning("No files were copied. Check the source directory path and file permissions.")
    print("No files were copied. Check the source directory path and file permissions.")
else:
    # Step 3: Ingest copied files into SQL Server
    start_time = time.time()
    logging.info(f"Starting ingestion process for copied files")
    print(f"Starting ingestion process for copied files")
    process_files_in_directory(output_directory)
    end_time = time.time()
    log_time_step("Ingest copied files", start_time, end_time)

    # Write the summary to CSV
    start_time = time.time()
    summary_output_file = 'parser_summary.csv'
    write_summary_to_csv(ingestion_summary, summary_output_file)
    logging.info(f"Summary written to {summary_output_file}")
    print(f"Summary written to {summary_output_file}")
    end_time = time.time()
    log_time_step("Write summary to CSV", start_time, end_time)

logging.info("Script finished.")
print("Script finished.")
