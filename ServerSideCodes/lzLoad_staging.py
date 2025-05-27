import re
import sys
import os
import shutil
from os.path import exists
import pyodbc
import logging
import csv
 

#-- static variables
server="_______"
loadDB="_______"
dataSourcePath="D:\DataDump"
dataCopyPath="D:\DataDump\LoadLZ"
tablePrefix="[" + loadDB + "].[dbo]."
webappPrefix="[" + loadDB + "].[webapp]."

#-- Table Names
loadTables = ['APPROVED', 'BUDGETLINE', 'CIACFORFF', 'FFFIELDS', 'FUTUREYEAR', 'SPREAD', 'ESTIMATE', 'WEBAPPGA']

cols = {
    'FUTUREYEAR': [2, 3, 9],
    'ESTIMATE': [1, 11, 15, 20]
}

#-- FTTH.LZ load file names
lzFiles = {
    'APPROVED': ['FFAPROJX'],
    'BUDGETLINE': ['FFBDGTLN20'],
    'CIACFORFF': ['FFCIACOPNX'],
    'FFFIELDS': ['FFFIELDSX'],
    'FUTUREYEAR': ['JMFPRJBGYR'],
    'SPREAD': ['FFSPREAD20'],
    'WEBAPPGA': ['GROSSADDS'],
    'ESTIMATE': ['JFESTPJYR']
}

# Create and configure logger
#logging.basicConfig(filename="D:\DataDump\LoadLZ\lzLoad.log",
#                    format='%(asctime)s %(message)s',
#                    filemode='w')
logging.basicConfig(filename="D:\Logs\lzLoad.log",
                    format='%(asctime)s %(message)s',
                    filemode='w')
 
# Creating the logger object
logger = logging.getLogger()
 
# Setting the threshold of logger to DEBUG
logger.setLevel(logging.DEBUG)

#-----------------------------
#-- logIT log messages and 
#-- print to screen
#-----------------------------
def logIT(logMsg):
   print(logMsg)
   logger.info(logMsg)

#-----------------------------
#-- Connect to Database
#-----------------------------
def dbConn(iServer, iDB):

    logIT("[dbConn] Server:" + iServer + " Database:" + iDB)

    try:
       conn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;DATABASE=%s;Trusted_Connection=yes;' % (iServer, iDB))
    except pyodbc.Error as ex:
          sqlstate = ex.args[1]
          logIT("ERROR: " + sqlstate)

    return conn

#-----------------------------
#-- Run SQL command
#-----------------------------
def runSQL(iconn,isql):

    select=0
    select_count=0

    logIT ("[runSQL] " + isql)

    if isql.startswith('SELECT'):
       select=1
    if isql.startswith('SELECT COUNT'):
       select_count=1

    cursor=iconn.cursor()

    try:
        retVal=cursor.execute(isql)
        if select < 1:
           iconn.commit()
    except:
       logIT('ERROR: {}. {}, line: {}'.format(sys.exc_info()[0],
                                              sys.exc_info()[1],
                                              sys.exc_info()[2].tb_lineno))
    if select_count > 0:
       row = retVal.fetchone() 
       if isinstance(row[0],int):
          retNum=int(row[0])
    else:
       retNum=retVal.rowcount

    return(retNum)

    cursor.close()


#-----------------
#----- MAIN ------
#-----------------

for lz in loadTables:
   # set the full path to the load file
   loadFile = dataSourcePath + "\\" + lzFiles[lz][0] + ".csv"
   logIT ("loadFile=" + loadFile)

   #-- Check if the lz load file exists
   file_exists = exists(loadFile)
   if not file_exists:
       logIT ("ERROR: " + loadFile + " does not exist")
       sys.exit(1)

   #-- We want to make a copy of the load file to a separate directory
   #-- Make sure this directory exists
   dir_exists = os.path.isdir(dataCopyPath) 
   if not dir_exists:
       logIT ("ERROR: " + dataCopyPath + " does not exist")
       sys.exit(1)

   #-- full name of file we are copying to
   copyFile = dataCopyPath + "\\" + lzFiles[lz][0] + ".csv"
   logIT ("About to copy " + loadFile + " to " + copyFile)

   #-- copy the load file to a separate directory
   try:
       shutil.copy(loadFile, copyFile)
   except OSError:
       logIT ("ERROR: Cannot copy " + loadFile + " to " + copyFile)
       sys.exit(1)

   #-- TMP Output filename 
   tmpFile = dataCopyPath + "\\" + lzFiles[lz][0] + "_tmp.csv"

   #-- Open the input file and tmp file and write to tmpfile
   with open(copyFile, encoding='cp437', mode="r", newline='') as icsvFile, open(tmpFile,  encoding='cp437', mode="w", newline='') as ocsvFile:
      csvReader = csv.reader(icsvFile, doublequote=False, delimiter='|', quotechar='"')
      csvWriter = csv.writer(ocsvFile, delimiter='|', doublequote=False, escapechar='\\', quotechar='"', quoting=csv.QUOTE_MINIMAL)
      ilines=0
      if lz == "FUTUREYEAR" or lz == "ESTIMATE":
         newrows = []
         for row in csvReader:
            ilines += 1
            nrow = []
            for col in cols[lz]:
               nrow.append(row[col])
            newrows.append(nrow)
         csvWriter.writerows(newrows)
      else:
         for row in csvReader:
            ilines += 1
            nrow = []
            for col in row:
               nrow.append(col)
            csvWriter.writerow(nrow) 

   #-- Open the output file
   outFile = dataCopyPath + "\\" + lzFiles[lz][0] + "_out.csv"
   fout = open(outFile, encoding="cp437", mode="w")

   #-- Replace some characters in the tmp file and write to out file
   try:
       ftmp = open(tmpFile, encoding="cp437", mode="r")
   except OSError:
       logIT ("ERROR: Cannot open " + tmpFile)
       sys.exit(1)
   else:
       for line in ftmp:
          # Replace the String based on the pattern
          newline1 = line.replace('\\"','"')
          fout.write(newline1)
   fout.close()
   ftmp.close()

   olines=0
   #-- Get number of lines in output file.
   try:
       fout = open(outFile, encoding="cp437", mode="r")
   except OSError:
       logIT ("ERROR: Cannot open " + outFile)
       sys.exit(1)
   else:
       olines=len(fout.readlines())
   fout.close()

   # The number of lines in the output file should be the same as the input file
   # If not, then there was an error
   if ilines != olines:
       logIT ("ERROR: " + outFile + " and " + copyFile + " do not have same number of lines")
       logIT ("       Input File:  " + str(ilines) + " lines" )
       logIT ("       Output File: " + str(olines) + " lines" )
       sys.exit(1)

   conn=dbConn(server, loadDB)

   if lz == "WEBAPPGA":
      lzTbl = webappPrefix + "[GA]"    
   else:
      lzTbl = tablePrefix + "[" + lz + "]"    

   #-- Truncate table
   truncateSQL = 'TRUNCATE TABLE ' + lzTbl
   runSQL(conn,truncateSQL)

   #-- select SQL to count table rows
   selectSQL = 'SELECT COUNT(*) as n FROM ' + lzTbl

   #-- Check that table was trunated - no rows
   trows=0
   trows=runSQL(conn,selectSQL)
   if trows != 0:
       logIT ("ERROR: TRUNCATE TABLE " + lzTbl + " did not work")
       sys.exit(1)
       
   #-- Insert new data into table
   bulkinsertSQL = 'BULK INSERT ' + lzTbl + " FROM '" + outFile + "' WITH (FIELDTERMINATOR='|')"
   runSQL(conn,bulkinsertSQL)

   #-- Get the row count of the table
   trows=0
   trows=runSQL(conn,selectSQL)

   #-- Print the input and output file information
   logIT ("Input File:   " + copyFile + " [" + str(ilines) + "] lines" )
   logIT ("Output File:  " + outFile +  " [" + str(olines) + "] lines" )
   logIT ("Table Rows:   " + lzTbl +  " [" + str(trows) + "] rows" )

   #-- Row count should equal number of lines in input file
   if ilines != trows:
       logIT ("ERROR: " + copyFile + " and " + lzTbl + " do not have same number of lines")
       sys.exit(1)

   conn.close()
   
   logIT ("------------")

logIT ("Success")
sys.exit(0)

