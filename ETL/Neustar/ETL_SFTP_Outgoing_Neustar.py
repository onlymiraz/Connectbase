import sys
import pandas as pd
import shutil
import os
from sqlalchemy import create_engine
from datetime import datetime
import glob

# Mapping for server names to database names
server_name = os.environ.get('COMPUTERNAME', 'WADINFWWDDV01')  # dynamically get current server node
db_mapping = {
    'WADINFWWAPV02': 'WAD_PRD_02',
    'WADINFWWDDV01': 'WAD_STG_02'
}

# Dynamically determine database based on the current server node
db_name = db_mapping.get(server_name, 'WAD_STG_ScratchPad')  # fallback to default if not found

# Create an SQLAlchemy engine for the connection
engine = create_engine(f'mssql+pyodbc://{server_name}/{db_name}?driver=SQL+Server+Native+Client+11.0&trusted_connection=yes')

# Updated SQL query
script = """
SELECT REPORT_RUN_DATE
      ,ENV
      ,ORDNO
      ,WTN
      ,BTN
      ,CUSTNM
      ,PON
      ,ORD_TYPE
      ,CCNA
      ,SERV_TYPE
      ,STAGE
      ,SO_ACT_COMP_DT
  FROM dbo.NEUSTAR_ORDERS_V
"""

# Execute the query using SQLAlchemy engine
df = pd.read_sql_query(script, engine)

# Define file path as the same directory where the Python script is located
dump_path = os.path.dirname(os.path.realpath(__file__))  # Dynamically get the script's directory

current_date = datetime.now().strftime("%m%d%y")

file_name = f'NEUSTAR_ORDERS_V_{current_date}.xlsx'

#delete old file before writing new one (prevents Pluto from picking up dup files)
files_to_delete = glob.glob(os.path.join(dump_path, 'NEUSTAR_ORDERS_V*.xlsx'))

for file in files_to_delete:
    os.remove(file)
    print(f"Deleted file: {file}")

file_path = os.path.join(dump_path, file_name)
writer = pd.ExcelWriter(file_path)
df.to_excel(writer, sheet_name='NEUSTAR_ORDERS_V', index=False)
writer.close()  

print(f"Completed Writing to Excel at {file_path}")

# Copy the new file to a different location if needed
shutil.copy2(file_path, '\\\\WADINFWWAPV02\\Neustar\\' + file_name)
print("Copied the writer to the destination")
