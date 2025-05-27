
import sys

import pyodbc
import pandas as pd
import shutil


serverName="WADINFWWDDV01"
dbName="WAD_STG_ScratchPad"


try:
   cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;DATABASE=%s;Trusted_Connection=yes;' % (serverName, dbName))
except pyodbc.Error as ex:
      sqlstate = ex.args[1]
      print ("ERROR: " + sqlstate)
      sys.exit(1)

script = """
SELECT [ProjectNumber]
      ,[SubprojectNumber]
	  ,CAST(CAST([ProjectNumber] AS nvarchar(10))+CAST([SubprojectNumber] AS nvarchar(1)) AS INT) AS Proj_Sub
      ,[CostCode]
      ,sum([BudgetDollars]) as BudgetDollars
  FROM [dbo].[AUTHORIZED]
  group by [ProjectNumber]
      ,[SubprojectNumber]
      ,[CostCode]
"""

df = pd.read_sql_query(script, cnxn)

writer = pd.ExcelWriter('D:\\DataDump\\LoadLZ\\Authorized_Condensed.xlsx')

df.to_excel(writer, sheet_name='Authorized_Condensed', index=0)
writer.save()

print("Completed Writer")
"""
shutil.copy2('D:\\DataDump\\LoadLZ\\Authorized_Condensed.xlsx', 'Z:\\Capital Management Application\\Queries\\Authorized_Condensed.xlsx')
print("Copied the writer")
"""
