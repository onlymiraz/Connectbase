from odbc import odbc_read, odbc_write
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
log_filename = 'Scorecard_CARS_Script.log'

# Set the log file path to be in the same directory as the script
log_file_path = os.path.join(script_dir, log_filename)

# Set up logging
logging.basicConfig(filename=log_file_path, level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Print the absolute path of the log file
print(f"Log file is being written to: {log_file_path}")

sc_query =\
"""
DECLARE @CurrentDate DATE = GETDATE();
DECLARE @FilterDate DATE = DATEADD(DAY, 1 - DAY(@CurrentDate), @CurrentDate);

SELECT 
DATESTART, WTN, NATRL_ACCT_CD, CUST_SEG_NM, ADDRESS, CITY, STATE, ZIPCODE
FROM [{database}].[{schema}].[{table}]
WHERE [DATESTART] = @FilterDate AND [WTN] IS NOT NULL
AND (
    -- Wholesale Ethernet, Broadband, Voice
    (
        CUST_SEG_NM LIKE '%CARRIER%'
        AND (
            -- Ethernet/DIA
            NATRL_ACCT_CD IN ('054', '105')
            OR
            -- Broadband
            NATRL_ACCT_CD IN ('102', '115', '116', '120')
            OR
            -- Voice
            NATRL_ACCT_CD IN ('001', '002', '003', '004', '005', '006', '009', '013', '014')
        )
    )
    OR
    -- SMB/ENT Ethernet
    (
        CUST_SEG_NM IN ('SMALL', 'ROHO', 'MEDIUM', 'LARGE')
        -- Ethernet/DIA
        AND NATRL_ACCT_CD IN ('054', '105')
    )
)
"""

cars_query =\
"""
DECLARE @CurrentDate DATE = GETDATE();
DECLARE @FilterDate DATE = DATEADD(MONTH, -1, DATEADD(DAY, 1 - DAY(@CurrentDate), @CurrentDate));

SELECT
BILL_MONTH,
BILLED_SVC_ACCS_METHD_NO AS WTN,
BILL_AMT_TOTAL

FROM [{database}].[{schema}].[{table}]
WHERE [BILL_MONTH] = @FilterDate AND [BILLED_SVC_ACCS_METHD_NO] IS NOT NULL
AND  ([CUST_SEG_NM] IN ('SMALL', 'ROHO', 'MEDIUM', 'LARGE') OR CUST_SEG_NM LIKE '%CARRIER%')
"""

if __name__ == '__main__':
    
    start_time = time.time()
    # Load in Scorecard
    #sc_cd = "../../OneDrive - Frontier Communications/SQL_Pulls/Scorecard/"
    #sc    = pd.read_csv(sc_cd + "2025-01-ALL.txt", sep="|", quoting=3, dtype=str)

    sc = odbc_read(server='WADINFWWAPV02', database='WAD_PRD_02', 
                schema='ADDRESS_BILLING', table='SAAFACTFEATUREMONTHLYSNAP_SUM', 
                custom_query=sc_query)
    end_time = time.time()
    elapsed_time = (end_time - start_time) / 60

    logging.info(f"Scorecard: {elapsed_time:.2f} minutes to pull for month = {sc['DATESTART'].unique()}")
    
    
    start_time = time.time()
    # Load in CARS
    # cars_cd = "../../OneDrive - Frontier Communications/SQL_Pulls/CARs_pipe/"
    # cars = pd.read_csv(cars_cd + "2024-12-WS.txt",  sep="|", quoting=3, dtype=str)
    cars = odbc_read(server='WADINFWWAPV02', database='WAD_PRD_02', 
                schema='EDW_VWMC_SEC', table='TBL_CUST_ACCT_REV_SUM_HIST', 
                custom_query=cars_query)

    end_time = time.time()
    elapsed_time = (end_time - start_time) / 60

    logging.info(f"CARS: {elapsed_time:.2f} minutes to pull for month = {cars['BILL_MONTH'].unique()}")
    
    
     # --Product filters
    whsl_DIA_filter   = (sc["NATRL_ACCT_CD"].isin(['054', '105'])) &\
                        (sc["CUST_SEG_NM"].str.contains("CARRIER", na=False))

    bus_DIA_filter    = (sc["NATRL_ACCT_CD"].isin(['054', '105'])) &\
                        (sc["CUST_SEG_NM"].isin(['ROHO','SMALL','MEDIUM','LARGE']))

    BB_filter         = (sc["NATRL_ACCT_CD"].isin(['102', '115', '116', '120']))

    voice_filter      = (sc["NATRL_ACCT_CD"].isin(['001', '002', '003', '004', '005',
                                                   '006', '009', '013', '014'])) 
    
    # Assigning product segment filters
    sc["SEG"] = np.select(
        [whsl_DIA_filter, bus_DIA_filter, BB_filter, voice_filter],
        ["WHSL_DIA", "BUS_DIA", "BB", "VOICE"],
        "MISCEL")

    # Creating ranking for dropping duplicates
    sc["SEG_ORDER"] = np.select(
        [whsl_DIA_filter, bus_DIA_filter, BB_filter, voice_filter],
        [1, 2, 3, 4],
        5)
    
    # Dropping duplicates and nulls
    sc2 = sc[["WTN", "SEG", "SEG_ORDER", "ADDRESS", "CITY", "STATE", "ZIPCODE"]]\
        .drop_duplicates().dropna(subset=["WTN", "ADDRESS"])
        
    # A WTN can match to both BB and voice. When this happens, we label it as BB only.
    sc3 = sc2.sort_values(["WTN", "SEG_ORDER"], ascending=True)\
         .drop_duplicates(["WTN"], keep='first')
    
    # Make sure MRC is float
    cars["BILL_AMT_TOTAL"] = cars["BILL_AMT_TOTAL"].astype(float)

    # Make sure WTNs are strings
    sc3["WTN"]   = sc3["WTN"].astype(str).str.rstrip('.0')
    cars["WTN"]  = cars["WTN"].astype(str).str.rstrip('.0')

    # Aggregating MRC by WTN 
    cars2 = cars.groupby(["WTN"])["BILL_AMT_TOTAL"].sum().to_frame("TOTAL_MRC").reset_index()
    
    # We drop any rows found not to be billing
    sc_cars = sc3.merge(cars2, on=["WTN"], how='inner')
    
    # Getting needed columns only
    df = sc_cars[['WTN', 'SEG', 'ADDRESS', 'CITY', 'STATE', 'ZIPCODE', 'TOTAL_MRC']].copy()
    df.columns = ['WTN', 'SEG', 'FINAL_ADDRESS', 'FINAL_CITY', 'FINAL_STATE', 'FINAL_ZIP', 'TOTAL_MRC']
    
    # Standardize addresses using usaddress library for preliminary grouping
    df2 = padd.tag(df, ['FINAL_ADDRESS', 'FINAL_CITY', 'FINAL_STATE', 'FINAL_ZIP'], 
                   granularity='low', standardize=True)
    
    df2["ADDRESS"]      = (df2["AddressNumber"] + " " + df2["StreetTag"]).str.upper()
    df2["CITY"]         = (df2["PlaceName"]).str.upper()
    df2["STATE"]        = (df2["StateName"]).str.upper()
    df2["ZIP"]          = (df2["ZipCode"]).str.upper()
    
    # Make sure zipcodes are only 5 digits
    df2["ZIP"] = df2["ZIP"].str[:5]

    # If zipcode is only 4 digits and in state CT, add a leading zero
    df2["ZIP"] = np.where((df2["STATE"]=="CT") & (df2["ZIP"].str.len()==4),
                            "0"+df2["ZIP"], df2["ZIP"])
    
    # Creating pivot table by product and address
    agg = df2.pivot_table(values=["TOTAL_MRC"], index=['ADDRESS', 'CITY', 'STATE', 'ZIP'], 
                      columns=["SEG"], aggfunc="sum").reset_index()

    # Convert back to single-indexed DF 
    agg.columns = np.concatenate((agg.columns.get_level_values(0)[:4],
                agg.columns.get_level_values(1)[4:]))
    
    # Write result to SQL server    
    start_time = time.time()

    odbc_write(agg, "WADINFWWAPV02", "WAD_PRD_Integration", "ADDRESS_BILLING", "CARS_ADDR_PRD_PIVOT")
    end_time = time.time()
    elapsed_time = (end_time - start_time) / 60

    logging.info(f"{len(agg)} rows witten to CARS_ADDR_PRD_PIVOT in {elapsed_time:.2f} minutes")