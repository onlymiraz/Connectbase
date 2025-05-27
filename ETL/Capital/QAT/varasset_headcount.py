import pyodbc
import logging
import smtplib
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Define connection strings for Windows Authentication
source_conn_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=SQLINFWWDVP07\\DCPRD07;"
    "DATABASE=Varasset;"
    "Trusted_Connection=yes;"
)

destination_conn_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=WADINFWWDDV01;"
    "DATABASE=WAD_STG_Capital;"
    "Trusted_Connection=yes;"
)

# Function to send email
def send_email(subject, body):
    sender_email = "WAD@ftr.com"
    receiver_email = "DL_WAD_Logs@ftr.com"
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'plain'))
    try:
        server = smtplib.SMTP('MailRelay.corp.pvt')  # Use the correct SMTP server for your environment
        server.sendmail(sender_email, receiver_email, msg.as_string())
        server.quit()
        logging.info("Email sent successfully.")
    except Exception as e:
        logging.error(f"Failed to send email: {e}")

# Function to log error in database
def log_error(event_name, event_start, event_end, source, dest, issue, event_type):
    try:
        conn = pyodbc.connect(destination_conn_str)
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO LOG.ETL_ERROR (EVENTNAME, EVENTSTART, EVENTEND, SOURCE, DEST, ISSUE, EVENTTYPE)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (event_name, event_start, event_end, source, dest, issue, event_type))
        conn.commit()
        conn.close()
        logging.info("Error logged successfully in the database.")
    except pyodbc.Error as e:
        logging.error(f"Failed to log error in database: {e}")

# Function to test connection
def test_connection(conn_str):
    try:
        conn = pyodbc.connect(conn_str)
        conn.close()
        logging.info("Connection successful.")
        return True
    except pyodbc.Error as e:
        logging.error(f"Connection failed: {e}")
        return False

# Function to fetch row count from a table
def fetch_row_count(conn_str, table_schema, table_name):
    query = f"SELECT COUNT(*) FROM [{table_schema}].[{table_name}]"
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        cursor.execute(query)
        row_count = cursor.fetchone()[0]
        conn.close()
        return row_count
    except pyodbc.Error as e:
        logging.error(f"Failed to fetch row count: {e}")
        return None

# Function to fetch column count from a table
def fetch_column_count(conn_str, table_schema, table_name):
    query = (
        f"SELECT COUNT(*) "
        f"FROM INFORMATION_SCHEMA.COLUMNS "
        f"WHERE TABLE_SCHEMA = '{table_schema}' AND TABLE_NAME = '{table_name}'"
    )
    try:
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        cursor.execute(query)
        column_count = cursor.fetchone()[0]
        conn.close()
        return column_count
    except pyodbc.Error as e:
        logging.error(f"Failed to fetch column count: {e}")
        return None

# Function to perform headcount check
def headcount_check():
    try:
        source_table_schema = "ext"
        source_table_name = "FPStatus"
        destination_table_schema = "LZ"
        destination_table_name = "Varasset_FPStatus"

        # Fetch row and column counts from source and destination
        source_row_count = fetch_row_count(source_conn_str, source_table_schema, source_table_name)
        destination_row_count = fetch_row_count(destination_conn_str, destination_table_schema, destination_table_name)

        source_column_count = fetch_column_count(source_conn_str, source_table_schema, source_table_name)
        destination_column_count = fetch_column_count(destination_conn_str, destination_table_schema, destination_table_name)

        assert source_row_count is not None, "Source row count fetch failed."
        assert destination_row_count is not None, "Destination row count fetch failed."
        assert source_column_count is not None, "Source column count fetch failed."
        assert destination_column_count is not None, "Destination column count fetch failed."

        logging.info(f"Source - Rows: {source_row_count}, Columns: {source_column_count}")
        logging.info(f"Destination - Rows: {destination_row_count}, Columns: {destination_column_count}")

        # Match row count
        if source_row_count != destination_row_count:
            issue = f"Row count mismatch during Varasset ETL: Source={source_row_count}, Destination={destination_row_count}"
            log_error("Row Count Mismatch", start_time, datetime.now(), source_table_name, destination_table_name, issue, "Mismatch")
            send_email("Row Count Mismatch", issue)
            raise AssertionError(issue)

        logging.info("Row count matches between source and destination.")

        # Match column count
        if source_column_count != destination_column_count:
            issue = f"Column count mismatch during Varasset ETL: Source={source_column_count}, Destination={destination_column_count}"
            log_error("Column Count Mismatch", start_time, datetime.now(), source_table_name, destination_table_name, issue, "Mismatch")
            send_email("Column Count Mismatch", issue)
            raise AssertionError(issue)

        logging.info("Column count matches between source and destination.")

    except AssertionError as e:
        logging.error(f"Headcount check failed: {e}")

# Main function
def main():
    global start_time
    start_time = datetime.now()

    # Test connections
    if not test_connection(source_conn_str):
        logging.error("Exiting due to failed source database connection.")
        return

    if not test_connection(destination_conn_str):
        logging.error("Exiting due to failed destination database connection.")
        return

    # Perform headcount check between source and destination tables
    headcount_check()

    end_time = datetime.now()
    logging.info(f"Headcount check completed in: {end_time - start_time}")

if __name__ == "__main__":
    main()
