import os
import pandas as pd
import pyodbc
import re
import socket
import time
import logging
import csv
import shutil
from datetime import datetime

# Configure logging
logging.basicConfig(filename='combined_log.txt', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')


# Sanitize function for filenames and column names
def sanitize_name(name):
    return re.sub(r'\W+', '_', name)


# Define directories
script_directory = os.path.dirname(os.path.abspath(__file__))
output_directory = os.path.join(script_directory, 'copied_files')
os.makedirs(output_directory, exist_ok=True)

# Source directory for files
source_directory = r'd:\lz\CircuitInventory'

# Node-to-database mapping
node_db_mapping = {
    'WADINFWWAPV02': 'WAD_PRD_Integration',
    'WADINFWWDDV01': 'WAD_STG_Integration'
}

# Get the current node
current_node = socket.gethostname().upper()
database_name = node_db_mapping.get(current_node, 'Playground')

# SQL Server connection settings
connection_string = (
    f"Driver={{ODBC Driver 17 for SQL Server}};"
    f"Server={current_node};"
    f"Database={database_name};"
    "Trusted_Connection=yes;"
)

# Specify schema
schema_name = 'LZ_Py_CircuitInventory'

# Establish SQL Server connection
conn = pyodbc.connect(connection_string)
cursor = conn.cursor()

# Create schema if not exists
cursor.execute(f"""
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{schema_name}')
BEGIN
    EXEC('CREATE SCHEMA [{schema_name}]')
END
""")
conn.commit()

# Collect summary statistics
ingestion_summary = []

# List of files to process
csv_files_to_process = [
    "ALL_ACTIVE_CZN.csv",
    "ALL_ACTIVE_RTC.csv",
    "ALL_ACTIVE_SOC.csv",
    "ALL_DISCO_CZN.csv",
    "ALL_DISCO_RTC.csv",
    "ALL_DISCO_SOC.csv"
]


# Detect delimiter in CSV file
def detect_delimiter(file_path):
    with open(file_path, 'r', errors='ignore') as file:
        sample = file.read(1024)
        sniffer = csv.Sniffer()
        try:
            dialect = sniffer.sniff(sample)
            return dialect.delimiter
        except csv.Error:
            logging.warning(f"Could not determine delimiter for {file_path}. Using default ','")
            return ','


# Process file and ingest data
def process_file(file_path):
    try:
        start_time = time.time()
        file_extension = os.path.splitext(file_path)[1].lower()

        if file_extension == '.csv':
            # Load CSV with specific encoding and error handling
            try:
                df = pd.read_csv(
                    file_path,
                    delimiter=',',
                    dtype=str,
                    encoding='latin1',
                    on_bad_lines='skip',
                    quoting=csv.QUOTE_NONE,
                    skip_blank_lines=True
                )
            except pd.errors.ParserError as e:
                logging.error(f"Error parsing {file_path}: {e}")
                return

            # Sanitize column names
            df.columns = [sanitize_name(col) for col in df.columns]

            # Unique table name with timestamp
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            table_name = sanitize_name(f"{os.path.splitext(os.path.basename(file_path))[0]}_{timestamp}")

            # Insert data into SQL server with new table name
            insert_data_to_sql_server(df, table_name)
            log_summary(file_path, table_name, file_extension, df)

    except Exception as e:
        logging.error(f"Error processing {file_path}: {e}")
        print(f"Error processing {file_path}: {e}")
    finally:
        elapsed_time = time.time() - start_time
        logging.info(f"{file_path} processed in {elapsed_time:.2f} seconds.")
        print(f"{file_path} processed in {elapsed_time:.2f} seconds.")


# Log summary
def log_summary(file_path, table_name, file_extension, df):
    try:
        cursor.execute(f"SELECT COUNT(*) FROM [{schema_name}].[{table_name}]")
        row_count = cursor.fetchone()[0]

        summary = {
            'source_file_path': file_path,
            'target_table_name': f"{schema_name}.{table_name}",
            'file_extension': file_extension,
            'num_rows_source': len(df),
            'num_columns_source': len(df.columns),
            'num_rows_target': row_count,
            'ingestion_timestamp': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        ingestion_summary.append(summary)
        print(f"Logged summary for {table_name}")
    except Exception as e:
        logging.error(f"Error logging summary for {table_name}: {e}")
        print(f"Error logging summary for {table_name}: {e}")


# Insert data into SQL server with unique table name
def insert_data_to_sql_server(df, table_name):
    try:
        # DDL for table creation
        ddl = f"CREATE TABLE [{schema_name}].[{table_name}] (" + ", ".join(
            [f"[{col}] NVARCHAR(MAX)" for col in df.columns]) + ")"

        # Drop table if exists and create new table
        cursor.execute(f"DROP TABLE IF EXISTS [{schema_name}].[{table_name}]")
        cursor.execute(ddl)

        # Insert data into table
        columns = ", ".join([f"[{col}]" for col in df.columns])
        values = ", ".join(['?' for _ in df.columns])
        insert_sql = f"INSERT INTO [{schema_name}].[{table_name}] ({columns}) VALUES ({values})"

        # Convert NaN to None
        df = df.where(pd.notnull(df), None)
        cursor.executemany(insert_sql, df.values.tolist())
        conn.commit()

    except Exception as e:
        logging.error(f"Error in insert_data_to_sql_server for {table_name}: {e}")
        print(f"Error in insert_data_to_sql_server for {table_name}: {e}")


# Write summary to CSV
def write_summary_to_csv(summary, output_file):
    if summary:
        keys = summary[0].keys()
        with open(output_file, 'w', newline='') as output_csv:
            dict_writer = csv.DictWriter(output_csv, fieldnames=keys)
            dict_writer.writeheader()
            dict_writer.writerows(summary)


# Clear output directory
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


# Copy files to output directory
def copy_files_to_output_directory(src_directory, dest_directory, files_to_copy):
    copied_files = []
    for root, _, files in os.walk(src_directory):
        for file in files:
            if file.lower() in [f.lower() for f in files_to_copy]:  # Case-insensitive match
                file_path = os.path.join(root, file)
                dest_path = os.path.join(dest_directory, file)
                shutil.copy(file_path, dest_path)
                copied_files.append(dest_path)
    return copied_files


# Process files in a directory
def process_files_in_directory(directory, files_to_process):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower() in [f.lower() for f in files_to_process]:  # Case-insensitive match
                file_path = os.path.join(root, file)
                process_file(file_path)


# Clear the output directory
clear_output_directory(output_directory)

# Copy specified files to the output directory
copied_files = copy_files_to_output_directory(source_directory, output_directory, csv_files_to_process)

if copied_files:
    # Process and ingest copied files into SQL Server
    process_files_in_directory(output_directory, csv_files_to_process)

    # Write the summary to CSV
    summary_output_file = 'parser_summary.csv'
    write_summary_to_csv(ingestion_summary, summary_output_file)
else:
    logging.warning("No files were copied. Check source directory path, file names, and permissions.")

# Close SQL connection
conn.close()

logging.info("Script finished.")
print("Script finished.")
