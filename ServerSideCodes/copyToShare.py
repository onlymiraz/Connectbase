import sys    
import os
from os.path import exists
import shutil
import logging
import sharedFunctions as s

#--
#-- Global Variables
#--
logDir="D:\\Logs"
networkDrive = "B:"
networkDir = networkDrive + "\\Writers"
localDir='D:\\DataDump\\LoadLZ'

emailTo = ['DL_WAD_Logs@ftr.com']

emailFrom = 'WAD@ftr.com'

pwMapScript="D:\\Scripts\\mapShareDrive.ps1"

#-- Files we want to copy

copyFiles = ['FFAPROJX_share.xlsx', 'FFBDGTLN20_share.xlsx', 'FFCIACOPNX_share.xlsx', 'FFFIELDSX_share.xlsx', 'JMFPRJBGYR_share.xlsx', 'FFSPREAD20_share.xlsx', 'GROSSADDS_share.xlsx', 'JFESTPJYR_share.xlsx', 'FFAUTHDTLX_share.xlsx', 'FFAUTHDTLZ_share.xlsx','CIACREVX20_share.xlsx','Authorized_Condensed.xlsx']

#-- For testing
#copyFiles = ['FFTEST1.csv', 'FFTEST2.csv']

#--
#-- Get this script' basename to use for the log file
#--
scriptName = os.path.basename(sys.argv[0])
scriptBase = s.getBasename(scriptName)

#--
#-- Initialize log file
#--
logFile=logDir + "\\" + scriptBase + ".log"
logger=s.initLogger(logFile)

#------------------------------------------------------------------------------
#-- MAIN
#------------------------------------------------------------------------------
s.logIT(logger,"Starting " + scriptName)

#-- Check that local file directory exists
if not os.path.isdir(localDir):
   s.logIT (logger, "ERROR: " + localDir + " does not exist")
   s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   sys.exit(1)

#--
#-- Map Capital Management Network Drive
#--
s.logIT (logger, "--------------------")
s.logIT (logger, "Mapping Capital Management Network Drive")

if not os.path.isfile(pwMapScript):
   s.logIT(logger,"ERROR: Cannot find " + psMapScript)
   emailSub="[ ERROR ] " + scriptName 
   s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   sys.exit(1)

if not s.mapDriveCM(logger,pwMapScript):
   s.logIT(logger,"ERROR: Unable to map Capital Management Drive")
   emailSub="[ ERROR ] " + scriptName 
   s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   sys.exit(1)

#--
#-- Check that Captital Management Drive is mounted
#--
if not os.path.ismount(networkDrive):
   s.logIT(logger, "ERROR: " + networkDrive + " is not mounted")
   emailSub="[ ERROR ] " + scriptName 
   s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   sys.exit(1)

#--
#-- Make sure the Network Drive Directory Exists
#-- If not, try creating it
#--
if not s.createDir(logger,networkDir):
   s.logIT(logger, "ERROR: " + networkDir + " does not exist")
   emailSub="[ ERROR ] " + scriptName 
   s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   sys.exit(1)

#--
#-- Copy files to the Network Drive Directory (Queries)
#--
s.logIT (logger, "--------------------")
s.logIT (logger, "Copying files to Network Drive")

for file in copyFiles:

   localFile = localDir + "\\" + file  
   remoteFile = networkDir + "\\" + file

   s.logIT (logger, file)

   if os.path.isfile(remoteFile):
      s.logIT(logger, "   Removing old " + remoteFile)
      os.unlink(remoteFile)
      #-- make sure it is gone
      if os.path.isfile(remoteFile):
         s.logIT(logger, "   ERROR: Failed to remove " + remoteFile)

   s.logIT (logger, "   Copying " + localFile + " to " + remoteFile)

   if not os.path.isfile(localFile):
      s.logIT (logger, "   ERROR: " + localFile + " does not exist")
   else:
      #-- copy the file to the Network Drive
      try:
          shutil.copy2(localFile, remoteFile)
      except shutil.Error:
          s.logIT (logger, "   ERROR: copying file" )

      if not os.path.isfile(remoteFile):
         s.logIT(logger, "   ERROR: " + remoteFile + " does not exist")

   s.logIT (logger, " ")

#--
#-- Look for ERROR in the log file
#--
if s.stringInFile(logger,"ERROR",logFile):
   emailSub="[ ERROR ] " + scriptName 
else:
   emailSub="[ SUCCESS ] " + scriptName 

s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   
s.logIT(logger,"Finished " + scriptName)
