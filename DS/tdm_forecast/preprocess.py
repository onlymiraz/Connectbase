import os
import pandas as pd
import numpy as np
import dask.dataframe as dd
import pyodbc
from sqlalchemy import create_engine


def query_and_clean(run_date, first_date='2019-06-01', last_date='2024-05-31'):
    """
    Pulls TDM CABS data from SQL Server.
    Main.py should leave a 1-month buffer.

    Example:
        Today: '2024-09-09'
        Start: '2019-08-01'
        Stop:  '2024-07-31'

    Args:
        run_date (str): Saves cleaned file to outputs/run_date.
        first_date (str): Should be set to 5 years + 1 month ago (first day).
        last_date (str): Should be set to 2 months ago (last day).

    Returns:
        pd.DataFrame: The select SQL query table.
    """
    print('Querying data')

    select = f'''
    SELECT [PRIMARY_CARRIER_NM] AS PRIMARY_CARRIER_NAME
      ,[CLEAN_ID]
      ,[BILL_MONTH_DT]
      ,[INSTALL_DT]
      ,[DISCONNECT_DT]
      ,[JURIS_DS]
      ,[CHRGE_AMT]
      ,[IXC_NAME]
      ,[EO_CLLI_CD]
      ,[POP_CLLI_CD]
      ,[TERM_START_DT]
      ,[TERM_END_DT]
      ,[FACILITY_TYPE]
      ,[SW_SPL_IND]
      ,[ACCT_TYPE]
      ,[PRMIUM_IND]
      ,[FUSC_EXMPT_IND]
      ,[TAX_SURCHRG_EXMPT_IND]
      ,[ACTLCLLI]
      ,[SWPIU]
      ,[CUST]
      ,[CUSTNAME]    
      ,[EO]
      ,[RATEID]
      ,[RATE]
      ,[CUSTSTATE]
      ,[PROD_TYPE]
      ,[CURR_BILL]
    FROM [WAD_PRD_02].[dbo].[CABS_CIRCUIT_USOC_DETAIL_V]
    WHERE BILL_MONTH_DT BETWEEN '{first_date}' AND '{last_date}'
      AND (PROD_TYPE IN ('T1','T3') OR PROD_TYPE LIKE ('%TDM%') /*OR PROD_TYPE LIKE ('%OCN%'))*/ )
      /*AND TERM_START_DT <> '2106-08-10'
      AND TERM_END_DT <> '9999-12-31'*/
    '''
    conn_str = (
        'Driver={ODBC Driver 17 for SQL Server};'
        'Server=WADINFWWAPV02;'
        'Database=WAD_PRD_02;'
        'Trusted_Connection=yes;')

    conn = pyodbc.connect(conn_str, timeout=3600 * 3)  # 3 hour timeout
    print('Database connection established')

    chunk_size = 100000
    lst_chunks = []
    for chunk in pd.read_sql_query(select, conn, chunksize=chunk_size):
        print(f'Processing chunk of size: {len(chunk)}')
        lst_chunks.append(dd.from_pandas(chunk, npartitions=1))

    # Concatenate the chunks into a single Dask DataFrame
    ddf = dd.concat(lst_chunks, axis=0)
    print(f'Concatenated {len(lst_chunks)} chunks into a single Dask DataFrame')
    print(f'Dask df size: {len(ddf)}')

    # Process the data in parallel using Dask
    df_tdm = ddf.compute()

    conn.close()

    print('Pandas df before preprocessing: ', df_tdm.shape)

    df_tdm.drop_duplicates(inplace=True)

    # clean date formats
    df_tdm['BILL_MONTH_DT'] = pd.to_datetime(df_tdm['BILL_MONTH_DT'], errors='coerce')
    df_tdm['INSTALL_DT'] = pd.to_datetime(df_tdm['INSTALL_DT'], errors='coerce')

    df_tdm.loc[df_tdm['TERM_START_DT'] == '?', 'TERM_START_DT'] = np.nan
    df_tdm.loc[df_tdm['TERM_END_DT'] == '?', 'TERM_END_DT'] = np.nan
    df_tdm['TERM_START_DT'] = pd.to_datetime(df_tdm['TERM_START_DT'], errors='coerce')
    df_tdm['TERM_END_DT'] = pd.to_datetime(df_tdm['TERM_END_DT'], errors='coerce')

    df_tdm = df_tdm.loc[df_tdm['BILL_MONTH_DT'].between(first_date, last_date, inclusive='both')]

    # BELOW CODE WORKED WITH CABS BUT NOT WITH SQL VIEW - MISSING COLUMNS
    # # filter to only include TDM
    # df_tdm = df_tdm.loc[(df_tdm['SVC_GROUP'].str.contains('TDM')) |
    #                     (df_tdm['SVC_GROUP'].str.contains('OCN')), :]
    #
    # df_tdm = df_tdm.loc[df_tdm['WIRELESS'] == 'WIRELINE', :]

    df_tdm.loc[df_tdm['PROD_TYPE'].isin(['T1', ]), 'PROD_TYPE'] = 'TDM_DS1'
    df_tdm.loc[df_tdm['PROD_TYPE'] == 'T3', 'PROD_TYPE'] = 'TDM_DS3'

    # calculate tenure
    df_tdm['tenure'] = (df_tdm['BILL_MONTH_DT'] - df_tdm['INSTALL_DT']).dt.days.astype('Int64')
    df_tdm = df_tdm.loc[df_tdm['tenure'] >= 0, :]
    df_tdm['tenure'] = round(df_tdm['tenure'] / 365, 2)

    # format for clean forecasting
    df_tdm['BILL_MONTH_DT'] = df_tdm['BILL_MONTH_DT'].dt.strftime('%Y-%m')

    if not os.path.exists(f'./output/{str(run_date)}/'):
        os.makedirs(f'./output/{str(run_date)}/')
    df_tdm.to_csv(f'./output/{str(run_date)}/tdm_cleaned.csv', index=False)
    print('Pandas df after preprocessing: ', df_tdm.shape)

    return df_tdm
