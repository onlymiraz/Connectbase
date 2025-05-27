import os
import pandas as pd
import pyodbc
import re
import socket
import time
import logging
import csv

# Configure logging
logging.basicConfig(filename='script_log.txt', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

# Function to sanitize column names
def sanitize_column_names(df):
    df.columns = [re.sub(r'\W+', '_', col) for col in df.columns]
    return df

# Define the root source directories
source_directories = [
    r'\\WADINFWWDDV01\LZ',
    # Add more directories as needed
]

# Mapping of nodes to databases
node_db_mapping = {
    'WADINFWWAPV02': 'WAD_STG_02',
    'WADINFWWDDV01': 'Playground'
    # Add other nodes and their corresponding databases here
}

# Get the current node
current_node = socket.gethostname().upper()
database_name = node_db_mapping.get(current_node, 'Playground')  # Default to 'Playground' if node not found

# SQL Server connection settings
connection_string = (
    "Driver={ODBC Driver 17 for SQL Server};"
    f"Server={current_node};"
    f"Database={database_name};"
    "Trusted_Connection=yes;"
)

# Establish SQL Server connection
conn = pyodbc.connect(connection_string)
cursor = conn.cursor()

# List to collect summary statistics
ingestion_summary = []

def detect_delimiter(file_path):
    with open(file_path, 'r') as file:
        sample = file.read(1024)
        sniffer = csv.Sniffer()
        dialect = sniffer.sniff(sample)
        return dialect.delimiter

def process_file(file_path, table_name):
    try:
        start_time = time.time()
        file_extension = os.path.splitext(file_path)[1].lower()
        df = None
        
        # Read file into a DataFrame
        if file_extension in ['.csv', '.txt']:
            delimiter = detect_delimiter(file_path)
            df = pd.read_csv(file_path, delimiter=delimiter, dtype=str)
        elif file_extension in ['.xls', '.xlsx']:
            df = pd.read_excel(file_path, dtype=str)
        elif file_extension in ['.mdb', '.accdb']:
            access_conn_str = f"DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={file_path};"
            access_conn = pyodbc.connect(access_conn_str)
            access_cursor = access_conn.cursor()
            for table_info in access_cursor.tables(tableType='TABLE'):
                table_name = table_info.table_name
                df = pd.read_sql(f"SELECT * FROM [{table_name}]", access_conn)
                df = sanitize_column_names(df)
                insert_data_to_sql_server(df.astype(str), table_name)
                log_summary(file_path, table_name, file_extension, df)
            for view_info in access_cursor.tables(tableType='VIEW'):
                view_name = view_info.table_name
                df = pd.read_sql(f"SELECT * FROM [{view_name}]", access_conn)
                df = sanitize_column_names(df)
                insert_data_to_sql_server(df.astype(str), view_name)
                log_summary(file_path, view_name, file_extension, df)
            access_conn.close()
            return
        else:
            print(f"Unsupported file extension: {file_extension}")
            return

        df = sanitize_column_names(df)
        insert_data_to_sql_server(df.astype(str), table_name)
        log_summary(file_path, table_name, file_extension, df)

    except Exception as e:
        logging.error(f"Error processing file {file_path}: {e}")
        print(f"Error processing file {file_path}: {e}")
    finally:
        elapsed_time = time.time() - start_time
        print(f"File {file_path} processed in {elapsed_time:.2f} seconds.")
        logging.info(f"File {file_path} processed in {elapsed_time:.2f} seconds.")

def log_summary(file_path, table_name, file_extension, df):
    # Get row count of the target table
    cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
    row_count = cursor.fetchone()[0]

    summary = {
        'source_file_path': file_path,
        'target_table_name': table_name,
        'file_extension': file_extension,
        'num_rows_source': len(df),
        'num_columns_source': len(df.columns),
        'num_rows_target': row_count
    }
    ingestion_summary.append(summary)

def insert_data_to_sql_server(df, table_name):
    try:
        # Generate DDL for table creation
        ddl = f"CREATE TABLE {table_name} (" + ", ".join([f"[{col}] NVARCHAR(MAX)" for col in df.columns]) + ")"
        
        # Drop table if exists and create new table
        try:
            cursor.execute(f"DROP TABLE IF EXISTS {table_name}")
            print(f"Table {table_name} dropped successfully.")
        except pyodbc.DatabaseError as e:
            print(f"Error dropping table {table_name}: {e}")
        
        try:
            cursor.execute(ddl)
            print(f"Table {table_name} created successfully.")
        except pyodbc.DatabaseError as e:
            print(f"Error creating table {table_name}: {e}")
            return
        
        # Ensure the table exists before proceeding with data insertion
        cursor.execute(f"SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '{table_name}'")
        if cursor.fetchone() is None:
            raise ValueError(f"Table {table_name} does not exist after creation attempt.")

        # Insert data into table
        columns = ", ".join([f"[{col}]" for col in df.columns])
        values = ", ".join(['?' for _ in df.columns])
        insert_sql = f"INSERT INTO {table_name} ({columns}) VALUES ({values})"
        
        try:
            cursor.executemany(insert_sql, df.values.tolist())
            conn.commit()
            print(f"Data inserted into table {table_name} successfully.")
        except pyodbc.DatabaseError as e:
            logging.error(f"Error inserting data into table {table_name}: {e}")
            print(f"Error inserting data into table {table_name}: {e}")
            # Attempt row-by-row insertion
            for index, row in df.iterrows():
                try:
                    cursor.execute(insert_sql, tuple(row))
                except pyodbc.DatabaseError as row_e:
                    logging.error(f"Error inserting row {index} into table {table_name}: {row_e}, Row Data: {row}")
                    print(f"Error inserting row {index} into table {table_name}: {row_e}, Row Data: {row}")
            conn.commit()

    except Exception as e:
        logging.error(f"Error in insert_data_to_sql_server for table {table_name}: {e}")
        print(f"Error in insert_data_to_sql_server for table {table_name}: {e}")

def process_directory(root_directory):
    start_time = time.time()
    # Count total number of files
    total_files = sum([len(files) for r, d, files in os.walk(root_directory)])
    print(f"Total number of files to process in {root_directory}: {total_files}")
    logging.info(f"Total number of files to process in {root_directory}: {total_files}")

    processed_files = 0

    for dirpath, _, filenames in os.walk(root_directory):
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            table_name = "LZ__" + re.sub(r'\W+', '_', os.path.splitext(filename)[0])
            print(f"Processing file {processed_files + 1}/{total_files}: {file_path}")
            process_file(file_path, table_name)
            processed_files += 1
            remaining_files = total_files - processed_files
            eta = (time.time() - start_time) / processed_files * remaining_files
            print(f"Remaining files in {root_directory}: {remaining_files}")
            print(f"ETA for remaining files: {eta:.2f} seconds.")
            logging.info(f"Remaining files in {root_directory}: {remaining_files}")
            logging.info(f"ETA for remaining files: {eta:.2f} seconds.")

    total_elapsed_time = time.time() - start_time
    print(f"Total processing time for {root_directory}: {total_elapsed_time:.2f} seconds.")
    logging.info(f"Total processing time for {root_directory}: {total_elapsed_time:.2f} seconds.")

# Process each source directory
for source_directory in source_directories:
    print(f"Starting processing for directory: {source_directory}")
    process_directory(source_directory)

# Print and save ingestion summary
summary_df = pd.DataFrame(ingestion_summary)
summary_csv_path = os.path.join(os.getcwd(), 'ingestion_summary.csv')
summary_df.to_csv(summary_csv_path, index=False)

print("\nIngestion Summary:")
print(summary_df)

# Close the SQL connection
conn.close()

print("Script finished.")
logging.info("Script finished.")
