import os
import pandas as pd
import pyodbc

# SQL Server Connection Configuration
server = 'WADINFWWDDV01'
database = 'Playground'
username = 'tsql_wad'
password = '1QwKdb79!'
driver = '{SQL Server}'

# Local Folder Path
folder_path = '\\Wadinfwwddv01\lz'

# Create a connection string
connection_string = f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}'

# Connect to SQL Server
conn = pyodbc.connect(connection_string)
cursor = conn.cursor()

# Function to create DDL for a table
def create_table_ddl(df, table_name):
   ddl = f"CREATE TABLE {table_name} (\n"
   for column, dtype in zip(df.columns, df.dtypes):
       # Map pandas data types to SQL Server data types
       sql_type = 'VARCHAR(MAX)' if dtype == 'object' else 'INT'  # Adjust as needed
       ddl += f"    {column} {sql_type},\n"
   ddl = ddl.rstrip(',\n') + '\n)'
   return ddl


# Loop through Excel files in the folder
for filename in os.listdir(folder_path):
    if filename.endswith('.xlsx'):
        excel_file_path = os.path.join(folder_path, filename)

        # Read Excel file into DataFrame
        df = pd.read_excel(excel_file_path, engine='openpyxl')

        # Extract table name from file name (assuming file name is TableName.xlsx)
        table_name = os.path.splitext(filename)[0]

        # Create DDL for the table
        ddl = create_table_ddl(df, table_name)

        # Execute DDL on SQL Server
        cursor.execute(ddl)

        # Ingest data into SQL Server
        df.to_sql(name=table_name, con=conn, index=False, if_exists='replace')

# Commit changes and close connection
conn.commit()
conn.close()
