import os
import pandas as pd
import pyodbc

# Load environment variables
server = os.getenv('SQL_SERVER')  # e.g., 'localhost\SQLEXPRESS'
database = os.getenv('SQL_DATABASE')  # e.g., 'TestDB'
username = os.getenv('SQL_USERNAME')  # e.g., 'sa'
password = os.getenv('SQL_PASSWORD')  # e.g., 'your_password'
driver = '{ODBC Driver 17 for SQL Server}'

# Establish the connection
conn = pyodbc.connect(
    f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}'
)
cursor = conn.cursor()

# Define the table creation SQL statement
create_table_query = """
CREATE TABLE TelecomData (
    QuoteDate DATE,
    AgentCompany VARCHAR(255),
    CCNA_X VARCHAR(255),
    ClientCompany VARCHAR(255),
    ProductType VARCHAR(255),
    ServiceType VARCHAR(255),
    Terms INT,
    Address VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(2),
    Zip VARCHAR(10),
    RFQNumber VARCHAR(20),
    ServiceStatus VARCHAR(50)
);
"""

# Execute the table creation query
cursor.execute(create_table_query)
conn.commit()

# Load the CSV data into a DataFrame
csv_file_path = 'path_to_your_csv_file.csv'  # e.g., 'C:\\path\\to\\your\\paste.txt'
df = pd.read_csv(csv_file_path)

# Insert data into the table
insert_query = """
INSERT INTO TelecomData (
    QuoteDate, AgentCompany, CCNA_X, ClientCompany, ProductType, ServiceType, Terms, Address, City, State, Zip, RFQNumber, ServiceStatus
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"""

# Convert the DataFrame to a list of tuples
data = [tuple(row) for row in df.itertuples(index=False, name=None)]

# Execute the insert query for each row
cursor.executemany(insert_query, data)
conn.commit()

# Close the connection
cursor.close()
conn.close()