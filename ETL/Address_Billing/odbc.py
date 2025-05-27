import pandas as pd
from sqlalchemy import create_engine

def odbc_read(server, database, schema, table, custom_query=None, read_as_str = False):
    """
    Reads from SQL Server Table to Pandas DF in chunks.
    If a custom query is not provided, a SELECT * is executed.
    Args:,
        server (str):       server name       e.g. WADINFWWAPV02
        database (str):     database name     e.g. WAD_PRD_02
        schema (str):       schema name       e.g. dbo
        table (str):        table name        e.g. ETH_ENABLED_LIST
        custom_query (str): Custom SQL query to execute. If None, a default query is used.
        read_as_str (bool): Set as true to read all cols as str.
    """
    driver = 'ODBC Driver 17 for SQL Server'
    connection_string = f'mssql://@{server}/{database}?driver={driver}&Trusted_Connection=yes'
    engine = create_engine(connection_string)
    
    # Use the custom query if provided, otherwise use a default query
    if custom_query is None:
        custom_query = f'''SELECT * FROM [{database}].[{schema}].[{table}]'''
    else:
        custom_query = custom_query.format(database=database, schema=schema, table=table)

    # Read the first chunk to determine the number of columns
    first_chunk_gen = pd.read_sql_query(custom_query, engine, chunksize=1)
    first_chunk = next(first_chunk_gen)
    num_columns = len(first_chunk.columns)
    
    # 2100 is the maximum number of parameters that SQL Server can handle in a single query
    # Calculate chunk size based on the number of columns
    chunk_size = (2100 // num_columns) - 1
    
    # Read data in chunks
    if read_as_str:
        chunks = pd.read_sql_query(custom_query, engine, chunksize=chunk_size, dtype=str)
    else:
        chunks = pd.read_sql_query(custom_query, engine, chunksize=chunk_size)
    # Concatenate chunks into a single DataFrame
    df_sql = pd.concat(chunk for chunk in chunks)
    
    return df_sql


def odbc_write(df, server, database, schema, table, exists='replace'):
    """
    Uploads DF to SQL Server. Set to replace unless exists='append'.
    Args:
        df (pd.DataFrame):  The table to upload.
        server (str):       server name       e.g. WADINFWWAPV02
        database (str):     database name     e.g. WAD_PRD_02
        schema (str):       schema name       e.g. dbo
        table (str):        table name        e.g. ETH_ENABLED_LIST
        exists (str):       replace vs append
    """

    driver = 'ODBC Driver 17 for SQL Server'
    connection_string = f'mssql://@{server}/{database}?driver={driver}&Trusted_Connection=yes'
    engine = create_engine(connection_string)  # , fast_executemany=True
    # insert df into sql server table
    with engine.begin() as connection:
        chunk_size = (2100 // len(df.columns)) - 1
        df.to_sql(table,
                  engine,
                  if_exists=exists,
                  index=False,
                  method='multi',
                  chunksize=chunk_size,
                  schema=schema
                  )