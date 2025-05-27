import pyodbc
import pandas as pd
import logging
from datetime import datetime
import time

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

# Step 1: Extract data from source table using chunking
def extract_data(chunk_size=20_000):
    try:
        source_conn = pyodbc.connect(source_conn_str)
        
        # Get the total row count
        count_query = "SELECT COUNT(*) FROM [ext].[FPStatus]"
        total_rows = pd.read_sql(count_query, source_conn).iloc[0, 0]
        total_chunks = (total_rows + chunk_size - 1) // chunk_size
        
        logging.info(f"Total rows: {total_rows}, Total chunks: {total_chunks}")

        query = "SELECT * FROM [ext].[FPStatus]"
        df_list = []
        chunk_count = 0
        for chunk in pd.read_sql(query, source_conn, chunksize=chunk_size):
            chunk_count += 1
            df_list.append(chunk)
            logging.info(f"Extracted chunk of size {len(chunk)} ({chunk_count}/{total_chunks})")
        source_conn.close()
        df = pd.concat(df_list, ignore_index=True)
        logging.info(f"Data extracted successfully from source. Total chunks: {chunk_count}")
        return df
    except pyodbc.Error as e:
        logging.error(f"Failed to extract data: {e}")
        exit(1)
        return None


# Step 2: Get source table schema
def get_table_schema():
    try:
        source_conn = pyodbc.connect(source_conn_str)
        cursor = source_conn.cursor()
        query = """
        SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = 'FPStatus'
        """
        cursor.execute(query)
        columns = cursor.fetchall()
        source_conn.close()
        
        schema = []
        for column in columns:
            col_name = column.COLUMN_NAME
            col_type = column.DATA_TYPE
            max_length = column.CHARACTER_MAXIMUM_LENGTH
            if col_type == 'nvarchar' and max_length:
                col_type = f"NVARCHAR({max_length})"
            elif col_type == 'varchar' and max_length:
                col_type = f"VARCHAR({max_length})"
            elif col_type in ['nvarchar', 'varchar'] and not max_length:
                col_type = f"{col_type}(MAX)"
            else:
                col_type = col_type.upper()
            schema.append(f"[{col_name}] {col_type}")

        # Change -1 to MAX
        schema = [s.replace('(-1)', '(MAX)') for s in schema]
        
        return schema
    except pyodbc.Error as e:
        logging.error(f"Failed to retrieve table schema: {e}")
        exit(1)
        return None

# Step 3: Create table in destination database
def create_table(schema):
    if schema is not None:
        try:
            destination_conn = pyodbc.connect(destination_conn_str)
            cursor = destination_conn.cursor()

            # Replace DATETIME with DATETIME2 in schema
            schema = [s.replace('DATETIME', 'DATETIME2') for s in schema]

            # Create table query
            create_table_query = f"""
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Varasset_FPStatus' AND xtype='U')
            BEGIN
                CREATE TABLE LZ.Varasset_FPStatus (
                    {', '.join(schema)}
                )
            END
            """
            
            logging.info(f"Executing create table query:\n{create_table_query}")
            cursor.execute(create_table_query)
            destination_conn.commit()
            cursor.close()
            destination_conn.close()
            logging.info("Table created successfully in destination.")
        except pyodbc.Error as e:
            logging.error(f"Failed to create table: {e}")
            exit(1)

# Step 3.5: Clear destination table before inserting new data
def clear_destination_table():
    try:
        destination_conn = pyodbc.connect(destination_conn_str)
        cursor = destination_conn.cursor()
        delete_query = "DELETE FROM LZ.Varasset_FPStatus"
        logging.info("Clearing destination table.")
        cursor.execute(delete_query)
        destination_conn.commit()
        cursor.close()
        destination_conn.close()
        logging.info("Destination table cleared successfully.")
    except pyodbc.Error as e:
        logging.error(f"Failed to clear destination table: {e}")
        exit(1)

# Function to handle datetime conversion
def handle_datetime2(value):
    if pd.isna(value):
        # Handle NaT and None values
        return None
    if isinstance(value, pd.Timestamp):
        try:
            # Convert to string in the format required by DATETIME2
            converted_value = value.to_pydatetime().strftime('%Y-%m-%d %H:%M:%S')
            logging.debug(f"Converted datetime")
            return converted_value
        except Exception as e:
            logging.error(f"Date conversion error: {e}")
            return None
    return value

# Step 4: Insert data into destination table using bulk insert
def insert_data(df, batch_size=20_000):
    if df is not None:
        try:
            destination_conn = pyodbc.connect(destination_conn_str)
            cursor = destination_conn.cursor()

            # Dynamically create the insert query
            columns = ", ".join(f"[{col}]" for col in df.columns)
            placeholders = ", ".join("?" for _ in df.columns)
            insert_query = f"""
            INSERT INTO LZ.Varasset_FPStatus ({columns})
            VALUES ({placeholders})
            """
            
            logging.info(f"Inserting {len(df)} rows into destination table in batches of {batch_size}.")
            
            # Insert in batches
            for start in range(0, len(df), batch_size):
                batch_df = df[start:start + batch_size].applymap(handle_datetime2)
                batch_start_time = time.time()
                cursor.executemany(insert_query, batch_df.values.tolist())
                batch_time = time.time() - batch_start_time
                logging.info(f"Inserted batch starting at row {start} of size {len(batch_df)} in {batch_time:.2f} seconds")
            
            destination_conn.commit()
            logging.info("Data inserted successfully into destination.")
        except pyodbc.Error as e:
            logging.error(f"Failed to insert data: {e}")
            exit(1)
        finally:
            cursor.close()
            destination_conn.close()

# Main function
def main():
    start_time = datetime.now()

    # Test connections
    if not test_connection(source_conn_str):
        logging.error("Exiting due to failed source database connection.")
        exit(1)

    if not test_connection(destination_conn_str):
        logging.error("Exiting due to failed destination database connection.")
        exit(1)

    # Step 1: Extract data from source table
    df = extract_data()

    # Step 2: Get source table schema
    schema = get_table_schema()

    # Step 3: Create table in destination database
    create_table(schema)

    # Step 3.5: Clear destination table before inserting new data
    clear_destination_table()

    # Step 4: Insert data into destination table
    insert_data(df)

    logging.info("ETL process completed successfully.")

    # Print time in hours and minutes
    total_time = datetime.now() - start_time
    hours, remainder = divmod(total_time.total_seconds(), 3600)
    minutes, seconds = divmod(remainder, 60)
    logging.info(f"The ETL process took {int(hours)} hours and {int(minutes)} minutes to complete.")

    exit(0)

if __name__ == "__main__":
    main()
