"""
import sys
import shutil

files=['GLEXPENSE.csv','PJEXPENSE.csv']
src='\\\\WADINFWWDDV01\\DataDump\\'
dst='d:\\DataDump\\'



shutil.copy2('\\\\WADINFWWAPV02\\DataDump\\GLEXPENSE.csv', 'd:\\DataDump\\GLEXPENSE.csv')
print("Copied files successfully.")
"""
import glob
import shutil
import sys
import os

emailTo = ['DL_WAD_Logs@FTR.com']
emailFrom = 'WAD@FTR.com'
files = glob.glob('\\\\WADINFWWDDV01\\DataDump\\*.csv')
destination=(r'd:\\DataDump\\')

for file_path in files:
    #print file_path()
    shutil.copy(file_path, destination)
    print(file_path+' copied successfully!')

sys.exit()
