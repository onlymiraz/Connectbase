import os
import pandas as pd
import pyodbc
import re
import glob
import socket
import csv
import logging

# Configure logging
logging.basicConfig(filename='script_log.txt', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

# Log the start of the script
logging.info('Script started.')
print('Script started.')

# Get the node hosting/running the script
node_name = socket.gethostname()
logging.info(f'Script is running on node: {node_name}')
print(f'Script is running on node: {node_name}')

# Mapping of node names to database names
node_to_database = {
    'WADINFWWAPV02': 'WAD_STG_02',
    #'WADINFWWAPV02': 'WAD_PRD_02',
    # 'WADINFWWAPV02': 'WAD_PRD_02',
    'WADINFWWDDV01': 'Playground'
    # Add more mappings as needed
}

# Determine the database name based on the node name
database = node_to_database.get(node_name, 'DefaultDatabase')
logging.info(f'Using database: {database}')
print(f'Using database: {database}')

# Set the server name (assuming server name is same as node name)
server = node_name

# SQL Server connection string with Windows Authentication
sql_server_conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes;'

# Establish the connection
try:
    sql_server_conn = pyodbc.connect(sql_server_conn_str)
    sql_server_cursor = sql_server_conn.cursor()
    logging.info('Connection to SQL Server established.')
    print('Connection to SQL Server established.')
except pyodbc.Error as e:
    logging.error(f'Error connecting to SQL Server: {e}')
    print(f'Error connecting to SQL Server: {e}')
    raise

# Get the SQL Server instance name
try:
    sql_server_cursor.execute("SELECT CONVERT(sysname, SERVERPROPERTY('servername'))")
    server_name = sql_server_cursor.fetchone()[0]
    logging.info(f'Connected to SQL Server instance: {server_name}')
    print(f'Connected to SQL Server instance: {server_name}')
except pyodbc.Error as e:
    logging.error(f'Error retrieving SQL Server instance name: {e}')
    print(f'Error retrieving SQL Server instance name: {e}')
    raise

# List of directories where the files are located
source_directories = [
    r'\\WADINFWWDDV01\d\LZ\MasterStream',
    # r'D:/path/to/your/files/directory2',
    # r'D:/path/to/your/files/directory3'
    # Add more directories as needed
]

# Function to create a table name from a filename
def create_table_name(filename):
    # Remove the file extension
    table_name = os.path.splitext(filename)[0]
    # Replace non-alphanumeric characters with underscores
    table_name = re.sub(r'[^a-zA-Z0-9]', '_', table_name)
    return table_name

# Function to sanitize column names
def sanitize_column_name(column_name):
    return re.sub(r'[^a-zA-Z0-9]', '_', column_name)

# Function to create a DDL statement for a file
def create_ddl(dataframe, schema, table_name):
    ddl = f'CREATE TABLE {schema}.{table_name} (\n'
    for column in dataframe.columns:
        sanitized_column = sanitize_column_name(column)
        ddl += f'    [{sanitized_column}] VARCHAR(255),\n'
    ddl = ddl.rstrip(',\n') + '\n);'
    return ddl

# Function to read a file into a DataFrame
def read_file(file_path):
    ext = os.path.splitext(file_path)[1].lower()
    if ext in ['.csv', '.txt']:
        with open(file_path, 'r') as file:
            sample = file.read(1024)
            sniffer = csv.Sniffer()
            delimiter = sniffer.sniff(sample).delimiter
        return pd.read_csv(file_path, delimiter=delimiter, dtype=str)
    elif ext in ['.xls', '.xlsx']:
        return pd.read_excel(file_path, dtype=str)
    else:
        raise ValueError(f"Unsupported file extension: {ext}")

# Function to drop table if it exists
def drop_table_if_exists(schema, table_name):
    try:
        sql_server_cursor.execute(f"IF OBJECT_ID('{schema}.{table_name}', 'U') IS NOT NULL DROP TABLE {schema}.{table_name}")
        sql_server_conn.commit()
        logging.info(f'Table {schema}.{table_name} dropped successfully.')
        print(f'Table {schema}.{table_name} dropped successfully.')
    except pyodbc.Error as e:
        logging.error(f'Error dropping table {schema}.{table_name}: {e}')
        print(f'Error dropping table {schema}.{table_name}: {e}')

# Schema name
schema = 'LZ'

# Iterate over all source directories
for directory_path in source_directories:
    logging.info(f'Searching for files in directory: {directory_path}')
    print(f'Searching for files in directory: {directory_path}')
    
    # Iterate over all files in the directory
    for file_path in glob.glob(os.path.join(directory_path, '*.*')):
        filename = os.path.basename(file_path)
        table_name = create_table_name(filename)
        
        # Read the file into a DataFrame
        try:
            df = read_file(file_path)
            logging.info(f'Read file {file_path} into DataFrame.')
            print(f'Read file {file_path} into DataFrame.')
        except Exception as e:
            logging.error(f'Error reading file {file_path}: {e}')
            print(f'Error reading file {file_path}: {e}')
            continue
        
        # Drop the table if it already exists
        drop_table_if_exists(schema, table_name)
        
        # Create DDL statement
        ddl = create_ddl(df, schema, table_name)
        logging.info(f'Generated DDL for table {schema}.{table_name}.')
        print(f'Generated DDL for table {schema}.{table_name}.')
        
        # Execute the table creation query
        try:
            sql_server_cursor.execute(ddl)
            sql_server_conn.commit()
            logging.info(f'Table {schema}.{table_name} created successfully.')
            print(f'Table {schema}.{table_name} created successfully.')
        except pyodbc.Error as e:
            logging.error(f'Error creating table {schema}.{table_name}: {e}')
            print(f'Error creating table {schema}.{table_name}: {e}')
        
        # Sanitize DataFrame column names to match the table's columns
        df.columns = [sanitize_column_name(col) for col in df.columns]
        logging.info(f'Sanitized column names: {df.columns.tolist()}')
        print(f'Sanitized column names: {df.columns.tolist()}')

        # Insert data into the table
        insert_query = f"""
        INSERT INTO {schema}.{table_name} ({', '.join([f'[{sanitize_column_name(col)}]' for col in df.columns])}) VALUES ({', '.join(['?'] * len(df.columns))})
        """
        
        # Convert the DataFrame to a list of tuples
        data = [tuple(row) for row in df.itertuples(index=False, name=None)]
        
        # Execute the insert query for each row
        try:
            sql_server_cursor.executemany(insert_query, data)
            sql_server_conn.commit()
            logging.info(f'Data inserted into table {schema}.{table_name} successfully.')
            print(f'Data inserted into table {schema}.{table_name} successfully.')
        except pyodbc.Error as e:
            logging.error(f'Error inserting data into table {schema}.{table_name}: {e}')
            print(f'Error inserting data into table {schema}.{table_name}: {e}')

# Close the connection
sql_server_cursor.close()
sql_server_conn.close()
logging.info('Connection to SQL Server closed.')
print('Connection to SQL Server closed.')
logging.info('Script finished.')
print('Script finished.')
