import cx_Oracle
import teradatasql
import pyodbc
import os
import json

# Environment variables for secure password retrieval
oracle_pw = 'asap'  # Make sure to set this environment variable
teradata_pw = 'Welcome24'  # Using directly for demonstration; use secure storage in production

# Create a DSN (Data Source Name) for Oracle
dsn = cx_Oracle.makedsn("asapprdstdby.corp.pvt", 1521, service_name="asapprd")
oracle_conn_str = cx_Oracle.connect(user="ASAP", password=oracle_pw, dsn=dsn)

# Connection strings
teradata_conn_str = json.dumps({
    'host': '10.209.129.144',
    'user': 's_WAD3',
    'password': teradata_pw,
    'logmech': 'TD2'
})
sql_server_conn_str = 'DRIVER={SQL Server};SERVER=WADINFWWAPV02;DATABASE=WAD_PRD_02;Trusted_Connection=yes;'

# Establish connections
oracle_conn = cx_Oracle.connect(user="ASAP", password=oracle_pw, dsn=dsn)
oracle_cursor = oracle_conn.cursor()

teradata_conn = teradatasql.connect(teradata_conn_str)
teradata_cursor = teradata_conn.cursor()

sql_server_conn = pyodbc.connect(sql_server_conn_str)
sql_server_cursor = sql_server_conn.cursor()

# Oracle query and table mapping
oracle_query = """
SELECT
    CAST(DOCUMENT_NUMBER AS VARCHAR(15)) AS DOC_NUMBER,
    CAST(NOTES_ID AS VARCHAR(15)) AS NOTES_ID,
    CAST(NOTE_TEXT AS VARCHAR(500)) AS NOTE_TEXT,
    CAST(USER_ID AS VARCHAR(15)) AS USER_ID,
    CAST(TO_CHAR(LAST_MODIFIED_DATE, 'YYYYMMDD') AS VARCHAR(8)) AS LAST_MODIFIED_DATE
FROM ASAP.NOTES
WHERE EXTRACT(YEAR FROM DATE_ENTERED) >= 2024
"""
oracle_insert_query = "INSERT INTO LZ.TBL_Notes (DOC_NUMBER, NOTES_ID, NOTE_TEXT, USER_ID, LAST_MODIFIED_DATE) VALUES (?, ?, ?, ?, ?)"

# Teradata query and table mapping
teradata_query = "SELECT DISTINCT stn FROM USER_WORK.CM_LSPBANM"
teradata_insert_query = "INSERT INTO LZ.TBL_MCL (stn) VALUES (?)"

# Function to load data
def load_data(source_cursor, query, target_cursor, insert_query):
    source_cursor.execute(query)
    rows = source_cursor.fetchall()
    for row in rows:
        target_cursor.execute(insert_query, row)
    sql_server_conn.commit()

# Load data from Oracle to SQL Server
load_data(oracle_cursor, oracle_query, sql_server_cursor, oracle_insert_query)

# Load data from Teradata to SQL Server
load_data(teradata_cursor, teradata_query, sql_server_cursor, teradata_insert_query)

# Close all connections
oracle_conn.close()
teradata_conn.close()
sql_server_conn.close()

print("ETL Process completed successfully!")
