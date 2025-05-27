from odbc import odbc_read, odbc_write
from process_raw_addresses import clean_addresses, parse_addresses
import pandas as pd
import pandas_usaddress as padd
import numpy as np
import time
import logging
import os
import warnings
import sys

warnings.simplefilter(action='ignore', category=FutureWarning)

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))
log_filename = 'Fuzzymatch_Script.log'

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

# Filter to records after Jan 26
target_query = '''SELECT * 
FROM [{database}].[{schema}].[{table}]
WHERE ingestion_timestamp > '2025-01-26'
ORDER BY id;'''

results_query = '''SELECT DISTINCT batch_id
FROM [{database}].[{schema}].[{table}]
WHERE ingestion_timestamp > '2025-01-26'
'''

if __name__ == '__main__':
    # Get all already processed batch_ids
    batch_ids = timed_execution(odbc_read, "Get existing batch_ids -",
        server='WADINFWWDDV01', database='Playground', 
        schema='addressbilling', table='Fuzzymatch_Output', custom_query=results_query)

    # Read in target df -- User Uploaded Addresses
    target0 = timed_execution(
        odbc_read, "Uploaded addresses -", server='WADINFWWDDV01', database='Playground', 
        schema='addressbilling', table='UI_LZ', custom_query=target_query)
    
    # Get indicator to see whether batch_id already exists in the results table
    # Note we are using .merge() instead of .isin() because former has better performance
    target_all = pd.merge(target0, batch_ids, on='batch_id', how='left', indicator=True)
    
    # Filtering down to only unprocessed rows
    target = target_all[target_all['_merge'] == 'left_only'].drop(columns=['_merge'])
    
    if len(target) == 0:
        print("All batch ids already processed.")
        logging.info("All batch ids already processed.")
        sys.exit()
    
    # Read in source df -- ADDR_BILLING_MASTER
    source = timed_execution(
        odbc_read, "Master list -", server='WADINFWWAPV02', database='WAD_PRD_Integration', 
        schema='ADDRESS_BILLING', table='ADDR_BILLING_MASTER')

    # Repointing column names to those used in Jack's code
    target["ADDRESS"] = target["Address1"]
    target["CITY"]    = target["City"]
    target["STATE"]   = target["State"]

    # Jack's code doesn't currently handle zipcode variations well
    # so additional logic used for the zip code

    # Extracting only digits in the column (sometimes leading ZIP_)
    target["ZIP"] = target["Zip"].str.extract('(\d+)', expand=False)
    # Make sure zipcodes are only 5 digits
    target["ZIP"] = target["ZIP"].str[:5]
    # If zipcode is only 4 digits and in state CT, add a leading zero
    target["ZIP"] = np.where((target["STATE"]=="CT") & (target["ZIP"].str.len()==4),
                            "0"+target["ZIP"], target["ZIP"])

    # Prep addresses for fuzzymatching
    df_L, df_R = timed_execution(
        clean_addresses, "Address preparatory cleaning -", target, source)

    # Apply fuzzymatching code 
    df_match = timed_execution(parse_addresses, "Address Fuzzymatch -",
            df_L[["ADDRESS", "CITY", "STATE", "ZIP", "full_address", "index"]].copy(),
            df_R[["ADDRESS", "CITY", "STATE", "ZIP", "full_address", "index", "PRICING_TIER"]].copy())
    
    # Create flags for whether zipcode and post directional match
    df_match["EXACT_MATCH"] = (df_match["full_address_l"] == df_match["full_address_r"])
    df_match["ZIP_MATCH"]   = (df_match["ZIP_l"] == df_match["ZIP_r"])
    df_match["POST_MATCH"]  = (df_match["StreetNamePostDirectional_l"] == df_match["StreetNamePostDirectional_r"])

    # Sort dupes using created flags
    # Dupes in index_l happen when we match to more than one row on the master addr list
    # In this case, we find and return the best match using above flags 
    df_match2 = df_match.sort_values(["index_l", "EXACT_MATCH", "ZIP_MATCH", "POST_MATCH", "PRICING_TIER_r"],
                                    ascending=[True, False, False, False, True])
    
    # Keeping preferred dupe first (e.g. zipcode matches, post matches, lower pricing tier)
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
    
    # Adding back target addresses that did not match to the master list source
    Lmerged_df = pd.merge(df_L, df_match3[['index_l']], on='index_l', how='left', indicator=True)
    newL_rows = Lmerged_df[Lmerged_df['_merge'] == 'left_only'].drop(columns=['_merge', 'full_address'])
    
    # Combine matched and unmatched records together
    df_final = pd.concat([df_merge, newL_rows], axis=0, ignore_index=True)
    
    # Re-ordering and re-naming output columns
    # Standardizing all NULL types as np.nan
    df_final2 = df_final[[
    'batch_id', 'ID', 'ingestion_timestamp', 'user_def_row_ID', 
    'Address1', 'ADDRESS_y', 'City', 'CITY_y', 'State', 'STATE_y', 'Zip',  'ZIP_y',
    'UniqueID', 'PRICING_TIER', 'LIT', 'EthernetLit', 'SWC',
    'WIRELINE_ETH', 'WIRELESS_ETH', 'WHSL_DIA', 'BUS_DIA', 'BB',
    'WAVELENGTH', 'TDM', 'SONET', 'VOICE', 'COLLO']].sort_values(["ID"]).replace({None: np.nan, 'None': np.nan})

    df_final2.columns = \
    ['batch_id', 'ID', 'ingestion_timestamp', 'user_def_row_ID',
    'Input_Address', 'Matched_Address', 'Input_City', 'Matched_City', 
    'Input_State', 'Matched_State', 'Input_Zip', 'Matched_Zip',
    'BLL_UniqueID', 'PRICING_TIER', 'LIT', 'EthernetLit', 'SWC',
    'WIRELINE_ETH', 'WIRELESS_ETH', 'WHSL_DIA', 'BUS_DIA', 'BB',
    'WAVELENGTH', 'TDM', 'SONET', 'VOICE', 'COLLO']
    
    timed_execution(odbc_write, "write to Fuzzymatch_Output", df_final2,
        server='WADINFWWDDV01', database='Playground', 
        schema='addressbilling', table='Fuzzymatch_Output', exists='append')