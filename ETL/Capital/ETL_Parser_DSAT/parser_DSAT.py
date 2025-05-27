import os
import pandas as pd
import pyodbc
import re
import socket
import time
import logging
import csv
import shutil

# Configure logging
logging.basicConfig(filename='combined_log.txt', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

# Function to sanitize file names and column names
def sanitize_name(name):
    return re.sub(r'\W+', '_', name)

# Define the output directory
script_directory = os.path.dirname(os.path.abspath(__file__))  # Directory where the script is running
output_directory = os.path.join(script_directory, 'copied_files')  # New folder for copied files

# Ensure the output directory exists
os.makedirs(output_directory, exist_ok=True)

# Define the source directory to search for files recursively
source_directory = r'D:\LZ\Capital\DSAT'

# Mapping of nodes to databases
node_db_mapping = {
    'WADINFWWAPV02': 'WAD_PRD_Integration',
    'WADINFWWDDV01': 'WAD_STG_Integration'
    # Add other nodes and their corresponding databases here
}

# Get the current node
current_node = socket.gethostname().upper()
database_name = node_db_mapping.get(current_node, 'Playground')  # Default to 'Playground' if node not found

# SQL Server connection settings
connection_string = (
    f"Driver={{ODBC Driver 17 for SQL Server}};"
    f"Server={current_node};"
    f"Database={database_name};"
    "Trusted_Connection=yes;"
)

# Specify the target schema
schema_name = 'LZ_Py_Capital'

# Establish SQL Server connection
conn = pyodbc.connect(connection_string)
cursor = conn.cursor()

# Create schema if it doesn't exist
cursor.execute(f"""
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{schema_name}')
BEGIN
    EXEC('CREATE SCHEMA [{schema_name}]')
END
""")
conn.commit()

# List to collect summary statistics
ingestion_summary = []

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
                df.columns = [sanitize_name(col) for col in df.columns]
                table_name = sanitize_name(f"{os.path.splitext(os.path.basename(file_path))[0]}_{sheet_name}")
                insert_data_to_sql_server(df, table_name)
                log_summary(file_path, sheet_name, table_name, file_extension, df)
        else:
            df = None
            sheet_name = None
            if file_extension == '.csv' or file_extension == '.txt':
                delimiter = detect_delimiter(file_path)
                df = pd.read_csv(file_path, delimiter=delimiter, dtype=str)
            else:
                logging.warning(f"Unsupported file extension: {file_extension}")
                print(f"Unsupported file extension: {file_extension}")
                return

            if df is not None:
                df.columns = [sanitize_name(col) for col in df.columns]
                table_name = sanitize_name(os.path.splitext(os.path.basename(file_path))[0])
                insert_data_to_sql_server(df, table_name)
                log_summary(file_path, sheet_name, table_name, file_extension, df)

    except Exception as e:
        logging.error(f"Error processing file {file_path}: {e}")
        print(f"Error processing file {file_path}: {e}")
    finally:
        elapsed_time = time.time() - start_time
        logging.info(f"File {file_path} processed in {elapsed_time:.2f} seconds.")
        print(f"File {file_path} processed in {elapsed_time:.2f} seconds.")

def log_summary(file_path, sheet_name, table_name, file_extension, df):
    try:
        # Get row count of the target table
        cursor.execute(f"SELECT COUNT(*) FROM [{schema_name}].[{table_name}]")
        row_count = cursor.fetchone()[0]

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
    try:
        # Generate DDL for table creation
        ddl = f"CREATE TABLE [{schema_name}].[{table_name}] (" + ", ".join([f"[{col}] NVARCHAR(MAX)" for col in df.columns]) + ")"

        # Drop table if exists and create new table
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

        # Ensure the table exists before proceeding with data insertion
        cursor.execute(f"SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '{schema_name}' AND TABLE_NAME = '{table_name}'")
        if cursor.fetchone() is None:
            raise ValueError(f"Table {schema_name}.{table_name} does not exist after creation attempt.")

        # Insert data into table
        columns = ", ".join([f"[{col}]" for col in df.columns])
        values = ", ".join(['?' for _ in df.columns])
        insert_sql = f"INSERT INTO [{schema_name}].[{table_name}] ({columns}) VALUES ({values})"

        # Convert NaN to None
        df = df.where(pd.notnull(df), None)

        try:
            cursor.executemany(insert_sql, df.values.tolist())
            conn.commit()
            logging.info(f"Data inserted into table {schema_name}.{table_name} successfully.")
            print(f"Data inserted into table {schema_name}.{table_name} successfully.")
        except pyodbc.DatabaseError as e:
            logging.error(f"Error inserting data into table {schema_name}.{table_name}: {e}")
            print(f"Error inserting data into table {schema_name}.{table_name}: {e}")
            # Attempt row-by-row insertion
            for index, row in df.iterrows():
                try:
                    cursor.execute(insert_sql, tuple(row))
                except pyodbc.DatabaseError as row_e:
                    logging.error(f"Error inserting row {index} into table {schema_name}.{table_name}: {row_e}, Row Data: {row}")
                    print(f"Error inserting row {index} into table {schema_name}.{table_name}: {row_e}, Row Data: {row}")
            conn.commit()

    except Exception as e:
        logging.error(f"Error in insert_data_to_sql_server for table {schema_name}.{table_name}: {e}")
        print(f"Error in insert_data_to_sql_server for table {schema_name}.{table_name}: {e}")

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
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            process_file(file_path)
            logging.info(f"Processed file: {file_path}")
            print(f"Processed file: {file_path}")

# Step 1: Clear the output directory
logging.info(f"Clearing the output directory: {output_directory}")
print(f"Clearing the output directory: {output_directory}")
clear_output_directory(output_directory)

# Step 2: Copy files to the output directory
logging.info(f"Copying files from directory: {source_directory} to {output_directory}")
print(f"Copying files from directory: {source_directory} to {output_directory}")
copied_files = copy_files_to_output_directory(source_directory, output_directory)

if not copied_files:
    logging.warning("No files were copied. Check the source directory path and file permissions.")
    print("No files were copied. Check the source directory path and file permissions.")
else:
    # Step 3: Ingest copied files into SQL Server
    logging.info(f"Starting ingestion process for copied files")
    print(f"Starting ingestion process for copied files")
    process_files_in_directory(output_directory)

    # Write the summary to CSV
    summary_output_file = 'parser_summary.csv'
    write_summary_to_csv(ingestion_summary, summary_output_file)
    logging.info(f"Summary written to {summary_output_file}")
    print(f"Summary written to {summary_output_file}")

# Close the SQL connection
conn.close()

logging.info("Script finished.")
print("Script finished.")
