import os
import pyodbc
from sqlalchemy import create_engine

import pandas as pd


def odbc_read(table):
    """
    Must provide table argument 'left' or 'right' or it breaks.
    Pulls data from server WADINFWWAPV02, database WAD_PRD_02.

    Args:
        table (str): Determines which select query to use.

    Returns:
        pd.DataFrame: The select SQL query table.
    """
    # determine which table to query
    if table == 'left':
        select = '''
            SELECT *
            FROM [WAD_PRD_02].[CB_MS].[TBL_CB_MS_COMBINED]
            '''
        conn_str = (
            'Driver={ODBC Driver 17 for SQL Server};'
            'Server=WADINFWWAPV02;'
            'Database=WAD_PRD_02;'
            'Trusted_Connection=yes;')

    elif table == 'right':
        select = '''
            SELECT *
            FROM [WAD_PRD_02].[LZ].[TBL_WABB_SERVICE_ORDERS]
            '''
        conn_str = (
            'Driver={ODBC Driver 17 for SQL Server};'
            'Server=WADINFWWAPV02;'
            'Database=WAD_PRD_02;'
            'Trusted_Connection=yes;')

    else:
        raise ValueError("table must be either 'left' or 'right'")

    # create connection
    conn = pyodbc.connect(conn_str)

    # insert sql server data into df
    df_sql = pd.read_sql_query(select, conn)

    # conn.close()

    return df_sql


def odbc_write(df):
    """
    Uploads DF to SQL Server.

    Args:
        df (pd.DataFrame): The table to upload.
    """

    # define connection string for sql server
    server = 'WADINFWWAPV02'
    database = 'WAD_PRD_02'
    driver = 'ODBC Driver 17 for SQL Server'

    connection_string = f'mssql://@{server}/{database}?driver={driver}&Trusted_Connection=yes'
    engine = create_engine(connection_string)  # , fast_executemany=True

    # insert df into sql server table
    with engine.begin() as connection:

        chunk_size = (2100 // len(df.columns)) - 1

        df.to_sql('TBL_PY_OUTPUT',
                  engine,
                  if_exists='replace',
                  index=False,
                  method='multi',
                  chunksize=chunk_size,
                  schema='LZ'
                  )
