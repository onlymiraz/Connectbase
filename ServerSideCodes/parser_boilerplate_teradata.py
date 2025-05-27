import os
import pyodbc
import teradatasql

# Teradata Connection Parameters
teradata_server = "your_teradata_server"
teradata_username = "your_teradata_username"
teradata_password_env_var = "TERADATA_PASSWORD"  # Environment variable name for the password
teradata_database = "your_teradata_database"
teradata_table = "your_teradata_table"

# SQL Server Connection Parameters
sql_server = "your_sql_server"
sql_database = "your_sql_database"
sql_username = "your_sql_username"
sql_password_env_var = "SQL_PASSWORD"  # Environment variable name for the password
sql_table = "your_sql_table"

# Fetch credentials from environment variables
teradata_password = os.environ.get(teradata_password_env_var)
sql_password = os.environ.get(sql_password_env_var)

# Connect to Teradata
teradata_conn_str = rf'DRIVER=Teradata;DBCName={teradata_server};UID={teradata_username};PWD={teradata_password};DATABASE={teradata_database}'
teradata_conn = teradatasql.connect(teradata_conn_str)
teradata_cursor = teradata_conn.cursor()

# Get Teradata Table Schema
teradata_cursor.execute(f"SHOW TABLE {teradata_table};")
teradata_columns = teradata_cursor.fetchall()

# Connect to SQL Server
sql_conn_str = rf'DRIVER=SQL Server;SERVER={sql_server};DATABASE={sql_database};UID={sql_username};PWD={sql_password}'
sql_conn = pyodbc.connect(sql_conn_str)
sql_cursor = sql_conn.cursor()

# Create SQL Server Table
create_table_sql = f"CREATE TABLE {sql_table} ({', '.join([f'{col[0]} NVARCHAR(MAX)' for col in teradata_columns])})"
sql_cursor.execute(create_table_sql)
sql_conn.commit()

# ETL - Extract from Teradata and Load into SQL Server
teradata_cursor.execute(f"SELECT * FROM {teradata_table};")
for row in teradata_cursor.fetchall():
    insert_sql = f"INSERT INTO {sql_table} VALUES ({', '.join([rf'\'{str(value)}\'' for value in row])})"
    sql_cursor.execute(insert_sql)
sql_conn.commit()

# Close connections
teradata_cursor.close()
teradata_conn.close()
sql_cursor.close()
sql_conn.close()

print(f"ETL process completed from Teradata table '{teradata_table}' to SQL Server table '{sql_table}'.")
