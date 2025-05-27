# app_AddressBilling/orchestration/ETL/Scorecard_CARS.py

from odbc import odbc_read, odbc_write, _get_server_and_db
import pandas as pd
import pandas_usaddress as padd
import numpy as np
import time
import logging
import os
import warnings

warnings.simplefilter(action='ignore', category=FutureWarning)

script_dir = os.path.dirname(os.path.abspath(__file__))
log_filename = 'Scorecard_CARS_Script.log'
log_file_path = os.path.join(script_dir, log_filename)

logging.basicConfig(filename=log_file_path,
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

print(f"Log file is being written to: {log_file_path}")

sc_query = """
DECLARE @CurrentDate DATE = GETDATE();
DECLARE @FilterDate DATE = DATEADD(DAY, 1 - DAY(@CurrentDate), @CurrentDate);

SELECT 
  DATESTART, WTN, NATRL_ACCT_CD, CUST_SEG_NM,
  ADDRESS, CITY, STATE, ZIPCODE
FROM [{database}].[{schema}].[{table}]
WHERE [DATESTART] = @FilterDate
  AND [WTN] IS NOT NULL
  AND (
      -- Wholesale Ethernet, Broadband, Voice
      (
          CUST_SEG_NM LIKE '%CARRIER%'
          AND (
              -- Ethernet/DIA
              NATRL_ACCT_CD IN ('054','105')
              OR
              -- Broadband
              NATRL_ACCT_CD IN ('102','115','116','120')
              OR
              -- Voice
              NATRL_ACCT_CD IN ('001','002','003','004','005','006','009','013','014')
          )
      )
      OR
      -- SMB/ENT Ethernet
      (
          CUST_SEG_NM IN ('SMALL','ROHO','MEDIUM','LARGE')
          AND NATRL_ACCT_CD IN ('054','105')
      )
  );
"""

cars_query = """
DECLARE @CurrentDate DATE = GETDATE();
DECLARE @FilterDate DATE = DATEADD(MONTH, -1,
                   DATEADD(DAY, 1 - DAY(@CurrentDate), @CurrentDate));

SELECT
  BILL_MONTH,
  BILLED_SVC_ACCS_METHD_NO AS WTN,
  BILL_AMT_TOTAL
FROM [{database}].[{schema}].[{table}]
WHERE [BILL_MONTH] = @FilterDate
  AND [BILLED_SVC_ACCS_METHD_NO] IS NOT NULL
  AND ([CUST_SEG_NM] IN ('SMALL','ROHO','MEDIUM','LARGE')
       OR CUST_SEG_NM LIKE '%CARRIER%');
"""

def timed_execution(func, *args, **kwargs):
    start_time = time.time()
    result = func(*args, **kwargs)
    end_time = time.time()
    elapsed = (end_time - start_time)/60
    logging.info(f"{func.__name__} took {elapsed:.2f} minutes")
    return result

if __name__ == '__main__':
    # 1) Pull Scorecard
    sc = timed_execution(
        odbc_read,
        schema='ADDRESS_BILLING',
        table='SAAFACTFEATUREMONTHLYSNAP_SUM',
        custom_query=sc_query
    )
    logging.info(f"Scorecard rows = {len(sc)}")

    # 2) Pull CARS
    cars = timed_execution(
        odbc_read,
        schema='EDW_VWMC_SEC',
        table='TBL_CUST_ACCT_REV_SUM_HIST',
        custom_query=cars_query
    )
    logging.info(f"CARS rows = {len(cars)}")

    # Product filters
    whsl_DIA_filter = (sc["NATRL_ACCT_CD"].isin(['054','105'])) & (sc["CUST_SEG_NM"].str.contains("CARRIER", na=False))
    bus_DIA_filter  = (sc["NATRL_ACCT_CD"].isin(['054','105'])) & (sc["CUST_SEG_NM"].isin(['ROHO','SMALL','MEDIUM','LARGE']))
    BB_filter       = sc["NATRL_ACCT_CD"].isin(['102','115','116','120'])
    voice_filter    = sc["NATRL_ACCT_CD"].isin(['001','002','003','004','005','006','009','013','014'])

    sc["SEG"] = np.select(
        [whsl_DIA_filter, bus_DIA_filter, BB_filter, voice_filter],
        ["WHSL_DIA", "BUS_DIA", "BB", "VOICE"],
        "MISCEL"
    )
    sc["SEG_ORDER"] = np.select(
        [whsl_DIA_filter, bus_DIA_filter, BB_filter, voice_filter],
        [1,2,3,4],
        5
    )

    # Drop duplicates
    sc2 = sc[["WTN","SEG","SEG_ORDER","ADDRESS","CITY","STATE","ZIPCODE"]].drop_duplicates()
    sc2 = sc2.dropna(subset=["WTN","ADDRESS"])

    # Sort so that if a WTN has multiple SEG types, we pick the smallest order
    sc3 = sc2.sort_values(["WTN","SEG_ORDER"], ascending=[True,True])\
             .drop_duplicates(["WTN"], keep='first')

    # handle cars
    cars["BILL_AMT_TOTAL"] = cars["BILL_AMT_TOTAL"].astype(float)
    sc3["WTN"] = sc3["WTN"].astype(str).str.rstrip('.0')
    cars["WTN"] = cars["WTN"].astype(str).str.rstrip('.0')

    cars2 = cars.groupby("WTN")["BILL_AMT_TOTAL"].sum().to_frame("TOTAL_MRC").reset_index()
    sc_cars = sc3.merge(cars2, on="WTN", how='inner')

    df = sc_cars[[
        'WTN','SEG','ADDRESS','CITY','STATE','ZIPCODE','TOTAL_MRC'
    ]].copy()
    df.columns = [
        'WTN','SEG','FINAL_ADDRESS','FINAL_CITY','FINAL_STATE','FINAL_ZIP','TOTAL_MRC'
    ]

    # Standardize addresses => pivot => write
    df2 = padd.tag(
        df,
        ['FINAL_ADDRESS','FINAL_CITY','FINAL_STATE','FINAL_ZIP'],
        granularity='low',
        standardize=True
    )

    df2["ADDRESS"] = (df2["AddressNumber"] + " " + df2["StreetTag"]).str.upper()
    df2["CITY"]    = df2["PlaceName"].str.upper()
    df2["STATE"]   = df2["StateName"].str.upper()
    df2["ZIP"]     = df2["ZipCode"].str.upper()

    df2["ZIP"] = df2["ZIP"].str[:5]
    df2["ZIP"] = np.where(
        (df2["STATE"]=="CT") & (df2["ZIP"].str.len()==4),
        "0"+df2["ZIP"],
        df2["ZIP"]
    )

    agg = df2.pivot_table(
        values=["TOTAL_MRC"],
        index=['ADDRESS','CITY','STATE','ZIP'],
        columns=["SEG"],
        aggfunc="sum"
    ).reset_index()

    agg.columns = np.concatenate((
        agg.columns.get_level_values(0)[:4],
        agg.columns.get_level_values(1)[4:]
    ))

    logging.info(f"{len(agg)} rows => CARS_ADDR_PRD_PIVOT")

    timed_execution(
        odbc_write,
        agg,
        schema='ADDRESS_BILLING',
        table='CARS_ADDR_PRD_PIVOT',
        exists='replace'
    )
