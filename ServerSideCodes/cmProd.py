#!/usr/bin/env python
import ctypes
import datetime
import os
import time
import pyodbc
import tkinter as tk
from pathlib import Path
from sqlalchemy import create_engine
#import sqlalchemy as sa
#import sqlalchemy_access as sa_a
#import sqlalchemy_access.pyodbc as sa_a_pyodbc
from tkinter import filedialog, messagebox
from tkinter import * 
from tkinter.ttk import *
import functions as f
import pandas as pd
import xlrd
import time
from shutil import copyfile


def convert(file_path, output_path, files, cols, dtypes):

    print('Python is converting excel files into csv files (queries)...')

    # Convert queries
    for file in files:
        start = time.time()
        xl_file = file_path + file + '.xlsx'
        csv_file = output_path + file + '.csv'

        if file in cols:
            file_read = pd.read_excel(xl_file, index_col=None, dtype=dtypes[file], usecols=cols[file], na_filter=False)
        else:
            file_read = pd.read_excel(xl_file, index_col=None, dtype=dtypes[file], na_filter=False)

        file_obj = file_read.select_dtypes(include=['object'], exclude=['number'])
        file_read[file_obj.columns] = file_obj.apply(lambda x: x.str.strip())
        #file_read.fillna(value='', inplace=True)
        if file != 'AUTHORIZED1':
            file_read.to_csv(csv_file, sep='\t', header=False, index=False, chunksize=10000)
        else:
            file_read.to_csv(output_path + 'AUTHORIZED.csv', sep='\t', header=False, index=False, mode='a', chunksize=10000)

        end = time.time()
        print(file, 'query took', int(round(end - start)), 'second(s) to convert from Excel to CSV.')


def upload(files, src_dir, dest_dir):

    print('\n\nPython is uploading the csv files (queries) into the location from where the database will pick up these queries...\n')

    for file in files:
        start = time.time()
        src_file = src_dir + file + '.csv'
        dest_file = dest_dir + file + '.csv'
        copyfile(src_file, dest_file)
        end = time.time()
        print(file, 'query took', int(round(end - start)), 'second(s) to upload.')


def update(conn, startDate, endDate):

    print('\nPython is running the SQL Server database to update the forecast report...\n')

    start = time.time()

    conn.execute('EXECUTE forecast.usp_RunForecastUpdate @ga_start_month = ' + str(startDate) + ', @ga_end_month = ' + str(endDate) + '')
    conn.commit()

    end = time.time()

    print('\nSQL Server took', int(round((end - start)/60)), 'minute(s) to update the ForecastExport table in the database.')


def export(file_dir, file, engine):

    print('\n\nPython is bringing the updated Forecast File from the database...\n')

    start = time.time()

    table = 'ForecastExport'
    schema = 'forecast'
    data = pd.read_sql_table(table, engine, schema)
    data = data.applymap(lambda x: x.encode('unicode_escape').
                         decode('utf-8') if isinstance(x, str) else x)
    data_obj = data.select_dtypes(include=['object'], exclude=['number'])
    data[data_obj.columns] = data_obj.apply(lambda x: x.str.strip())

    file = file_dir + file + '.xlsx'
    data.to_excel(file, index=None, engine='xlsxwriter')

    end = time.time()

    print('It took a total of', int(round((end - start)/60)), 'minutue(s) to download the ForecastExport file from the database.')


files = ['APPROVED', 'AUTHORIZED', 'BUDGETLINE', 'CIACFORFF', 'FIELDS', 'Forecast Upload', 'FUTUREYEAR', 'GA', 'SPREAD', 'Varasset Status', 'ESTIMATE']

dtypes = {
    'APPROVED': {'ProjectNumber': str, 'SubprojectNumber': str},
    'AUTHORIZED': {'ProjectNumber': str, 'SubprojectNumber': str, 'CostCode': int, 'BudgetDollars': float},
    'AUTHORIZED1': {'ProjectNumber': str, 'SubprojectNumber': str, 'CostCode': int, 'BudgetDollars': float},
    'BUDGETLINE': {'ProjectNumber': str, 'SubprojectNumber': str, 'BudgetLineNumber': str},
    'CIACFORFF': {'ProjectNumber': str, 'SubprojectNumber': str, 'BudgetDollars': float, 'SpentDollars': float},
    'FIELDS': {'ProjectNumber': str,
                'SubprojectNumber': str,
                'ClassOfPlant': str,
                'LinkCode': str,
                'JustificationCode': int,
                'FunctionalGroup': str,
                'ProjectDescription': str,
                'ProjectStatusCode': str,
                'ApprovalCode': str,
                'ProjectType': str,
                'Billable': str,
                'Company': int,
                'ExchangeNumber': int,
                'OperatingArea': int,
                'State': str,
                'Engineer': str,
                'ProjectOwner': str,
                'ApprovalDate': int,
                'EstimatedStartDate': int,
                'EstimatedCompleteDate': int,
                'ActualStartDate': int,
                'ReadyForServiceDate': int,
                'TentativeCloseDate': int,
                'CloseDate': int
                },
    'FUTUREYEAR': {'Proj#': str, 'Sub Proj#': str, 'Release $\'s': float},
    'GA': {'GAPRJ#': str, 'GAPRJS': str, 'GAMTRX': int, 'GARPT$': float, 'GAACTY': int, 'GAACTP': int},
    'SPREAD': {'BudgetLineNumber': str, 'BudgetLineName': str},
    'Forecast Upload': {'Proj Num': str, 'Sub Num': str, 'Budget Line Num': str, 'Class of Plant': str, 'Link Code': str, 'Budget Category': str, 'Just Code': int, 'Group': str,
               'Project Description': str, 'Billable': str, 'Proj Status': str, 'Appr Code': str, 'Project Type': str, 'Company': str, 'Exchange': str, 'OA': int, 'State': str, 'Engineer': str,
               'Project Owner': str, 'Approval Date': str, 'Est Start Date': str, 'Est Comp Date': str, 'Act Start Date': str, 'Rdy For Svc Date': str,
               'Tent Close Date': str, 'Close Date': str, 'Current Project Authorized Direct': float, 'Current Project Authorized Indirect': float,
               'Current Project Authorized Amount': float, 'Prior Years Spent': float, 'January Adds Direct': float, 'January Adds Indirect': float, 'February Adds Direct': float,
               'February Adds Indirect': float, 'March Adds Direct': float, 'March Adds Indirect': float, 'April Adds Direct': float, 'April Adds Indirect': float, 'May Adds Direct': float,
               'May Adds Indirect': float, 'June Adds Direct': float, 'June Adds Indirect': float, 'July Adds Direct': float, 'July Adds Indirect': float, 'August Adds Direct': float,
               'August Adds Indirect': float, 'September Adds Direct': float, 'September Adds Indirect': float, 'October Adds Direct': float, 'October Adds Indirect': float, 'November Adds Direct': float,
               'November Adds Indirect': float, 'December Adds Direct': float, 'December Adds Indirect': float, 'All CIAC': float, 'Future Years Spending - Infinium': float, 'Future Years Spending': float,
               'Spending Not Needed': float, 'Additional $ Needed': float, 'CIAC Budget': float, 'Analyst Notes': str, 'Current Project Status': str, '2018 or Carry-In': str, 'Sent to Closing': str},
    'Varasset Status': {'Project': str, 'Subproject': str, 'OSP Project Status': str, 'OSP Project Status Updated On': str, 'Closing Issue': str, 'Scheduled Finish': str, 'Varasset Work Order Status': str},
    'ESTIMATE': {'PJ#': str, 'Bdgt Yr': str, 'Proj Life (Yrs)': str, 'AP Code': str}
}

cols = {
    'Forecast Upload': [0, 1, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 31, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 62, 63, 64, 65, 67, 79, 80, 81, 82, 84],
    'FUTUREYEAR': [2, 3, 9],
    'GA': [2, 3, 7, 14, 16, 17],
    'Varasset Status': [0, 1, 2, 3, 4, 5, 6],
    'ESTIMATE': [1, 11, 15, 20]
}


#--
#-- 2022-08-24 CL Modify script for Production
#--               Change server name and db name
#--
# engine = create_engine('mssql+pyodbc://CAPINFWWWPV01/CapitalManagementStaging?driver=SQL+Server+Native+Client+11.0')
engine = create_engine('mssql+pyodbc://CAPINFWWAPV01/CapitalManagementProduction?driver=SQL+Server+Native+Client+11.0')
c = engine.connect()
conn = c.connection

class Application(tk.Frame):

    def __init__(self, master=None):
        tk.Frame.__init__(self, master)
        self.grid()

        # self.qDir
        #self.createLabel('Location of your latest NGS Queries (Excel files)', 1, 0)
        # self.oDir
        self.createLabel('Where the Forecast Export file will go?', 2, 0)
        self.label.grid(row=2, column=0, sticky='e', pady=5, padx=5)

        # self.rDir
        #self.createLabel('Where the database will pick up the queries', 3, 0)

        self.createLabel('Gross Adds Start Month', 4, 0)
        self.label.grid(row=4, column=0, sticky='e', padx=5)

        self.createLabel('Gross Adds End Month', 5, 0)
        self.label.grid(row=5, column=0, sticky='e', padx=5)

        self.qDir = tk.StringVar()
        #self.entry = tk.Entry(self, textvariable=self.qDir, width=50)
        #self.entry.grid(row=1, column=1)

        self.oDir = tk.StringVar()
        self.entry = tk.Entry(self, textvariable=self.oDir, width=50)
        self.entry.grid(row=2, column=1, sticky='w', pady=10)

        self.rDir = tk.StringVar()
        #self.rDir.set('\\\\nspinfwcipp01\\Capital_Management\\Capital Management Application\\Queries\\')
        #self.entry = tk.Entry(self, textvariable=self.rDir, width=50)
        #self.entry.grid(row=3, column=1)

        self.gaStart = tk.IntVar()
        self.entry = tk.Entry(self, textvariable=self.gaStart, width=10)
        self.entry.grid(row=4, column=1, sticky='w', pady=10)
        
        self.gaEnd = tk.IntVar()
        self.entry = tk.Entry(self, textvariable=self.gaEnd, width=10)
        self.entry.grid(row=5, column=1, sticky='w', pady=10)

        self.manualConvert = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self, text='Do you want to manually convert the queries into csv files?', variable=self.manualConvert)
        #self.chkBtn.grid(row=6, column=1)

        # start convert frame
        #self.conContainer = tk.Frame(self)
        #self.conContainer.grid(row=7, column=1)
        
        #label = tk.Label(self.conContainer, text='List of queries to Convert -->')
        #label.grid(row=4, column=0)
        
        self.conApproved = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='APPROVED', variable=self.conApproved)
        #self.chkBtn.grid(row=0, column=1)
        
        self.conAuthorized = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='AUTHORIZED', variable=self.conAuthorized)
        #self.chkBtn.grid(row=1, column=1)
        
        self.conAuthorized1 = tk.IntVar(value=0)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='AUTHORIZED1', variable=self.conAuthorized1)
        #self.chkBtn.grid(row=2, column=1)
        
        self.conBudgetLine = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='BUDGETLINE', variable=self.conBudgetLine)
        #self.chkBtn.grid(row=3, column=1)
        
        self.conCIAC = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='CIAC', variable=self.conCIAC)
        #self.chkBtn.grid(row=4, column=1)
        
        self.conFields = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='FIELDS', variable=self.conFields)
        #self.chkBtn.grid(row=5, column=1)
        
        self.conForecast = tk.IntVar(value=0)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='Forecast Upload', variable=self.conForecast)
        #self.chkBtn.grid(row=6, column=1)
        
        self.conFutureYear = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='FUTUREYEAR', variable=self.conFutureYear)
        #self.chkBtn.grid(row=7, column=1)
        
        self.conGA = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='GA', variable=self.conGA)
        #self.chkBtn.grid(row=8, column=1)
        
        self.conSpread = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='SPREAD', variable=self.conSpread)
        #self.chkBtn.grid(row=9, column=1)

        self.conVarasset = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='Varasset Status', variable=self.conVarasset)
        #self.chkBtn.grid(row=10, column=1)

        self.conEstimate = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self.conContainer, text='ESTIMATE', variable=self.conEstimate)
        #self.chkBtn.grid(row=11, column=1)
        # end convert frame

        self.manualUpload = tk.IntVar(value=1)
        #self.chkBtn = tk.Checkbutton(self, text='Do you want to manually upload the queries (csv files)?', variable=self.manualUpload)
        #self.chkBtn.grid(row=8, column=1)

        self.manualUpdate = tk.IntVar()
        #self.chkBtn = tk.Checkbutton(self, text='Do you want to manually update the database?', variable=self.manualUpdate)
        self.chkBtn = tk.Checkbutton(self, text='Do you want to avoid updating the database?', variable=self.manualUpdate)
        self.chkBtn.grid(row=9, column=1, sticky='w')

        self.manualExport = tk.IntVar()
        self.chkBtn = tk.Checkbutton(self, text='Manually export the updated ForecastExport table from the database?', anchor=tk.NW, justify=tk.LEFT, variable=self.manualExport)
        self.chkBtn.grid(row=10, column=1, sticky='nw')

        #self.createButton('Search', self.dirPrompt, self.qDir, 1, 2)
        self.createButton('Search', self.dirPrompt, self.oDir, 2, 2)
        self.button.grid(row=2, column=2, sticky='w', padx=5, pady=10)

        self.button = tk.Button(self, text='Update', command=self.runUpdate)
        self.button.grid(row=11, column=1, sticky='w', pady=10)

        #-- progress bar
        self.createLabel('Progress Bar:', 12, 0)
        self.label.grid(row=12, column=0, sticky='e', padx=5)

        self.progress = Progressbar(self, orient = HORIZONTAL, length = 400, mode = 'determinate')
        self.progress.grid(row=12, column=1, columnspan=1, sticky='w', pady=10)

        self.plabel = tk.Label(self, text='0%')
        self.plabel.grid(row=12, column=2, sticky='w', padx=5)

        self.pstatus = tk.Label(self, text=' ')
        self.pstatus.grid(row=13, column=1, sticky='w', padx=5)

    def createLabel(self, labelText, r, c):
        self.label = tk.Label(self, text=labelText)
        self.label.grid(row=r, column=c)

    def createButton(self, buttonText, func, var, r, c):
        self.button = tk.Button(self, text=buttonText, command=lambda a=var : func(a))
        self.button.grid(row=r, column=c)

    def dirPrompt(self, var):
        curdir = 'C:\\Users\\' + os.getlogin() + '\\Desktop\\'
        #var.set(filedialog.askdirectory(parent=root, initialdir=curdir, title='Location of your latest NGS queries that you saved in your desktop.') + '/')
        var.set(filedialog.askdirectory(parent=root, initialdir=curdir, title='Select the location.') + '/')

    def update_progress(self,value, msg):
       self.progress['value'] = value
       self.plabel['text']=str(value) + '%'
       self.pstatus['text'] = msg

       if value < 100 and value > 0:
          self.button['state']="disabled"

       if value == 100 or value == 0:
          self.button['state']="normal"

       root.update()

    def runUpdate(self):

        self.update_progress(0,"Running: starting update process")
        time.sleep(1)

        if (self.manualConvert.get() == 0 and self.qDir.get()) or (self.manualConvert.get() == 1):
            convert = []
            upload = []

            if self.conApproved.get():
                convert.append('APPROVED')
                upload.append('APPROVED')
            if self.conAuthorized.get():
                convert.append('AUTHORIZED')
                upload.append('AUTHORIZED')
            if self.conAuthorized1.get():
                convert.append('AUTHORIZED1')
            if self.conBudgetLine.get():
                convert.append('BUDGETLINE')
                upload.append('BUDGETLINE')
            if self.conCIAC.get():
                convert.append('CIACFORFF')
                upload.append('CIACFORFF')
            if self.conFields.get():
                convert.append('FIELDS')
                upload.append('FIELDS')
            if self.conForecast.get():
                convert.append('Forecast Upload')
                upload.append('Forecast Upload')
            if self.conFutureYear.get():
                convert.append('FUTUREYEAR')
                upload.append('FUTUREYEAR')
            if self.conGA.get():
                convert.append('GA')
                upload.append('GA')
            if self.conSpread.get():
                convert.append('SPREAD')
                upload.append('SPREAD')
            if self.conVarasset.get():
                convert.append('Varasset Status')
                upload.append('Varasset Status')
            if self.conEstimate.get():
                convert.append('ESTIMATE')
                upload.append('ESTIMATE')

            qExist = True
            missing = []
            for file in convert:
                if(not Path(self.qDir.get() + file + '.xlsx').is_file()):
                    qExist = False
                    missing.append(file)


            #print(qExist)
            if(self.manualConvert.get() == 0 and qExist) or (self.manualConvert.get() == 1):
                if (self.manualUpload.get() == 0 and self.rDir.get()) or (self.manualUpload.get() == 1):
                    if(self.manualUpdate.get() == 0 and (self.gaStart.get() != 0 and self.gaEnd.get() != 0)) or (self.manualUpdate.get() == 1):
                        if (self.manualExport.get() == 0 and self.oDir.get()) or (self.manualExport.get() == 1):
                            start = time.time()
                            try:
                                if self.manualConvert.get() == 0:
                                    msg='Running: converting the files...'
                                    self.update_progress(10,msg)
                                    f.convert(self.qDir.get(), self.qDir.get(), convert, cols, dtypes)
                                else:
                                    msg='Running: files manually converted...'
                                    self.update_progress(10,msg)
                                    time.sleep(1)
                                    #self.Mbox('Continue', 'Click OK to continue after you have converted the queries.', 0)
                                    self.grab_set()

                                if self.manualUpload.get() == 0:
                                    msg='Running: uploading the files...'
                                    self.update_progress(25,msg)
                                    f.upload(upload, self.qDir.get(), self.rDir.get())
                                else:
                                    msg='Running: files manually uploaded...'
                                    self.update_progress(25,msg)
                                    time.sleep(1)
                                    #self.Mbox('Continue', 'Click OK to continue after you have uploaded the queries to the drive.', 0)
                                    self.grab_set()

                                if self.manualUpdate.get() == 0:
                                    msg='Running: updating the forecast report...'
                                    self.update_progress(50,msg)
                                    f.update(conn, self.gaStart.get(), self.gaEnd.get())
                                else:
                                    self.Mbox('Continue', 'Click OK to continue after you have updated the database.', 0)
                                    self.grab_set()
                                    msg='Running: forecast report manually updated...'
                                    self.update_progress(50,msg)
                                    time.sleep(1)


                                if self.manualExport.get() == 0:
                                    msg='Running: exporting the updated Forecast File ...'
                                    self.update_progress(75, msg)
                                    f.export(self.oDir.get(), 'Forecast Export', engine)
                                else:
                                    self.Mbox('Continue', 'Click OK to continue after you have exported the data.', 0)
                                    self.grab_set()
                                    msg='Running: Forecast File exported manually...'
                                    self.update_progress(75, msg)
                                    time.sleep(1)

                            except RuntimeError:
                                msg='Error!'
                                self.update_progress(0,msg)
                                print('Error!')
                            end = time.time()
                            msg='Finished: It took ' + str(int(round((end - start)/60))) + ' minutes to run'
                            self.update_progress(100,msg)
                            print('It took', int(round((end - start)/60)), 'minutes to run the entire program to update and obtain the latest forecast report.')
                        else:
                            msg='Error: Missing Output Directory'
                            self.update_progress(0,msg)
                            messagebox._show('Missing Output Directory!', 'You must select the output directory to export with the script.')
                    else:
                       msg='Error: Invalid Gross Adds Start or End'
                       self.update_progress(0,msg)
                       messagebox._show('Invalid Gross Adds Start or End Month', 'You must enter a valid GA start and end month (1-12).')
                else:
                    msg='Error: Missing Remote Directory'
                    self.update_progress(0,msg)
                    messagebox._show('Missing Remote Directory!', 'You must enter a remote directory to upload with the script.')
            else:
                missingStr = ''
                for file in missing:
                    missingStr = missingStr + ', ' + file
                
                msg='Error: Missing Queries'
                self.update_progress(0,msg)
                messagebox._show('Missing Queries!', 'You are missing the following required queries: ' + missingStr[2:])
        else:
            msg='Error: Missing Query Directory'
            self.update_progress(0,msg)
            messagebox._show('Missing Query Directory!',  'You must select the query directory to convert with the script.')


    def Mbox(self, title, text, style):
        return ctypes.windll.user32.MessageBoxW(0, text, title, style)

root = tk.Tk()
#root.withdraw() #use to hide tkinter window

app = Application(root)
app.master.title('Forecast Update Tool')
