# app_AddressBilling/orchestration/ETL/odbc.py

import os
import socket
import pandas as pd
from sqlalchemy import create_engine

###############################################################################
# This dictionary maps known HOSTNAMEs to (server, database).
# If the current hostname isn't recognized, we default to STG.
###############################################################################
node_db_mapping = {
    'WADINFWWDDV01': {
        'server': 'WADINFWWDDV01',
        'database': 'WAD_STG_Integration'
    },
    'WADINFWWAPV02': {
        'server': 'WADINFWWAPV02',
        'database': 'WAD_PRD_Integration'
    },
    'WADINFWWAPV03': {
        'server': 'WADINFWWAPV02',
        'database': 'WAD_PRD_Integration'
    },
    'WADINFWWDPV01': {
        'server': 'WADINFWWAPV02',
        'database': 'WAD_PRD_Integration'
    },
    'WADINFWWDPV02': {
        'server': 'WADINFWWAPV02',
        'database': 'WAD_PRD_Integration'
    }
}

def _get_server_and_db():
    """
    Return (server, database) based on the machine's hostname.
    Fallback to STG if not recognized.
    """
    hostname = socket.gethostname().upper()
    info = node_db_mapping.get(hostname)
    if info is not None:
        return (info['server'], info['database'])
    else:
        # fallback => STG
        return ('WADINFWWDDV01', 'WAD_STG_Integration')

def odbc_read(schema, table, custom_query=None, read_as_str=False):
    """
    Reads from the chosen environment (STG or PRD) with chunking.
    If custom_query is specified, we use that. Otherwise SELECT *.
    """
    server, database = _get_server_and_db()
    driver = 'ODBC Driver 17 for SQL Server'
    conn_str = f"mssql://@{server}/{database}?driver={driver}&Trusted_Connection=yes"
    engine = create_engine(conn_str)

    if custom_query is None:
        custom_query = f"SELECT * FROM [{schema}].[{table}]"

    # We'll do a tiny read to figure out chunk_size
    import pandas as pd
    first_iter = pd.read_sql_query(custom_query, engine, chunksize=1)
    first_chunk = next(first_iter)
    num_columns = len(first_chunk.columns)
    chunk_size = max(1, (2100 // num_columns) - 1)

    if read_as_str:
        df_iter = pd.read_sql_query(custom_query, engine, chunksize=chunk_size, dtype=str)
    else:
        df_iter = pd.read_sql_query(custom_query, engine, chunksize=chunk_size)

    df_out = pd.concat(df_iter, ignore_index=True)
    return df_out

def odbc_write(df, schema, table, exists='replace'):
    """
    Writes df to the chosen environment's [schema].[table], using to_sql chunking.
    """
    server, database = _get_server_and_db()
    driver = 'ODBC Driver 17 for SQL Server'
    conn_str = f"mssql://@{server}/{database}?driver={driver}&Trusted_Connection=yes"
    engine = create_engine(conn_str)

    with engine.begin() as conn:
        chunk_size = max(1, (2100 // len(df.columns)) - 1)
        df.to_sql(
            table,
            conn,
            schema=schema,
            if_exists=exists,
            index=False,
            method='multi',
            chunksize=chunk_size
        )
