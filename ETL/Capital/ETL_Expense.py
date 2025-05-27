import os
import pandas as pd
import pyodbc
import re
import socket
import time
import logging
import csv
import shutil


# Mapping of nodes to databases
node_db_mapping = {
    'WADINFWWAPV02': 'WAD_PRD_Expense',
    'WADINFWWDDV01': 'WAD_STG_Expense'
    # Add other nodes and their corresponding databases here
}

output_directory = r'D:\LZ\Capital'

# Function to sanitize file names and column names
def sanitize_name(name):
    return re.sub(r'\W+', '_', name)

# Get the current node
current_node = socket.gethostname().upper()
database_name = node_db_mapping.get(current_node, 'WAD_STG_Expense')  # Default to 'Playground' if node not found

# SQL Server connection settings
connection_string = (
    f"Driver={{ODBC Driver 17 for SQL Server}};"
    f"Server={current_node};"
    f"Database={database_name};"
    "Trusted_Connection=yes;"
)

# Specify the target schema
schema_name = 'LZ_Expense'

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
        

def find_column_name(table_name):
    # Connect to WAD_STG_Capital database
    wad_stg_expense_conn_str = (
        f"Driver={{ODBC Driver 17 for SQL Server}};"
        f"Server={current_node};"
        f"Database=WAD_STG_Expense;"
        "Trusted_Connection=yes;"
    )
    
    try:
        wad_stg_expense_conn = pyodbc.connect(wad_stg_expense_conn_str)
        wad_stg_expense_cursor = wad_stg_expense_conn.cursor()
        
        # Query to retrieve column names for the table matching the CSV filename
        wad_stg_expense_cursor.execute(f"""
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA <> 'LZ_Expense' AND TABLE_NAME = ?
        """, table_name)
        
        columns = [row.COLUMN_NAME for row in wad_stg_expense_cursor.fetchall()]
        
        # If no columns are found, log a warning and return an empty list
        if not columns:
            logging.warning(f"No columns found for table {table_name} in WAD_STG_Expense")
            print(f"No columns found for table {table_name} in WAD_STG_Expense")
        
        return columns
    
    except pyodbc.DatabaseError as e:
        logging.error(f"Error retrieving column names for table {table_name}: {e}")
        print(f"Error retrieving column names for table {table_name}: {e}")
        return []
    
    finally:
        wad_stg_expense_conn.close()
    

def process_file(file_path):
    try:
        start_time = time.time()
        file_extension = os.path.splitext(file_path)[1].lower()

        logging.info(f"Processing file: {file_path} with extension: {file_extension}")

        if file_extension in ['.xls', '.xlsx']:
            xls = pd.ExcelFile(file_path)
            for sheet_name in xls.sheet_names:
                df = pd.read_excel(xls, sheet_name=sheet_name, dtype=str)
                print(f"DataFrame columns: {df.columns.tolist()}")
                df.columns = [sanitize_name(col) for col in df.columns]
                table_name = sanitize_name(f"{os.path.splitext(os.path.basename(file_path))[0]}_{sheet_name}")
                cols = find_column_name(table_name)
                insert_data_to_sql_server(df, table_name, cols)
                log_summary(file_path, sheet_name, table_name, file_extension, df)
        else:
            df = None
            sheet_name = None
            if file_extension in ['.csv', '.txt']:
                delimiter = detect_delimiter(file_path)
                try:
                    df = pd.read_csv(file_path, delimiter=delimiter, dtype=str, encoding='utf-8')
                except UnicodeDecodeError:
                    try:
                        df = pd.read_csv(file_path, delimiter=delimiter, dtype=str, encoding='latin1')
                    except Exception as e:
                        logging.error(f"Error reading file {file_path} with latin1 encoding: {e}")
                        print(f"Error reading file {file_path} with latin1 encoding: {e}")
                        return
            else:
                logging.warning(f"Unsupported file extension: {file_extension}")
                print(f"Unsupported file extension: {file_extension}")
                return

            if df is not None:
                df.columns = [sanitize_name(col) for col in df.columns]
                print(f"DataFrame columns: {df.columns.tolist()}")
                table_name = sanitize_name(os.path.splitext(os.path.basename(file_path))[0])
                cols = find_column_name(table_name)
                insert_data_to_sql_server(df, table_name, cols)
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


def insert_data_to_sql_server(df, table_name, cols):
    cols_filter = {
        'FUTUREYEAR': [2, 3, 9], 
        'ESTIMATE': [1, 11, 15, 20] 
    }

    # if we are only selecting a subset of columns
    if table_name in cols_filter:
        df = df.iloc[:, cols_filter[table_name]]
        df.columns = cols

    else:
        # Assign the filtered column names to the DataFrame
        df.columns = cols
        print(f"df after setting columns: {df.head()}")

    # Generate DDL for table creation using the filtered column names in `cols`
    ddl = f"CREATE TABLE [{schema_name}].[{table_name}] (" + ", ".join([f"[{col}] NVARCHAR(MAX)" for col in cols]) + ")"

    # Drop table if exists and create a new table
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
    columns = ", ".join([f"[{col}]" for col in cols])
    values = ", ".join(['?' for _ in cols])
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


def process_files_in_directory(directory, expenseFiles):
    for root, _, files in os.walk(directory):
        for file in files:

            if file not in expenseFiles:
                continue

            file_path = os.path.join(root, file)
            process_file(file_path)
            logging.info(f"Processed file: {file_path}")
            print(f"Processed file: {file_path}")


def rename_files_in_directory(directory):

    rename_mapping = {
    'GLEXPENSE.csv': 'Raw_GLExpense.csv',
    'PJEXPENSE.csv': 'Raw_PJExpense.csv',
    }

    try:
        for root, _, files in os.walk(directory):
            for file in files:
                print(f"File: {file}")
                if file in rename_mapping:
                    old_file_path = os.path.join(root, file)
                    new_file_path = os.path.join(root, rename_mapping[file])
                    os.rename(old_file_path, new_file_path)
                    logging.info(f"Renamed file: {old_file_path} to {new_file_path}")
                    print(f"Renamed file: {old_file_path} to {new_file_path}")
    except Exception as e:
        logging.error(f"Error renaming files in directory {directory}: {e}")
        print(f"Error renaming files in directory {directory}: {e}")



def main():

    # files for expense
    expenseFiles = ['Raw_GLExpense.csv', 'Raw_PJExpense.csv']
    rename_files_in_directory(output_directory)

    # ingest copied files into SQL Server
    logging.info(f"Starting ingestion process for copied files")
    print(f"Starting ingestion process for copied files")
    process_files_in_directory(output_directory, expenseFiles)

    # Close the SQL connection
    conn.close()

    logging.info("Script finished.")
    print("Script finished.")



if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
    main()