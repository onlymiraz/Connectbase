# /App/app_AddressBilling/models.py
import pyodbc

def get_sql_server_columns():
    try:
        connection = pyodbc.connect(
            'DRIVER={SQL Server};SERVER=WADINFWWDDV01;DATABASE=Playground;UID=tsql_wad;PWD=1QwKdb79!'
        )
        cursor = connection.cursor()
        cursor.execute("""
            SELECT 
                COLUMN_NAME,
                IS_NULLABLE
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = 'UI_LZ' 
            AND TABLE_SCHEMA = 'addressbilling' 
            AND COLUMN_NAME NOT IN ('ID', 'DtmStamp', 'ingestion_timestamp')
        """)
        sql_columns = {row.COLUMN_NAME: row.IS_NULLABLE for row in cursor.fetchall()}
        connection.close()
        return sql_columns
    except Exception as e:
        print(f"An error occurred: {e}")
        return None
