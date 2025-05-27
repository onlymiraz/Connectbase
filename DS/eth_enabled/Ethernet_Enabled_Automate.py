import pandas as pd
import numpy as np
import openpyxl
import os
import pyodbc
from sqlalchemy import create_engine
import socket
import logging
import sys

# Set up logging
# Need to change filename parameter only
# e.g. 2024-12-03 16:30:00,000 - INFO - Starting ETL process
logging.basicConfig(filename='Eth_Enabled_Script.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Print the absolute path of the log file
log_file_path = os.path.abspath('Eth_Enabled_Script.log')
print(f"Log file is being written to: {log_file_path}")

# The socket library in Python is used to get the hostname of the machine where the script is running
# Running socket.gethostname().upper() will return either WADINFWWDDV01 or WADINFWWAPV02
# Take advantage of this to test in staging (DDV01) before pushing to production (APV02)
# Use [WADINFWWDDV01].[WAD_STG_Integration] or [WADINFWWAPV02].[WAD_PRD_Integration] for python scripts 
# These two are exempt from build overwrites 

# Define dictionary mapping of hostnames to databases
# Your local machine hostname looks like 5CG213BFKQ
node_db_mapping = {
    'WADINFWWAPV02': 'WAD_PRD_Integration',
    'WADINFWWDDV01': 'WAD_STG_Integration'
    # Add other nodes and their corresponding databases here
}

# Get the current node
current_node = socket.gethostname().upper()
# For testing locally only
# current_node = 'WADINFWWDDV01'
# Default to 'WAD_STG_Integration' if you don't get a valid hostname
database_name = node_db_mapping.get(current_node, 'WAD_STG_Integration')

def odbc_read(table):
    """
    Must provide table argument 'left' or 'right' or it breaks.
    'left' pulls the latest ethernet enabled list to be updated
    'right' pulls the DSAT matrix to compute the needed updates

    Args:
        table (str): Determines which select query to use.

    Returns:
        pd.DataFrame: The select SQL query table.
    """
    # determine which table to query
    try:
        if table == 'left':
            select = f'''
            SELECT *
            FROM [{database_name}].[LZ_Py].[ETH_ENABLED_LIST]
            WHERE [SYSDATE] = (
                SELECT MAX(SYSDATE)
                FROM [{database_name}].[LZ_Py].[ETH_ENABLED_LIST])
            '''
            conn_str = (
                'Driver={ODBC Driver 17 for SQL Server};'
                f'Server={current_node};'
                f'Database={database_name};'
                'Trusted_Connection=yes;')
        elif table == 'right':
            select = '''
            SELECT [SYSDATE], [WIRECENTERCLLI], [EIA], [EREACHPATH], [MAXIMUMSPEED], [MAXIMUMQUALITYOFSERVICE],
                   [HBE_EIA], [HBE_EVPL], [HBE_MAX_SPEED], [HBE_MAX_QOS], [WAVELENGTH], [HBE_WAVELENGTH]
            FROM [WAD_PRD_02].[DBO].[DSAT_MATRIX_V]
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
        logging.info(f"Data read successfully from {table} table")
        return df_sql
    except Exception as e:
        logging.error(f"Error reading data from {table} table: {e}")
        sys.exit(1)

def odbc_write(df, server, database, out_name):
    """
    Uploads DF to SQL Server.
    Set to append, so we only run this after checking for if there is data to append.

    Args:
        df (pd.DataFrame): The table to upload.
        server (str):   server name       e.g. WADINFWWAPV02
        database (str): database name     e.g. WAD_PRD_02
        out_name (str): table name        e.g. ETH_ENABLED_LIST
        schema set to LZ_Py be default
    """
    try:
        # define connection string for sql server
        driver = 'ODBC Driver 17 for SQL Server'
        connection_string = f'mssql://@{server}/{database}?driver={driver}&Trusted_Connection=yes'
        engine = create_engine(connection_string) # , fast_executemany=True
        # insert df into sql server table
        with engine.begin() as connection:
            chunk_size = (2100 // len(df.columns)) - 1
            df.to_sql(out_name, engine, if_exists='append', index=False, method='multi', chunksize=chunk_size, schema='LZ_Py')
        logging.info(f"Data written successfully to {out_name} table")
    except Exception as e:
        logging.error(f"Error writing data to {out_name} table: {e}")
        sys.exit(1)
        
# Loading in all file dependencies

# Previous month's ethernet-enabled list used as a starting point
base0 = odbc_read('left')
logging.info('Existing ethernet enabled list read in')
base0["QOS"] = base0["QOS"].fillna('N/A')
# Weekly DSAT file that gets pushed Monday
dsat0 = odbc_read('right')
logging.info('Latest DSAT Matrix read in')

# Find the maximum date in base0["SYSDATE"]
max_base0_date = base0["SYSDATE"].max()

# Create a flag to check if the first occurence of dsat["SYSDATE"] is greater than max_base0_date
# This lets us know whether we should update the script or not
update_flag = dsat0["SYSDATE"].iloc[0] > max_base0_date
logging.info(f'Update available? = {update_flag}')


def update():
    """"
    Returns:
        pd.DataFrame: Updated ethernet enabled list using latest DSAT matrix
    """
    
    # There are 15 CLLI that can present itself in two different variations. 
    # Below is code converting them from one format (DSAT uses repeated letter) to the other (spacebar instead of letter)

    # 3 CITY CLLI SWCS format conversions (15 in total)
    dsat =   dsat0[["SYSDATE",     "WIRECENTERCLLI", 
                    "EIA",         "EREACHPATH",   "MAXIMUMSPEED",   "MAXIMUMQUALITYOFSERVICE",
                    "HBE_EIA",     "HBE_EVPL",     "HBE_MAX_SPEED",  "HBE_MAX_QOS",
                    "WAVELENGTH",  "HBE_WAVELENGTH"]].copy()

    dsat.columns = ["SYSDATE",     "SWC",
                    "LEG_EIA",     "LEG_EPATH",    "LEG_SPEED",      "LEG_QOS",                   
                    "HBE_EIA",     "HBE_EPATH",    "HBE_SPEED",      "HBE_QOS",
                    "WAVELENGTH",  "HBE_WAVELENGTH"]

    dsat["WAVELENGTH"]     = dsat["WAVELENGTH"].replace("Yes", "Y").replace("No", "N")
    dsat["HBE_WAVELENGTH"] = dsat["HBE_WAVELENGTH"].replace("Yes", "Y").replace("No", "N")

    dsat["SWC"] = dsat["SWC"].replace('MANNWVJU', 'MAN WVJU')
    dsat["SWC"] = dsat["SWC"].replace('IDAAMIXH', 'IDA MIXH')
    dsat["SWC"] = dsat["SWC"].replace('MIOOMIXG', 'MIO MIXG')
    dsat["SWC"] = dsat["SWC"].replace('ELYYMNXE', 'ELY MNXE')
    dsat["SWC"] = dsat["SWC"].replace('JOYYILXD', 'JOY ILXD')
    dsat["SWC"] = dsat["SWC"].replace('GAPPPAXG', 'GAP PAXG')
    dsat["SWC"] = dsat["SWC"].replace('INAAILXE', 'INA ILXE')
    dsat["SWC"] = dsat["SWC"].replace('ORDDNEXH', 'ORD NEXH')
    dsat["SWC"] = dsat["SWC"].replace('DOWWILXE', 'DOW ILXE')
    dsat["SWC"] = dsat["SWC"].replace('POEEINXA', 'POE INXA')
    dsat["SWC"] = dsat["SWC"].replace('NEYYOHXA', 'NEY OHXA')
    dsat["SWC"] = dsat["SWC"].replace('RIOOILXD', 'RIO ILXD')
    dsat["SWC"] = dsat["SWC"].replace('AVAAILXE', 'AVA ILXE')
    dsat["SWC"] = dsat["SWC"].replace('LEOOINXA', 'LEO INXA')

    # VAN TXXA, VANNTXXA already has both spellings in DSAT
    #dsat["SWC"] = dsat["SWC"].replace('VANNTXXA', 'VAN TXXA')

    # TOWWTXXA already in TOW TXXA format in DSAT
    
    # Standardizing nulls to "N/A"
    dsat["LEG_QOS"] = dsat["LEG_QOS"].fillna('N/A').replace('NA', 'N/A')
    dsat["HBE_QOS"] = dsat["HBE_QOS"].fillna('N/A').replace('NA', 'N/A')
    # dsat[["LEG_QOS", "HBE_QOS"]].value_counts(dropna=False)
    
    # Consolidating both networks to show the higher speed
    dsat["EIA2"]           = np.where( (dsat["LEG_EIA"]=="Yes")   | (dsat["HBE_EIA"]=="Yes"),   "Yes", "No")
    dsat["EPATH2"]         = np.where( (dsat["LEG_EPATH"]=="Yes") | (dsat["HBE_EPATH"]=="Yes"), "Yes", "No")

    # We only consolidate HBE speeds/QOS if either HBE EIA OR EPATH IS AVAILABLE
    # Otherwise fallback to showing only the max capable from legacy network
    HBE_cond               = (dsat["HBE_EIA"] == "Yes") | (dsat["HBE_EPATH"] == "Yes")
    valid_HBE_speed        = (dsat["HBE_SPEED"].str.contains("GB", na=False))
    dsat["SPEED2"]         = np.where( HBE_cond & valid_HBE_speed, dsat["HBE_SPEED"], dsat["LEG_SPEED"])

    QOS_conds = [
        HBE_cond & ((dsat['LEG_QOS'] == 'Platinum') | (dsat['HBE_QOS'] == 'Platinum')),
        HBE_cond & ((dsat['LEG_QOS'] == 'Silver') | (dsat['HBE_QOS'] == 'Silver')),
        (dsat['LEG_QOS'] == 'N/A') & (dsat['HBE_QOS'] == 'N/A')
    ]

    dsat["QOS2"]          = np.select(QOS_conds, ['Platinum', 'Silver', 'N/A'], dsat["LEG_QOS"])
    
    # Merge in latest DSAT fields
    # Drop old SYSDATE so we can use the latest one from the DSAT matrix
    base1 = base0.drop(columns=["SYSDATE"]).merge(dsat.drop(columns=["SYSDATE"]), on=["SWC"], how='left')
    
    # Set new SYSDATE manually so we don't have NA values if SWCs dropped from DSAT
    base1["SYSDATE"] = dsat["SYSDATE"].max()

    # If corresponding column is not null in DSAT, update the field
    base1["SPEED"] =  np.where(~base1["SPEED2"].isnull(),  base1["SPEED2"],  base1["SPEED"])
    base1["QOS"]   =  np.where(~base1["QOS2"].isnull(),    base1["QOS2"],    base1["QOS"])
    base1["QOS"]   =  base1["QOS"].fillna("N/A")
    base1["EPATH"] =  np.where(~base1["EPATH2"].isnull(),  base1["EPATH2"],  base1["EPATH"])
    base1["EIA"]   =  np.where(~base1["EIA2"].isnull(),    base1["EIA2"],    base1["EIA"])

    # Initializing new columns
    # base1["10G Wavelength"]  = base1["10G & 100G Wavelength"].copy()
    # base1["100G Wavelength"] = base1["10G & 100G Wavelength"].copy()
    # base1["400G Wavelength"] = base1["10G & 100G Wavelength"].copy()

    # Updating new wavelength availabilities from Clinton Haley's monthly file
    base1["10G_WAVELENGTH"]   = np.where(~base1["WAVELENGTH"].isnull(), base1["WAVELENGTH"], base1["10G_WAVELENGTH"])
    base1["400G_WAVELENGTH"]  = np.where(~base1["HBE_WAVELENGTH"].isnull(), base1["HBE_WAVELENGTH"], base1["400G_WAVELENGTH"])
    base1["100G_WAVELENGTH"]  = np.where( (base1["10G_WAVELENGTH"]=="Y") | (base1["400G_WAVELENGTH"]=="Y"), "Y", "N")

    # Only extracting needed columns
    out = base1[['SYSDATE',
        'FRONTIER_COMPANY', 'STATE', 'OCN', 'ICSC', 'LATA', 'OPERATING_AREA',
        'SWC', 'SWC_NAME', 'LATITUDE', 'LONGITUDE', 'ADDRESS', 'CITY', 'ZIP_CD',
        'SPEED', 'QOS', 'EPATH', 'EIA', '10G_WAVELENGTH', '100G_WAVELENGTH', '400G_WAVELENGTH']].copy()

    # Update the row where SWC is LNBHCAXS with values from LNBHCAXP, except for SWC
    # Points to the same physical CO as LNBHCAXS but all ROADM systems in the office are inventoried under LNBHCAXP
    out.loc[out['SWC'] == 'LNBHCAXS', out.columns != 'SWC'] = \
    out.loc[out['SWC'] == 'LNBHCAXP', out.columns != 'SWC'].values

    # Track differences from the update
    diff = pd.concat([out, base0])\
        .drop_duplicates(['SWC', 'SPEED', 'QOS', 'EPATH', 'EIA', 
                        '10G_WAVELENGTH','100G_WAVELENGTH', '400G_WAVELENGTH'],
                        keep=False
                        )['SWC'].unique()
                    
    out['CHANGED_FROM_LAST_DSAT'] = np.where(out['SWC'].isin(diff), 'Y', 'N')
    
    return out


if update_flag:
    # Only run the update script if DSAT matrix is newer than existing ethernet enabled list
    out = update()
    logging.info('Latest ethernet enabled list computed')
    
    # Write update to SQL
    odbc_write(out, current_node, database_name, 'ETH_ENABLED_LIST')
    logging.info('New list written to destination table')