import cx_Oracle
import teradatasql
import pyodbc
import os
import json
import logging

# Set up logging
logging.basicConfig(filename='etl_process.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Retrieve passwords securely from environment variables
oracle_pw = 'asap'
teradata_pw = 'Welcome24'

# Set up connection strings and connect to databases
try:
    # Oracle connection
    dsn = cx_Oracle.makedsn("asapprdstdby.corp.pvt", 1521, service_name="asapprd")
    oracle_conn = cx_Oracle.connect(user="ASAP", password=oracle_pw, dsn=dsn)
    oracle_cursor = oracle_conn.cursor()
    logging.info("Connected to Oracle database.")

    # Teradata connection
    teradata_conn_str = json.dumps(
        {'host': '10.209.129.144', 'user': 's_WAD3', 'password': teradata_pw, 'logmech': 'TD2'})
    teradata_conn = teradatasql.connect(teradata_conn_str)
    teradata_cursor = teradata_conn.cursor()
    logging.info("Connected to Teradata database.")

    # SQL Server connection
    sql_server_conn_str = 'DRIVER={SQL Server};SERVER=WADINFWWAPV02;DATABASE=WAD_PRD_02;Trusted_Connection=yes;'
    sql_server_conn = pyodbc.connect(sql_server_conn_str)
    sql_server_cursor = sql_server_conn.cursor()
    logging.info("Connected to SQL Server database.")
except Exception as e:
    logging.error("Error connecting to databases: %s", e)
    raise SystemExit(e)

# Truncate target tables before loading new data
try:
    sql_server_cursor.execute("TRUNCATE TABLE LZ.TBL_Notes")
    sql_server_cursor.execute("TRUNCATE TABLE LZ.TBL_MCL")
    sql_server_conn.commit()
    logging.info("Target tables truncated.")
except Exception as e:
    logging.error("Failed to truncate target tables: %s", e)
    raise


# Define the ETL process function
def load_data(source_cursor, query, target_cursor, insert_query):
    try:
        source_cursor.execute(query)
        rows = source_cursor.fetchall()
        for row in rows:
            target_cursor.execute(insert_query, row)
        sql_server_conn.commit()
        logging.info("Data loaded successfully from source to target.")
    except Exception as e:
        logging.error("Error during data loading: %s", e)
        raise


# Execute ETL from Oracle
try:
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
    logging.info("Starting Oracle data extraction and loading into SQL Server.")
    load_data(oracle_cursor, oracle_query, sql_server_cursor, oracle_insert_query)
except Exception as e:
    logging.error("Failed Oracle ETL: %s", e)

# Execute ETL from Teradata
try:
    teradata_query = "SELECT DISTINCT stn FROM USER_WORK.CM_LSPBANM"
    teradata_insert_query = "INSERT INTO LZ.TBL_MCL (stn) VALUES (?)"
    logging.info("Starting Teradata data extraction and loading into SQL Server.")
    load_data(teradata_cursor, teradata_query, sql_server_cursor, teradata_insert_query)
except Exception as e:
    logging.error("Failed Teradata ETL: %s", e)

# Close all connections
try:
    oracle_conn.close()
    teradata_conn.close()
    sql_server_conn.close()
    logging.info("Closed all database connections.")
except Exception as e:
    logging.error("Error closing database connections: %s", e)

logging.info("ETL process completed.")
