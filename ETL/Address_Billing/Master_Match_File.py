from odbc import odbc_read, odbc_write
from process_raw_addresses import clean_addresses, parse_addresses
import pandas as pd
import pandas_usaddress as padd
import numpy as np
import time
import logging
import os
import warnings

warnings.simplefilter(action='ignore', category=FutureWarning)

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))
log_filename = 'Master_Match_Script.log'

# Set the log file path to be in the same directory as the script
log_file_path = os.path.join(script_dir, log_filename)

# Set up logging
logging.basicConfig(filename=log_file_path, level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

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

bll_query =\
"""
SELECT
UniqueID, ADDR, CITY, STATE, ZIP, PRICING_TIER, 
LIT, EthernetLit, SWC

FROM [{database}].[{schema}].[{table}]
"""

if __name__ == '__main__':
    
    # Read in the three necessary DFS - 1. CABS PRD PIVOT, 2. CARS PRD PIVOT, 3. PUBLISHED BLDG LIST
    
    # cabs_piv = pd.read_csv("CABS_agg.csv", dtype={"ZIP":str})
    cabs_piv = timed_execution(
        odbc_read, "CABS PRODUCT PIVOT -", server='WADINFWWAPV02', database='WAD_PRD_Integration', 
        schema='ADDRESS_BILLING', table='CABS_ADDR_PRD_PIVOT')
    
    # cars_piv = pd.read_csv("CARS_agg.csv", dtype={"ZIP":str})
    cars_piv = timed_execution(
        odbc_read, "CARS PRODUCT PIVOT -", server='WADINFWWAPV02', database='WAD_PRD_Integration', 
        schema='ADDRESS_BILLING', table='CARS_ADDR_PRD_PIVOT')

    # bll_piv  = pd.read_csv("../BLL_MASTER_4Q24_NEW/BLL_PUB_122324.csv", dtype=str)
    bll = timed_execution(
        odbc_read, "Published Bldg List -", server='WADINFWWAPV02', database='WAD_PRD_Integration', 
        schema='ADDRESS_BILLING', table='24Q4_BLDG_LIST', custom_query=bll_query, read_as_str=True)
    
    # Renaming column to match fuzzymatch code
    bll_piv = bll.rename(columns={"ADDR":"ADDRESS"})
    
    # Combining CABS and CARS pivots into a single DF
    bill_piv = pd.merge(cabs_piv, cars_piv, on=['ADDRESS', 'CITY', 'STATE', 'ZIP'], how='outer')
    # Make sure zipcodes are only 5 digits
    bill_piv["ZIP"] = bill_piv["ZIP"].str[:5]

    # If zipcode is only 4 digits and in state CT, add a leading zero
    bill_piv["ZIP"] = np.where((bill_piv["STATE"]=="CT") & (bill_piv["ZIP"].str.len()==4),
                               "0"+bill_piv["ZIP"], bill_piv["ZIP"])
    
    # Re-arranging the order by which products are displayed
    new_order = ['ADDRESS', 'CITY', 'STATE', 'ZIP', 
                'WIRELINE_ETH', 'WIRELESS_ETH', 'WHSL_DIA', 'BUS_DIA',
                'BB', 'WAVELENGTH', 'TDM', 'SONET', 'VOICE', 'COLLO']

    bill_piv2 = bill_piv[new_order].copy()
    
    # Prep addresses for fuzzymatching
    df_L, df_R = timed_execution(
        clean_addresses, "Address preparatory cleaning -", bill_piv2, bll_piv)
    
    # Apply fuzzymatching code 
    df_match = timed_execution(parse_addresses, "Address Fuzzymatch -",
            df_L[["ADDRESS", "CITY", "STATE", "ZIP", "full_address", "index"]].copy(),
            df_R[["ADDRESS", "CITY", "STATE", "ZIP", "full_address", "index", "PRICING_TIER"]].copy())
    
    # Create flags for whether exact, zipcode and post directional match
    df_match["EXACT_MATCH"] = (df_match["full_address_l"] == df_match["full_address_r"])
    df_match["ZIP_MATCH"]   = (df_match["ZIP_l"] == df_match["ZIP_r"])
    df_match["POST_MATCH"]  = (df_match["StreetNamePostDirectional_l"] == df_match["StreetNamePostDirectional_r"])

    # Sort dupes using created flags
    df_match2 = df_match.sort_values(["index_l", "EXACT_MATCH", "ZIP_MATCH", "POST_MATCH", "PRICING_TIER_r"],
                                    ascending=[True, False, False, False, True])

    # Keeping preferred dupe first (e.g. zipcode must match, post must match, lower pricing tier)
    df_match3 = df_match2.drop_duplicates(["index_l"], keep='first')

    # Renaming index columns for subsequent joining
    df_L = df_L.rename(columns={"index":"index_l"})
    df_R = df_R.rename(columns={"index":"index_r"})
    
    # Joining address columns to index columns
    df_merge = df_match3[["index_l", "index_r"]]\
    .merge(df_L, on=["index_l"], how='left')\
    .merge(df_R, on=["index_r"], how='left')
    
    # Preferentially use BLL address columns as the final display set
    df_merge["ADDRESS"] = df_merge["ADDRESS_y"].str.upper()
    df_merge["CITY"]    = df_merge["CITY_y"].str.upper()
    df_merge["STATE"]   = df_merge["STATE_y"].str.upper()
    df_merge["ZIP"]     = df_merge["ZIP_y"].copy()
        
    # Columns to sum
    sum_columns = ['WIRELINE_ETH', 'WIRELESS_ETH', 'WHSL_DIA', 'BUS_DIA', 'BB',
                'WAVELENGTH', 'TDM', 'SONET', 'VOICE', 'COLLO']

    # Columns to keep 
    keep_columns = ['UniqueID', 'ADDRESS', 'CITY', 'STATE', 'ZIP', 
                    'PRICING_TIER', 'LIT', 'EthernetLit', 'SWC']
    
    # Make sure columns are in correct data type before performing agg functions
    for col in sum_columns:
        df_merge[col] = df_merge[col].astype(float)
        
    for col in keep_columns:
        df_merge[col] = df_merge[col].astype(str)   
    
    # Group by index_r and sum the specified columns
    # sum(min_count=1) ensures NaN + NaN = NaN and not 0.0
    df_grouped = df_merge.groupby('index_r')\
                        .agg({**{col: "first" for col in keep_columns},
                              **{col: lambda x: x.sum(min_count=1) for col in sum_columns}}).reset_index()
                        
    # Adding billing pivot addresses that did not match to bldg list
    Lmerged_df = pd.merge(df_L, df_match3[['index_l']], on='index_l', how='left', indicator=True)
    newL_rows = Lmerged_df[Lmerged_df['_merge'] == 'left_only'].drop(columns=['_merge', 'full_address'])

    # Adding bldg list addresses that did not match to billing addresses
    Rmerged_df = pd.merge(df_R, df_match3[['index_r']], on='index_r', how='left', indicator=True)
    newR_rows = Rmerged_df[Rmerged_df['_merge'] == 'left_only'].drop(columns=['_merge', 'full_address'])
    
    # Combine matched and unmatched records together
    df_final = pd.concat([df_grouped, newL_rows, newR_rows], axis=0, ignore_index=True)
    df_final2 = df_final.drop(columns=["index_r", "index_l"]).sort_values(["UniqueID"]).replace({None: np.nan, 'None': np.nan})
    
    
    # Write final result to WAD_PRD_Integration.ADDRESS_BILLING.ADDR_BILLING_MASTER
    timed_execution(odbc_write, "write to ADDR_BILLING_MASTER", df_final2, server='WADINFWWAPV02', database='WAD_PRD_Integration', 
        schema='ADDRESS_BILLING', table='ADDR_BILLING_MASTER')