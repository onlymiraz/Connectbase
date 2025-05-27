import teradatasql
import pyodbc
import pandas as pd
import json
import logging
import time
import os
import socket
from datetime import timedelta

# Set up logging
logging.basicConfig(filename='etl_process.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Retrieve passwords securely from environment variables
teradata_pw = 'Welcome24'

# Mapping of nodes to databases
node_db_mapping = {
    'WADINFWWAPV02': 'WAD_PRD_Integration',
    'WADINFWWDDV01': 'WAD_STG_Integration'
    # Add other nodes and their corresponding databases here
}

# Get the current node
current_node = socket.gethostname().upper()
database_name = node_db_mapping.get(current_node, 'WAD_STG_02')  # Default to 'Playground' if node not found

# Set up connection strings and connect to databases
try:
    # Teradata connection
    teradata_conn_str = json.dumps(
        {'host': '10.209.129.144', 'user': 's_WAD3', 'password': teradata_pw, 'logmech': 'TD2'})
    teradata_conn = teradatasql.connect(teradata_conn_str)
    teradata_cursor = teradata_conn.cursor()
    logging.info("Connected to Teradata database.")

    # SQL Server connection
    sql_server_conn_str = f'DRIVER={{SQL Server}};SERVER={current_node};DATABASE={database_name};Trusted_Connection=yes;'
    sql_server_conn = pyodbc.connect(sql_server_conn_str)
    sql_server_cursor = sql_server_conn.cursor()
    logging.info(f"Connected to SQL Server database: {database_name} on server: {current_node}.")
except Exception as e:
    logging.error("Error connecting to databases: %s", e)
    raise SystemExit(e)


def load_data_from_teradata_to_sql_server(source_cursor, query, target_cursor, table_name, sql_server_conn):
    try:
        start_time = time.time()
        start_dt = time.strftime("%Y-%m-%d %H:%M:%S")
        logging.info(f"Starting data extraction from Teradata at {start_dt}")

        # Execute the query on Teradata
        source_cursor.execute(query)
        rows = source_cursor.fetchall()
        columns = [desc[0] for desc in source_cursor.description]
        logging.info(f"Data extraction from Teradata completed. Rows fetched: {len(rows)}")

        # Convert the results to a DataFrame and ensure all columns are strings
        df = pd.DataFrame(rows, columns=columns).astype(str)

        # Drop the table if it exists
        logging.info(f"Dropping target table {table_name} if it exists.")
        target_cursor.execute(f"IF OBJECT_ID('{table_name}', 'U') IS NOT NULL DROP TABLE {table_name}")
        sql_server_conn.commit()

        # Create the table schema dynamically with NVARCHAR(MAX) for all columns
        create_table_sql = f"CREATE TABLE {table_name} ("
        for col in df.columns:
            create_table_sql += f"[{col}] NVARCHAR(MAX),"
        create_table_sql = create_table_sql.rstrip(',') + ")"

        logging.info(f"Creating target table {table_name} with NVARCHAR(MAX) columns.")
        target_cursor.execute(create_table_sql)
        sql_server_conn.commit()

        # Insert data into SQL Server table
        columns_str = ", ".join([f"[{col}]" for col in df.columns])
        placeholders = ", ".join(["?" for _ in df.columns])
        insert_sql = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"

        logging.info(f"Inserting data into target table {table_name}.")
        for index, row in df.iterrows():
            target_cursor.execute(insert_sql, tuple(row))

        sql_server_conn.commit()

        end_time = time.time()
        end_dt = time.strftime("%Y-%m-%d %H:%M:%S")
        duration = timedelta(seconds=end_time - start_time)

        logging.info(f"Data loaded successfully into {table_name}.")
        logging.info(f"Data loading started at {start_dt}, ended at {end_dt}, duration: {str(duration)}.")
    except Exception as e:
        logging.error("Error during data loading: %s", e)
        raise


# Read Teradata SQL query from file
script_directory = os.path.dirname(os.path.abspath(__file__))
sql_file_name = 'src_teradata_cabs_mrc_billing.sql'
sql_file_path = os.path.join(script_directory, sql_file_name)

try:
    with open(sql_file_path, 'r') as file:
        teradata_query = file.read()
except Exception as e:
    logging.error("Error reading SQL file: %s", e)
    raise SystemExit(e)

# Determine the table name from the SQL file name
table_name = os.path.splitext(sql_file_name)[0]

# Execute ETL from Teradata
try:
    logging.info("Starting Teradata data extraction and loading into SQL Server.")
    load_data_from_teradata_to_sql_server(teradata_cursor, teradata_query, sql_server_cursor, table_name,
                                          sql_server_conn)
except Exception as e:
    logging.error("Failed Teradata ETL: %s", e)

# Close all connections
try:
    teradata_conn.close()
    sql_server_conn.close()
    logging.info("Closed all database connections.")
except Exception as e:
    logging.error("Error closing database connections: %s", e)

logging.info("ETL process completed.")
