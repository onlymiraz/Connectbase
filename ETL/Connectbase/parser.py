import os
import pandas as pd
import pyodbc
import socket
import subprocess

# Get the server name dynamically
server_name = socket.gethostname()

# Database connection configuration
conn_str = (
    r'DRIVER={ODBC Driver 17 for SQL Server};'
    rf'SERVER={server_name};'
    r'DATABASE=your_database_name;'
    r'Trusted_Connection=yes;'
)

# File paths configuration
file_paths = [
    os.path.join(os.getcwd(), 'CB_FRONTIER_DEMAND_ENGINE_ACTIVITIES_750.csv'),
    os.path.join(os.getcwd(), 'CB_FRONTIER_DEMAND_ENGINE_ACTIVITIES_819.csv')
]


def truncate_table(cursor, table_name):
    cursor.execute(f"TRUNCATE TABLE {table_name}")
    cursor.commit()


def bulk_insert_data(cursor, file_path, table_name):
    df = pd.read_csv(file_path, delimiter=',', skiprows=1)
    data = df.values.tolist()

    cursor.fast_executemany = True
    cursor.executemany(
        f"""
        INSERT INTO {table_name} (
            ID, LOGIN_ID, ROUTE_NAME, REQUESTING_COMPANY, ADDRESS,
            CITY, STATE, ZIP, COUNTY, COUNTRY, USER_COMPANY,
            TARGET_COMPANY_ID, TARGET_COMPANY, REQUEST_DATE, RESULT,
            SERVICENAME, ERROR_MESSAGE
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        data
    )
    cursor.commit()


def update_country_column(cursor, table_name):
    # List of characters to remove from the COUNTRY column
    characters_to_remove = [' | ', '|', '"']
    for char in characters_to_remove:
        cursor.execute(f"UPDATE {table_name} SET COUNTRY = REPLACE(COUNTRY, '{char}', '')")
        cursor.commit()


def process_files():
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    try:
        for file_path in file_paths:
            # Extract the unique identifier from the filename
            file_name = os.path.basename(file_path)
            unique_id = file_name.split('_')[-1].split('.')[0]
            table_name = f"LZ.SFTP_CB_DE_{unique_id}"

            print(f"Truncating table {table_name}...")
            truncate_table(cursor, table_name)

            print(f"Bulk inserting data from {file_path} into {table_name}...")
            bulk_insert_data(cursor, file_path, table_name)

            print(f"Updating COUNTRY column in {table_name}...")
            update_country_column(cursor, table_name)

        print("Process completed successfully.")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()


def create_and_run_batch_file():
    # Define the path where the batch file will be created
    batch_file_path = os.path.join(os.getcwd(), 'run_parser.bat')

    # Define the content of the batch file
    batch_content = '''@echo off
python "%~dp0parser.py"
pause
'''

    # Create the batch file
    with open(batch_file_path, 'w') as batch_file:
        batch_file.write(batch_content)

    print(f"Batch file created at: {batch_file_path}")

    # Run the batch file
    subprocess.call([batch_file_path])


if __name__ == "__main__":
    # Process the CSV files
    process_files()

    # Create and run the batch file
    create_and_run_batch_file()