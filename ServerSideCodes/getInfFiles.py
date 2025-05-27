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
localDir='D:\\Infinium'
remoteDir='D:\\Infinium'

emailTo = ['DL_WAD_Logs@FTR.com']
emailFrom = 'WAD@FTR.com'

tz_string = datetime.now(timezone.utc).astimezone().tzname()

#--
#-- Files we want to copy
#--
copyFiles = ['ftrshiptoMDB.txt','ItemMasterMDB.txt','OnHandInventoryMDB.txt','WarehouseListMDB.txt']

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

s.logIT(logger, "--------------------")
s.logIT(logger, "Removing old files from " + localDir)
lFileName=[]
lFileTime=[]
l=0
for file in copyFiles:
   localFile = localDir + "\\" + file

   s.logIT(logger, file)

   if os.path.isfile(localFile):
      localTime = int(os.path.getmtime(localFile))
      lFileName.append(file)
      lFileTime.append(localTime)
      l+=1
      s.logIT(logger, file  + " " + str(localTime))
      os.unlink(localFile)
      #-- make sure it is gone
      if os.path.isfile(localFile):
         s.logIT(logger, "  ERROR: Failed to remove " + localFile)
      else:
         s.logIT(logger, "  Removed " + localFile)

#--
#-- sftp files from 144 server to this server
#-- 
s.logIT(logger, "--------------------")
s.logIT(logger, "Establishing SSH connection with 144 server")
try:
   ssh = paramiko.SSHClient()
   ssh.load_system_host_keys()

   ssh.connect('10.209.131.144',username='CORP\s_CapMgtIT')

   #-- For testing
   #ssh.connect('10.209.131.144',username='cll978')

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
   localFile = localDir + "\\" + file  

   s.logIT(logger, "Getting " + remoteFile + " from 144 server and copying to " + localFile)
   try:
      sftp.get(remoteFile, localFile)
      sftpattrs = sftp.stat(remoteFile)
      oTime=sftpattrs.st_mtime
      s.logIT(logger, file  + " " + str(oTime))
      lTime=0
      for l in range(0, len(lFileName)):
         if file == lFileName[l]:
            lTime=lFileTime[l]
            break
      if lTime == oTime:
         s.logIT(logger, "ERROR: Remote file " + file  + " has not changed")
         s.logIT(logger, "       remote timestamp: " + str(oTime))
         s.logIT(logger, "        local timestamp: " + str(lTime))
      else:
         s.logIT(logger, "Remote file " + file  + " has been updated ")
         s.logIT(logger, "       remote timestamp: " + str(oTime))
         s.logIT(logger, "        local timestamp: " + str(lTime))
      
      os.utime(localFile, (sftpattrs.st_atime, sftpattrs.st_mtime))
   except paramiko.SSHException:
      s.logIT(logger,"ERROR: Unable to sftp get " + remoteFile)

ssh.close()

#--
#-- Look for ERROR in the log file
#--
if s.stringInFile(logger,"ERROR",logFile):
   emailSub="[ ERROR ] " + scriptName 
else:
   emailSub="[ SUCCESS ] " + scriptName 

s.emailFile(logger,emailTo,emailFrom,emailSub,logFile)
   
s.logIT(logger,"Finished " + scriptName)
