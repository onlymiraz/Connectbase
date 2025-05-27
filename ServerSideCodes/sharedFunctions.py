import subprocess, sys    
import os
from os.path import exists
import logging
import smtplib
from email.message import EmailMessage
import re

#------------------------------------------------------------------------------
# getBasename
# Gets the basename of a filename
# For example: The basename of file.txt is file
#------------------------------------------------------------------------------
def getBasename(inName):
   inBase=""
   (inBase,inExt) = inName.split(".")
   return inBase

#------------------------------------------------------------------------------
# initLogger
# Initiates the log file
#------------------------------------------------------------------------------
def initLogger(logFile):

   logDir=os.path.dirname(logFile)

   if not os.path.isdir(logDir):
      os.makedirs(logDir)
      if not os.path.isdir(logDir):
         print ("Could not create the log directory " + logDir)
         sys.exit(1)

   # Create and configure logger
   logging.basicConfig(filename=logFile,
                       format='%(asctime)s %(message)s',
                       filemode='w')

   # Creating the logger object
   logger = logging.getLogger()

   # Setting the threshold of logger to DEBUG
   logger.setLevel(logging.INFO)

   return logger

#------------------------------------------------------------------------------
# logIT
# logs message to log file and to screen
#------------------------------------------------------------------------------
def logIT(ilogger,logMsg):
   print(logMsg)
   ilogger.info(logMsg)

#------------------------------------------------------------------------------
# mapDriveCM 
# maps the Capital Management Drive
#------------------------------------------------------------------------------
def mapDriveCM (ilogger,psScript):

   #--
   #-- powershell script to map the drive
   #--

   if not os.path.isfile(psScript):
      msg = "ERROR: Required powershell script " + psScript + " not found"
      ilogger.info(msg)
      return False

   p = subprocess.Popen('powershell.exe -ExecutionPolicy RemoteSigned -file D:\\Scripts\\mapShareDrive.ps1', stdout=subprocess.PIPE, stderr=subprocess.PIPE)

   stdout, stderr = p.communicate()

   if stdout:
       ilogger.info(stdout)
   if stderr:
       ilogger.error(stderr)
       return False

   return True

#------------------------------------------------------------------------------
# createDir
# creates a directory if it does not exist
#------------------------------------------------------------------------------
def createDir(ilogger,inDir):

   if not os.path.isdir(inDir):
       logIT (ilogger, inDir + " does not exist.  Creating.")
       os.makedirs(inDir)
       if not dirExists(inDir):
          logIT (ilogger, "ERROR: Unable to create " + inDir)
          return False

   return True

#------------------------------------------------------------------------------
# stringInFile
# searches a file for a string
#------------------------------------------------------------------------------
def stringInFile(ilogger,inStr,inFile):

   if not os.path.isfile(inFile):
      logIT (ilogger, "ERROR: " + inFile + " does not exist")
      return False

   flag = 0
   file1 = open(inFile, "r") 

   for line in file1:  
      # checking string is present in line or not
      if inStr in line:
         flag = 1
         break 
          
   # closing text file    
   file1.close() 

   if flag == 1: 
      return True

   return False

#------------------------------------------------------------------------------
# emailFile
# emails a file
#------------------------------------------------------------------------------
def emailFile(ilogger,iTo,iFrom,iSub,iFile):

   regex = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'

   if not os.path.isfile(iFile):
      logIT (ilogger, "ERROR: " + iFile + " does not exist")
      return False

   if not (re.fullmatch(regex, iFrom)):
      logIT (ilogger, "ERROR: " + iFrom + " is not a valid email")
      return False

   for e in iTo:
      if not (re.fullmatch(regex, e)):
         logIT (ilogger, "ERROR: " + e + " is not a valid email")
         return False

   # Open the plain text file whose name is in textfile for reading.
   with open(iFile) as fp:
      # Create a text/plain message
       msg = EmailMessage()
       msg.set_content(fp.read())

   msg['Subject'] = iSub
   msg['From'] = iFrom
   msg['To'] = ', '.join(iTo)

   try:
      # Send the message via our own SMTP server.
      s = smtplib.SMTP('MailRelay.corp.pvt')
      s.send_message(msg)
      s.quit()
      return True
   except SMTPResponseException as e:
      error_code = e.smtp_code
      error_message = e.smtp_error
      logIT (ilogger, "ERROR: Unable to send email")
      logIT (ilogger, "  " + error_code)
      logIT (ilogger, "  " + error_message)

   return False
