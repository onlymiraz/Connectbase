import cx_Oracle
import os

# Retrieve password from environment variable
oracle_pw = 'asap'

# Ensure the password was retrieved successfully
if oracle_pw is None:
    print("Error: ORACLE_PW_M6 environment variable not set.")
else:
    try:
        # Create a DSN (Data Source Name) string for Oracle
        dsn = cx_Oracle.makedsn("asapprdstdby.corp.pvt", 1521, service_name="asapprd")
        conn = cx_Oracle.connect("ASAP", "asap", dsn)

        print("Successfully connected to Oracle Database")
        cursor = conn.cursor()

        # Check if the table exists and select data
        cursor.execute("""
            SELECT COUNT(*) FROM all_tables 
            WHERE table_name = 'NOTES' AND owner = 'ASAP'
        """)
        if cursor.fetchone()[0] > 0:
            print("Table found. Executing query...")
            cursor.execute("""
                SELECT
                CAST(DOCUMENT_NUMBER AS VARCHAR(15)) AS DOC_NUMBER,
                CAST(NOTES_ID AS VARCHAR(15)) AS NOTES_ID,
                CAST(NOTE_TEXT AS VARCHAR(500)) AS NOTE_TEXT,
                CAST(USER_ID AS VARCHAR(15)) AS USER_ID,
                CAST(TO_CHAR(LAST_MODIFIED_DATE, 'YYYYMMDD') AS VARCHAR(8)) AS LAST_MODIFIED_DATE
                FROM ASAP.NOTES
                WHERE EXTRACT(YEAR FROM DATE_ENTERED) >= 2024
            """)
            for row in cursor:
                print(row)
        else:
            print("Table 'NOTES' does not exist or is not accessible under schema 'ASAP'.")

        cursor.close()
        conn.close()

    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print("Oracle-Error-Code:", error.code)
        print("Oracle-Error-Message:", error.message)
