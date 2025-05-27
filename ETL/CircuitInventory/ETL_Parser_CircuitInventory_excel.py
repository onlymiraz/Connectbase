import os
import pandas as pd
import pyodbc
import re
import socket
import time
import logging
import shutil
import csv  # Make sure to import the csv module

# Configure logging
logging.basicConfig(filename='excel_ingestion_log.txt', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

# Function to sanitize file names and column names
def sanitize_name(name):
    return re.sub(r'\W+', '_', name)

# Define the output directory
script_directory = os.path.dirname(os.path.abspath(__file__))  # Directory where the script is running
output_directory = os.path.join(script_directory, 'copied_files')  # New folder for copied files

# Ensure the output directory exists
os.makedirs(output_directory, exist_ok=True)

# Define the source Excel file location
source_excel_file = r'D:\LZ\CircuitInventory\CABS Co Table.xlsx'  # Update with the correct path to your Excel file

# Copy the Excel file to the output directory
shutil.copy(source_excel_file, output_directory)
logging.info(f"Copied Excel file to {output_directory}")

# Mapping of nodes to databases
node_db_mapping = {
    'WADINFWWAPV02': 'WAD_PRD_Integration',
    'WADINFWWDDV01': 'WAD_STG_Integration'
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
schema_name = 'LZ_Py_CircuitInventory'

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

def process_excel_file(file_path):
    try:
        start_time = time.time()
        xls = pd.ExcelFile(file_path)

        logging.info(f"Processing Excel file: {file_path}")

        for sheet_name in xls.sheet_names:
            df = pd.read_excel(xls, sheet_name=sheet_name, dtype=str)
            df.columns = [sanitize_name(col) for col in df.columns]
            table_name = sanitize_name(f"{os.path.splitext(os.path.basename(file_path))[0]}_{sheet_name}")
            insert_data_to_sql_server(df, table_name)
            log_summary(file_path, sheet_name, table_name, df)

    except Exception as e:
        logging.error(f"Error processing Excel file {file_path}: {e}")
        print(f"Error processing Excel file {file_path}: {e}")
    finally:
        elapsed_time = time.time() - start_time
        logging.info(f"Excel file {file_path} processed in {elapsed_time:.2f} seconds.")
        print(f"Excel file {file_path} processed in {elapsed_time:.2f} seconds.")

def log_summary(file_path, sheet_name, table_name, df):
    try:
        # Get row count of the target table
        cursor.execute(f"SELECT COUNT(*) FROM [{schema_name}].[{table_name}]")
        row_count = cursor.fetchone()[0]

        summary = {
            'source_file_path': f"{file_path} - {sheet_name}",
            'target_table_name': f"{schema_name}.{table_name}",
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

# Process the Excel file
process_excel_file(os.path.join(output_directory, 'CABS Co Table.xlsx'))

# Write the summary to CSV
summary_output_file = 'excel_parser_summary.csv'
write_summary_to_csv(ingestion_summary, summary_output_file)
logging.info(f"Summary written to {summary_output_file}")
print(f"Summary written to {summary_output_file}")

# Close the SQL connection
conn.close()

logging.info("Script finished.")
print("Script finished.")
