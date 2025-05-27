# /App/app_AddressBilling/config.py
import os

class Config:
    SQLALCHEMY_DATABASE_URI = (
        'mssql+pyodbc://tsql_wad:1QwKdb79!@WADINFWWDDV01/Playground?driver=ODBC+Driver+17+for+SQL+Server'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    UPLOAD_FOLDER = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'uploads')
    ALLOWEDEXTENSIONS = {'xls', 'xlsx', 'csv', 'txt'}
