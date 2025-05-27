# your_script.py

import pandas as pd
import pyodbc
from cryptography.fernet import Fernet
from office365.runtime.auth.authentication_context import AuthenticationContext
from office365.sharepoint.client_context import ClientContext

def encrypt_password(password, key):
    cipher_suite = Fernet(key)
    cipher_text = cipher_suite.encrypt(password.encode())
    return cipher_text

def decrypt_password(cipher_text, key):
    cipher_suite = Fernet(key)
    decrypted_password = cipher_suite.decrypt(cipher_text).decode()
    return decrypted_password

# Read configuration from file
config = configparser.ConfigParser()
config.read('config.ini')

# SharePoint configuration
sharepoint_url = config['SharePoint']['url']
sharepoint_username = config['SharePoint']['username']
encrypted_sharepoint_password = config['SharePoint']['password']

# SQL Server configuration
server = config['SQLServer']['server']
database = config['SQLServer']['database']
username = config['SQLServer']['username']
encrypted_sql_password = config['SQLServer']['password']

# Encryption configuration
key = config['Encryption']['key']

# Decrypt passwords
sharepoint_password = decrypt_password(encrypted_sharepoint_password, key)
sql_password = decrypt_password(encrypted_sql_password, key)

# Establish the SQL Server connection
conn_str = f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={sql_password}'
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Authenticate and connect to SharePoint
ctx_auth = AuthenticationContext(url=sharepoint_url)
ctx_auth.acquire_token_for_user(sharepoint_username, sharepoint_password)
ctx = ClientContext(sharepoint_url, ctx_auth)

# Continue with the rest of your script...
# Download Excel file from SharePoint, read into DataFrame, and ingest into SQL Server

# Commit changes and close the connection
conn.commit()
conn.close()

print(f'Data from SharePoint Excel file successfully ingested into SQL Server table: {table_name}')
