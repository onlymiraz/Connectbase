import sys    
import os
from os.path import exists
import shutil
import logging
import sharedFunctions as s
import paramiko
from datetime import datetime, timezone

#--
#-- Global Variables
#--
logDir="D:\\Logs"
localDir='D:\\DataDump'
remoteDir='D:\\DataDump'
localLoadDir = localDir + "\\LoadLZ"

emailTo = ['DL_WAD_Logs@FTR.com']
emailFrom = 'WAD@FTR.com'

tz_string = datetime.now(timezone.utc).astimezone().tzname()

#--
#-- Files we want to copy
#--
#copyFiles = ['FFAPROJX.csv', 'FFBDGTLN20.csv', 'FFCIACOPNX.csv', 'FFFIELDSX.csv', 'JMFPRJBGYR.csv', 'FFSPREAD20.csv', 'GROSSADDS.csv', 'JFESTPJYR.csv', 'FFAUTHDTLX.csv', 'FFAUTHDTLZ.csv','CIACREVX20.csv']
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
s.logIT(logger, "Removing old files from " + localDir + " and " + localLoadDir)
for file in copyFiles:
   localFile = localDir + "\\" + file
   localLoadFile = localLoadDir + "\\" + file

   s.logIT(logger, file)

   if os.path.isfile(localFile):
      os.unlink(localFile)
      #-- make sure it is gone
      if os.path.isfile(localFile):
         s.logIT(logger, "  ERROR: Failed to remove " + localFile)
      else:
         s.logIT(logger, "  Removed " + localFile)

   if os.path.isfile(localLoadFile):
      os.unlink(localLoadFile)
      #-- make sure it is gone
      if os.path.isfile(localLoadFile):
         s.logIT(logger, "  ERROR: Failed to remove " + localLoadFile)
      else:
         s.logIT(logger, "  Removed " + localLoadFile)

#--
#-- sftp files from 144 server to this server
#-- 
s.logIT(logger, "--------------------")
s.logIT(logger, "Establishing SSH connection with 144 server")
try:
   ssh = paramiko.SSHClient()
   ssh.load_system_host_keys()

   ssh.connect('10.209.228.42',username='CORP\s_WAD')

   #-- For testing
   #ssh.connect('10.209.228.42',username='CORP\mmm722')

   sftp = ssh.open_sftp()
except paramiko.SSHException:
   s.logIT(logger, "ERROR: Unable to SSH")
   emailSub="[ ERROR ] " + scriptName 
   s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   sys.exit(1)

s.logIT(logger, "--------------------")
s.logIT(logger, "Copying files from 144 Server")
for file in copyFiles:
   remoteFile = remoteDir + "\\" + file
   localFile = localLoadDir + "\\" + file  

   s.logIT(logger, "Getting " + remoteFile + " from 144 server and copying to " + localFile)
   try:
      sftp.get(remoteFile, localFile)
      sftpattrs = sftp.stat(remoteFile)
      os.utime(localFile, (sftpattrs.st_atime, sftpattrs.st_mtime))
   except paramiko.SSHException:
      s.logIT(logger,"ERROR: Unable to sftp get " + remoteFile)

ssh.close()

#--
#-- Copy files in D:\DataDump\LoadLZ directory to D:\DataDump
#-- Remove file from D:\DataDump first to ensure we have new file
#--
s.logIT(logger, "--------------------")
for file in copyFiles:
   localLoadFile = localLoadDir + "\\" + file  
   localFile = localDir + "\\" + file  

   s.logIT(logger, "Copying " + localLoadFile + " to " + localFile)
   if os.path.isfile(localLoadFile):
      try:
         shutil.copy2(localLoadFile, localFile)
      except shutil.Error:
         s.logIT(logger, "ERROR: copy failed")
   else:
      s.logIT(logger, "ERROR: " + localLoadFile + " does not exist")

   #--
   #-- If file does not exist, log an error
   #--
   if not os.path.isfile(localFile):
      s.logIT(logger, "ERROR: " + localFile + " does NOT exist")

#--
#-- Look for ERROR in the log file
#--
if s.stringInFile(logger,"ERROR",logFile):
   emailSub="[ ERROR ] " + scriptName 
else:
   emailSub="[ SUCCESS ] " + scriptName 

s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   
s.logIT(logger,"Finished " + scriptName)
