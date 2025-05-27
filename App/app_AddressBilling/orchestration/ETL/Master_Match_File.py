# app_AddressBilling/orchestration/ETL/Master_Match_File.py

from odbc import odbc_read, odbc_write, _get_server_and_db
from process_raw_addresses import clean_addresses, parse_addresses
import pandas as pd
import pandas_usaddress as padd
import numpy as np
import time
import logging
import os
import warnings

warnings.simplefilter(action='ignore', category=FutureWarning)

script_dir = os.path.dirname(os.path.abspath(__file__))
log_filename = 'Master_Match_Script.log'
log_file_path = os.path.join(script_dir, log_filename)

logging.basicConfig(
    filename=log_file_path,
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Print the absolute path of the log file
print(f"Log file is being written to: {log_file_path}")

def timed_execution(func, message, *args, **kwargs):
    """
    Logs the time to execute a function.
    
    Args:
        func: function to execute
        message: custom text
        *args, **kwargs: function variables
    """
    start_time = time.time()
    result = func(*args, **kwargs)
    end_time = time.time()
    elapsed_time = (end_time - start_time) / 60
    logging.info(f"{message} {func.__name__.upper()}: {elapsed_time:.2f} minutes to execute")
    return result

def _get_bll_query():
    """
    Returns the SQL query used to read building-list data from environment.
    """
    return """
    SELECT
      UniqueID, ADDR, CITY, STATE, ZIP,
      PRICING_TIER, LIT, EthernetLit, SWC
    FROM [{database}].[{schema}].[{table}]
    """

if __name__ == '__main__':
    
    # 1) Read in CABS_ADDR_PRD_PIVOT
    cabs_piv = timed_execution(
        odbc_read, "CABS PRODUCT PIVOT =>",
        schema='ADDRESS_BILLING',
        table='CABS_ADDR_PRD_PIVOT'
    )
    
    # 2) Read in CARS_ADDR_PRD_PIVOT
    cars_piv = timed_execution(
        odbc_read, "CARS PRODUCT PIVOT =>",
        schema='ADDRESS_BILLING',
        table='CARS_ADDR_PRD_PIVOT'
    )
    
    # 3) Read in the building list (e.g. 24Q4_BLDG_LIST)
    bll_query = _get_bll_query()
    bll = timed_execution(
        odbc_read, "Published Bldg List =>",
        schema='ADDRESS_BILLING',
        table='24Q4_BLDG_LIST',
        custom_query=bll_query,
        read_as_str=True
    )
    
    # Renaming column to match fuzzymatch code
    bll_piv = bll.rename(columns={"ADDR":"ADDRESS"})
    
    # Combine cabs + cars pivot
    bill_piv = pd.merge(
        cabs_piv, cars_piv,
        on=['ADDRESS','CITY','STATE','ZIP'],
        how='outer'
    )
    # Ensure zip is only 5 digits
    bill_piv["ZIP"] = bill_piv["ZIP"].str[:5]
    # If zipcode is only 4 digits and in CT, add leading zero
    bill_piv["ZIP"] = np.where(
        (bill_piv["STATE"]=="CT") & (bill_piv["ZIP"].str.len()==4),
        "0"+bill_piv["ZIP"],
        bill_piv["ZIP"]
    )
    
    new_order = [
        'ADDRESS','CITY','STATE','ZIP',
        'WIRELINE_ETH','WIRELESS_ETH','WHSL_DIA','BUS_DIA','BB',
        'WAVELENGTH','TDM','SONET','VOICE','COLLO'
    ]
    bill_piv2 = bill_piv[new_order].copy()
    
    # 4) Prep addresses for fuzzymatching
    df_L, df_R = timed_execution(
        clean_addresses, "Prep addresses =>",
        bill_piv2, bll_piv
    )
    
    # 5) Apply fuzzymatching code
    df_match = timed_execution(
        parse_addresses, "Fuzzymatch =>",
        df_L[["ADDRESS","CITY","STATE","ZIP","full_address","index"]].copy(),
        df_R[["ADDRESS","CITY","STATE","ZIP","full_address","index","PRICING_TIER"]].copy()
    )
    
    # Create flags
    df_match["EXACT_MATCH"] = (df_match["full_address_l"] == df_match["full_address_r"])
    df_match["ZIP_MATCH"]   = (df_match["ZIP_l"] == df_match["ZIP_r"])
    df_match["POST_MATCH"]  = (df_match["StreetNamePostDirectional_l"] == df_match["StreetNamePostDirectional_r"])
    
    # Sort duplicates
    df_match2 = df_match.sort_values(
        ["index_l","EXACT_MATCH","ZIP_MATCH","POST_MATCH","PRICING_TIER_r"],
        ascending=[True,False,False,False,True]
    )
    df_match3 = df_match2.drop_duplicates(["index_l"], keep='first')
    
    df_L = df_L.rename(columns={"index":"index_l"})
    df_R = df_R.rename(columns={"index":"index_r"})
    
    df_merge = df_match3[["index_l","index_r"]]\
        .merge(df_L, on="index_l", how="left")\
        .merge(df_R, on="index_r", how="left")
    
    # Preferentially use BLL address columns
    df_merge["ADDRESS"] = df_merge["ADDRESS_y"].str.upper()
    df_merge["CITY"]    = df_merge["CITY_y"].str.upper()
    df_merge["STATE"]   = df_merge["STATE_y"].str.upper()
    df_merge["ZIP"]     = df_merge["ZIP_y"]
    
    # Columns to sum
    sum_columns = [
        'WIRELINE_ETH','WIRELESS_ETH','WHSL_DIA','BUS_DIA',
        'BB','WAVELENGTH','TDM','SONET','VOICE','COLLO'
    ]
    # Columns to keep
    keep_columns = [
        'UniqueID','ADDRESS','CITY','STATE','ZIP',
        'PRICING_TIER','LIT','EthernetLit','SWC'
    ]
    for col in sum_columns:
        df_merge[col] = df_merge[col].astype(float)
    for col in keep_columns:
        df_merge[col] = df_merge[col].astype(str)
    
    # Group by index_r
    df_grouped = df_merge.groupby('index_r').agg({
        **{col: "first" for col in keep_columns},
        **{col: lambda x: x.sum(min_count=1) for col in sum_columns}
    }).reset_index()
    
    # Add pivot addresses that did not match
    Lmerged_df = pd.merge(df_L, df_match3[['index_l']], on='index_l', how='left', indicator=True)
    newL_rows = Lmerged_df[Lmerged_df['_merge']=='left_only'].drop(columns=['_merge','full_address'])
    Rmerged_df = pd.merge(df_R, df_match3[['index_r']], on='index_r', how='left', indicator=True)
    newR_rows = Rmerged_df[Rmerged_df['_merge']=='left_only'].drop(columns=['_merge','full_address'])
    
    df_final = pd.concat([df_grouped, newL_rows, newR_rows], axis=0, ignore_index=True)
    df_final2 = df_final.drop(columns=["index_r","index_l"], errors='ignore')\
                        .sort_values(["UniqueID"])\
                        .replace({None: np.nan, 'None': np.nan})
    
    # 6) Write final => ADDR_BILLING_MASTER
    timed_execution(
        odbc_write, "Write => ADDR_BILLING_MASTER",
        df_final2,
        schema='ADDRESS_BILLING',
        table='ADDR_BILLING_MASTER',
        exists='replace'   # or 'append' if desired
    )
