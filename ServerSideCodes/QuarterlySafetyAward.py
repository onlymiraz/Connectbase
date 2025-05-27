import time, pyodbc, pandas as pd
from datetime import datetime

server = '_______'
database = '_______'
driver = '{SQL Server}'

cnxn = pyodbc.connect('DRIVER=' + driver + ';SERVER=' + server + ';DATABASE=' + database + ';Trusted_Connection=yes;')
cursor = cnxn.cursor()

currDate = datetime.strptime("10-01-2023", '%m-%d-%Y').date()
currYear = str(datetime.now().year)

last_quarter_start_month = ((currDate.month - 4) // 3) * 3 + 1
last_quarter_end_month = last_quarter_start_month + 2

quarter_start_date = pd.to_datetime(pd.datetime(int(currYear), last_quarter_start_month, 1)).strftime('%m-%d-%Y')
quarter_end_date = (pd.to_datetime(quarter_start_date, format='%m-%d-%Y') + pd.tseries.offsets.QuarterEnd(startingMonth=last_quarter_end_month)).date().strftime('%m-%d-%Y')

params = (quarter_start_date,quarter_end_date)
query = "EXEC [Schema].[StoreProc] ?, ?"
cursor.execute(query, params)
cursor.commit()
cursor.close()
