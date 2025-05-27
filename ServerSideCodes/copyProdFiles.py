import sys    
import os
from os.path import exists
import shutil
import logging
import sharedFunctions as s
#import paramiko
from datetime import datetime, timezone

#--
#-- Global Variables
#--
logDir="D:\\Logs"
localDir='D:\\DataDump'
localLoadDir = localDir + "\\LoadLZ"

emailTo = ['DL_WAD_Logs@FTR.com']

emailFrom = 'WAD@FTR.com'

tz_string = datetime.now(timezone.utc).astimezone().tzname()

#--
#-- Files we want to copy
#--
copyFiles = ['FFAPROJX.csv', 'FFBDGTLN20.csv', 'FFCIACOPNX.csv', 'FFFIELDSX.csv', 'JMFPRJBGYR.csv', 'FFSPREAD20.csv', 'GROSSADDS.csv', 'JFESTPJYR.csv', 'FFAUTHDTLX.csv', 'FFAUTHDTLZ.csv','CIACREVX20.csv','EQPSHIPTOF.csv','JFJC05SUMF.csv','JFPOLNSTSF.csv']

#-- For testing
#copyFiles = ['FFAPROJX.csv']

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
   emailSub="[ ERROR ] " + scriptName 
   s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   sys.exit(1)

#-- Check that local load file directory exists
if not os.path.isdir(localLoadDir):
   s.logIT (logger, "ERROR: " + localLoadDir + " does not exist")
   emailSub="[ ERROR ] " + scriptName 
   s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   sys.exit(1)

s.logIT(logger, "--------------------")
s.logIT(logger, "Removing old files from " + localLoadDir)
for file in copyFiles:
   localLoadFile = localLoadDir + "\\" + file

   s.logIT(logger, file)

   if os.path.isfile(localLoadFile):
      os.unlink(localLoadFile)
      #-- make sure it is gone
      if os.path.isfile(localLoadFile):
         s.logIT(logger, "  ERROR: Failed to remove " + localLoadFile)
      else:
         s.logIT(logger, "  Removed " + localLoadFile)

#--
#-- Copy files in D:\DataDump directory to D:\DataDump\LoadLZ
#--
s.logIT(logger, "--------------------")
for file in copyFiles:
   localLoadFile = localLoadDir + "\\" + file  
   localFile = localDir + "\\" + file  

   s.logIT(logger, "Copying " + localFile + " to " + localLoadFile)
   if os.path.isfile(localFile):
      try:
         shutil.copy2(localFile, localLoadFile)
      except shutil.Error:
         s.logIT(logger, "ERROR: copy failed")
   else:
      s.logIT(logger, "ERROR: " + localFile + " does not exist")

   #--
   #-- If file does not exist, log an error
   #--
   if not os.path.isfile(localLoadFile):
      s.logIT(logger, "ERROR: " + localLoadFile + " does NOT exist")

#--
#-- Look for ERROR in the log file
#--
if s.stringInFile(logger,"ERROR",logFile):
   emailSub="[ ERROR ] " + scriptName 
else:
   emailSub="[ SUCCESS ] " + scriptName 

s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   
s.logIT(logger,"Finished " + scriptName)
