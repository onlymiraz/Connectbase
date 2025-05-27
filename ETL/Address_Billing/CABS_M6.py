from odbc import odbc_read, odbc_write
import pandas as pd
import pandas_usaddress as padd
import numpy as np
import time
import logging
import os
import warnings
import databricks.sql
from fuzzywuzzy import fuzz

warnings.simplefilter(action='ignore', category=FutureWarning)

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))
log_filename = 'CABS_M6_Script.log'

# Set the log file path to be in the same directory as the script
log_file_path = os.path.join(script_dir, log_filename)

# Set up logging
logging.basicConfig(filename=log_file_path, level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Print the absolute path of the log file
print(f"Log file is being written to: {log_file_path}")

cabs_query =\
'''
WITH FilterDate AS (
  SELECT ADD_MONTHS(CURRENT_DATE - DAYOFMONTH(CURRENT_DATE) + 1, -1) AS date
  ),

  CABS_SPCL_AGGR AS (
        SELECT
            CIRCUIT_NO,
            BILL_MONTH_DT,
            CMPY_NO,
            MAX(PLAN_ID) AS PLAN_ID,
            SUM(CHRGE_AMT) AS TOTAL_MRC
        FROM
            it_gold_prod.billing.cabs_spcl_accs_bill_rev_dtl_v
        WHERE
            SW_SPL_IND = 'SP'
        GROUP BY
            CIRCUIT_NO,
            BILL_MONTH_DT,
            CMPY_NO
    ),

 CABS_MILEAGE_AGGR AS (
        SELECT
            CABS2.CIRCUIT_NO,
            CABS2.BILL_MONTH_DT,
            CABS2.CMPY_NO,
            SUM(CABS2.CHRGE_AMT) AS MILEAGE_MRC
        FROM
            it_gold_prod.billing.cabs_spcl_accs_bill_rev_dtl_v CABS2
            INNER JOIN wholesale.data_load_wholesale.cm_usoc_ethernet_type4 USOC2 ON CABS2.USOC_PRODUCT_CD = USOC2.USOC
            AND SUBSTR(USOC2.CHARGE_TYPE, 1, 7) = 'Mileage'
        GROUP BY
            CABS2.CIRCUIT_NO,
            CABS2.BILL_MONTH_DT,
            CABS2.CMPY_NO
    ),

CABSSP AS (
    SELECT DISTINCT
        SUBQ1.CIRCUIT_NO,
        SUBQ1.CMPY_NO,
        SUBQ1.STATE,
        SUBQ1.BILL_MONTH_DT,
        COUNT(SUBQ1.CMPY_NO) OVER (
            PARTITION BY
                SUBQ1.CIRCUIT_NO,
                SUBQ1.BILL_MONTH_DT
        ) AS CMPY_NO_COUNT
    FROM
        (
            SELECT DISTINCT
                CABS0.CIRCUIT_NO,
                CABS0.CMPY_NO,
                CASE
                    WHEN CABS0.STATE_CD IN (
                        'AL', 'AZ', 'CA', 'CT', 'FL', 'GA', 'IA', 'ID', 'IL', 'IN',
                        'MI', 'MN', 'MS', 'MT', 'NC', 'NE', 'NM', 'NV', 'NY', 'OH',
                        'OR', 'PA', 'SC', 'TN', 'TX', 'UT', 'WA', 'WI', 'WV'
                    ) THEN CABS0.STATE_CD
                    WHEN SUBSTR(CABS0.EO_CLLI_CD, 5, 2) IN (
                        'AL', 'AZ', 'CA', 'CT', 'FL', 'GA', 'IA', 'ID', 'IL', 'IN',
                        'MI', 'MN', 'MS', 'MT', 'NC', 'NE', 'NM', 'NV', 'NY', 'OH',
                        'OR', 'PA', 'SC', 'TN', 'TX', 'UT', 'WA', 'WI', 'WV'
                    ) THEN SUBSTR(CABS0.EO_CLLI_CD, 5, 2)
                    WHEN SUBSTR(CABS0.POP_CLLI_CD, 5, 2) IN (
                        'AL', 'AZ', 'CA', 'CT', 'FL', 'GA', 'IA', 'ID', 'IL', 'IN',
                        'MI', 'MN', 'MS', 'MT', 'NC', 'NE', 'NM', 'NV', 'NY', 'OH',
                        'OR', 'PA', 'SC', 'TN', 'TX', 'UT', 'WA', 'WI', 'WV'
                    ) THEN SUBSTR(CABS0.POP_CLLI_CD, 5, 2)
                    WHEN SUBSTR(CABS0.CIRCUIT_NO, 18, 2) IN (
                        'AL', 'AZ', 'CA', 'CT', 'FL', 'GA', 'IA', 'ID', 'IL', 'IN',
                        'MI', 'MN', 'MS', 'MT', 'NC', 'NE', 'NM', 'NV', 'NY', 'OH',
                        'OR', 'PA', 'SC', 'TN', 'TX', 'UT', 'WA', 'WI', 'WV'
                    ) THEN SUBSTR(CABS0.CIRCUIT_NO, 18, 2)
                    WHEN CABS0.STATE_CD IS NULL
                    OR CABS0.EO_CLLI_CD IS NULL
                    OR CABS0.POP_CLLI_CD IS NULL
                    OR CABS0.CIRCUIT_NO IS NULL THEN 'OTHER'
                    ELSE 'OTHER'
                END AS STATE,
                CABS0.BILL_MONTH_DT
            FROM
                it_gold_prod.billing.cabs_spcl_accs_bill_rev_dtl_v CABS0
            WHERE
                CABS0.BILL_MONTH_DT = (SELECT date FROM FilterDate)
                AND (
                    CABS0.SW_SPL_IND = 'SP'
                    OR SUBSTR(CABS0.NC_PRODUCT_CD, 1, 4) IN ('COLL', 'COLO')
                )
        ) SUBQ1
    WHERE
        CMPY_NO NOT IN ('0570', '0572', '0576', '6102', '6105', '6106')
),

FIRST_BILL_CTE AS (
  SELECT CIRCUIT_NO, BILL_MONTH_DT,
    CASE 
      WHEN BILL_MONTH_DT = MIN(BILL_MONTH_DT) OVER (PARTITION BY CIRCUIT_NO 
        ORDER BY BILL_MONTH_DT 
        RANGE BETWEEN INTERVAL 1 MONTH PRECEDING AND CURRENT ROW)
      THEN BILL_MONTH_DT 
      ELSE NULL 
    END AS FIRST_BILL_MONTH_DT
  FROM it_gold_prod.billing.cabs_spcl_accs_bill_rev_dtl_v
  WHERE SW_SPL_IND = 'SP'
),

LAST_BILL_CTE AS (
  SELECT CIRCUIT_NO, BILL_MONTH_DT,
    CASE 
      WHEN BILL_MONTH_DT = MAX(BILL_MONTH_DT) OVER (PARTITION BY CIRCUIT_NO 
        ORDER BY BILL_MONTH_DT 
        RANGE BETWEEN CURRENT ROW AND INTERVAL 1 MONTH FOLLOWING)
      THEN BILL_MONTH_DT 
      ELSE NULL 
    END AS LAST_BILL_MONTH_DT
  FROM it_gold_prod.billing.cabs_spcl_accs_bill_rev_dtl_v
  WHERE SW_SPL_IND = 'SP'
),


SUBQ2 AS (
  SELECT DISTINCT
    CABSSP.CMPY_NO,
    
    CMA.MILEAGE_MRC,
    --MAX(TIER) OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT) AS CABS_TIER,
    --MAX(CASE WHEN TIER = '   ' THEN NULL ELSE TIER END) OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT) AS CABS_TIER,
    MAX(CASE WHEN TRIM(TIER) = '' THEN NULL ELSE TIER END) 
OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT) AS TIER,


    CABSSP.CMPY_NO_COUNT, CABSSP.STATE, CABS.ACTLCLLI, CABS.CIRCUIT_NO, CABS.NC_PRODUCT_CD, 
    CABS.BILL_MONTH_DT, CABS.ACNA, CABS.JURIS_CD,
    CABS.ADDR, CABS.CUST, CABS.IXC_NAME, CABS.EO_CLLI_CD AS SWC, CABS.INSTALL_DT, CABS.DISCONNECT_DT, 
    CABS.TERM_START_DT, CABS.TERM_END_DT, CABS.SW_SPL_IND, CABS.NCI,
    
COALESCE(MCL.PRIMARY_CARRIER_NM, 'UNKNOWN') AS PRIMARY_CARRIER_NAME,
    CASE WHEN MCL.PRIMARY_FOCUS = 'WIRELESS' THEN 'WIRELESS' ELSE 'WIRELINE' END AS WIRELESS,
    CASE 
      WHEN MAX(USOC3.CHARGE_TYPE) OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT) = 'NNI' THEN 'ETH_NNI'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 1) = 'K' THEN 'ETH_UNI'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 2) = 'SN' THEN 'ETH_NNI'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 2) = 'VL' THEN 'ETH_EVC'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 1) = 'O' THEN 'OCN'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 2) = 'HF' AND SUBSTRING(CABS.NC_PRODUCT_CD, 4, 1) NOT IN ('-', ' ') 
        AND LENGTH(CABS.NC_PRODUCT_CD) = 4 THEN 'TDM_DS3_mux'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 2) = 'HC' AND SUBSTRING(CABS.NC_PRODUCT_CD, 4, 1) NOT IN ('-', ' ') 
        AND LENGTH(CABS.NC_PRODUCT_CD) = 4 THEN 'TDM_DS1_mux'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 2) = 'HF' AND LENGTH(CABS.CIRCUIT_NO) > 27 THEN 'TDM_DS3_noEU'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 2) = 'HC' AND LENGTH(CABS.CIRCUIT_NO) > 27 THEN 'TDM_DS1_noEU'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 2) = 'HF' THEN 'TDM_DS3'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 2) = 'HC' THEN 'TDM_DS1'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 4) = 'COLL' THEN 'COLLO_REG'
      WHEN SUBSTRING(CABS.NC_PRODUCT_CD, 1, 4) = 'COLO' THEN 'COLLO_NONREG'     
      ELSE 'OTHER' 
    END AS SVC_GROUP,
    MAX(USOC.PRODUCT) OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT) AS PRODUCT,
    MAX(USOC.ETHERNET_TYPE) OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT) AS ETHERNET_TYPE, 
    --MAX(USOC2.MBPS) OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT) AS EVC_MBPS, 
    CASE 
  WHEN MAX(CASE WHEN USOC2.MBPS = '?' THEN NULL ELSE USOC2.MBPS END) OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT) IS NULL THEN NULL
  ELSE MAX(CAST(CASE WHEN USOC2.MBPS = '?' THEN NULL ELSE USOC2.MBPS END AS DECIMAL(18,2))) OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT)
END AS EVC_MBPS,

    MAX(USOC3.CHARGE_TYPE) OVER (PARTITION BY CABS.CIRCUIT_NO, CABS.BILL_MONTH_DT) AS NNI, 
    CSA.PLAN_ID,
    CSA.TOTAL_MRC,   
    FBC.FIRST_BILL_MONTH_DT,
    LBC.LAST_BILL_MONTH_DT   
    FROM CABSSP
  INNER JOIN it_gold_prod.billing.cabs_spcl_accs_bill_rev_dtl_v CABS 
    ON CABSSP.CIRCUIT_NO = CABS.CIRCUIT_NO AND CABSSP.CMPY_NO = CABS.CMPY_NO  
  
  LEFT JOIN FIRST_BILL_CTE FBC
    ON CABS.CIRCUIT_NO = FBC.CIRCUIT_NO AND CABS.BILL_MONTH_DT = FBC.BILL_MONTH_DT
  LEFT JOIN LAST_BILL_CTE LBC
    ON CABS.CIRCUIT_NO = LBC.CIRCUIT_NO AND CABS.BILL_MONTH_DT = LBC.BILL_MONTH_DT
  LEFT JOIN CABS_MILEAGE_AGGR CMA ON CABS.CIRCUIT_NO = CMA.CIRCUIT_NO
            AND CABS.BILL_MONTH_DT = CMA.BILL_MONTH_DT
            AND CABS.CMPY_NO = CMA.CMPY_NO  
   LEFT OUTER JOIN wholesale.data_load_wholesale.cm_usoc_ethernet_type4 USOC ON CABS.USOC_PRODUCT_CD = USOC.USOC
            AND SUBSTR(USOC.CHARGE_TYPE, 1, 9) <> 'Mileage -'
            LEFT OUTER JOIN wholesale.data_load_wholesale.cm_usoc_ethernet_type4 USOC2 ON CABS.USOC_PRODUCT_CD = USOC2.USOC
            AND SUBSTR(USOC2.CHARGE_TYPE, 1, 9) <> 'Mileage -'
            LEFT OUTER JOIN wholesale.data_load_wholesale.cm_usoc_ethernet_type4 USOC3 ON CABS.USOC_PRODUCT_CD = USOC3.USOC
            AND USOC3.CHARGE_TYPE = 'NNI'
            LEFT OUTER JOIN wholesale.gold.mcl_v MCL ON CABS.ACNA = MCL.SECONDARY_ID   
            LEFT OUTER JOIN CABS_SPCL_AGGR CSA ON CABS.CIRCUIT_NO = CSA.CIRCUIT_NO
            AND CABS.BILL_MONTH_DT = CSA.BILL_MONTH_DT
            AND CABS.CMPY_NO = CSA.CMPY_NO

  
  WHERE
    CABS.BILL_MONTH_DT = (SELECT date FROM FilterDate)
    AND (SUBSTRING(CABS.NC_PRODUCT_CD, 1, 1) IN ('K', 'O') 
      OR SUBSTRING(CABS.NC_PRODUCT_CD, 1, 2) IN ('HF', 'HC', 'VL', 'SN', 'LX')
      OR SUBSTRING(CABS.NC_PRODUCT_CD, 1, 4) IN ('COLL', 'COLO'))
    AND CABS.ACNA NOT IN ('BLI', 'CQV', 'CZJ', 'CZX', 'EPX', 'FLR', 'FLX', 'FTR', 'GOV', 'SUV', 'ZWV', 'ZZZ',
                          'FIS', 'W05', 'ANV', 'FCA', 'GVN', 'ZAP', 'GSW', 'WBY', 'CUS', 'VZN',
                          'AF1', 'CXN', 'EXC', 'FBA', 'T05', 'WWW', 'ZTK')
),

FINAL_SELECT AS (
  SELECT
    REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(SUBQ2.CIRCUIT_NO, '\\.', ''), '-', ''), ' ', '') AS CLEAN_ID,
    SUBQ2.CMPY_NO, SUBQ2.CMPY_NO_COUNT, SUBQ2.STATE, SUBQ2.CIRCUIT_NO, SUBQ2.NC_PRODUCT_CD, SUBQ2.NCI, 
    SUBQ2.BILL_MONTH_DT, SUBQ2.ACNA, SUBQ2.JURIS_CD, 
    SUBQ2.TOTAL_MRC, SUBQ2.PRIMARY_CARRIER_NAME, SUBQ2.PLAN_ID, SUBQ2.WIRELESS, SUBQ2.TIER,
    CASE 
      WHEN (SUBQ2.STATE <> 'CT' AND SUBQ2.NNI = 'NNI') THEN 'ETH_NNI'
      WHEN (SUBQ2.STATE = 'CT' AND SUBSTRING(SUBQ2.NC_PRODUCT_CD,1,2) IN ('KD','KE','KF','KG','KJ','KP','KQ','KR','KS','KU','SN')
        AND SUBSTRING(SUBQ2.NC_PRODUCT_CD,4,1) IN ('0','-') 
        AND SUBQ2.ACTLCLLI <> 'UNKNOWN' 
        AND SUBQ2.ACTLCLLI <> 'ZZZZZZZZZZZ' 
        AND REGEXP_REPLACE(SUBQ2.ACTLCLLI,' ','') <> ''
        AND SUBSTRING(SUBQ2.ACTLCLLI,1,4) <> 'CUST' 
        AND SUBQ2.PRODUCT <> 'GIGA,DECA,WAVE') THEN 'ETH_NNI'
      ELSE SUBQ2.SVC_GROUP 
    END AS SVC_GROUP,
    COALESCE(SUBQ2.PRODUCT, 
      CASE 
        WHEN SUBSTRING(SUBQ2.SVC_GROUP,1,3) IN ('TDM','OCN') THEN 'TDM/OCN'
        WHEN SUBSTRING(SUBQ2.SVC_GROUP,1,5) = ('COLLO') THEN SUBQ2.SVC_GROUP
        ELSE 'UNKNOWN' 
      END
    ) AS PRODUCT, 
    COALESCE(SUBQ2.ETHERNET_TYPE,'UNKNOWN') AS ETHERNET_TYPE, 
    CASE 
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KD' THEN 10
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KE' THEN 100
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KF' THEN 1000
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KG' THEN 10000
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KJ' THEN 100000
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KP' THEN 10
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KQ' THEN 100
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KR' THEN 1000
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KS' THEN 10000     
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) = 'KU' THEN 100000     
      ELSE NULL 
    END AS UNI_MBPS,
    CASE 
      WHEN SUBSTRING(SUBQ2.CIRCUIT_NO,4,2) IN ('KP','KQ','KR','KS','KU') THEN 'Adj' 
      ELSE NULL 
    END AS ADJ,
    CASE 
      WHEN SUBQ2.SVC_GROUP = 'ETH_EVC' THEN SUBQ2.EVC_MBPS 
      ELSE NULL 
    END AS EVC_MBPS, 
    SUBQ2.NNI, 
    SUBQ2.FIRST_BILL_MONTH_DT, SUBQ2.LAST_BILL_MONTH_DT, SUBQ2.MILEAGE_MRC,
    SUBQ2.ADDR, SUBQ2.CUST, SUBQ2.IXC_NAME, SUBQ2.SWC, SUBQ2.INSTALL_DT, SUBQ2.DISCONNECT_DT, SUBQ2.TERM_START_DT, SUBQ2.TERM_END_DT, SUBQ2.SW_SPL_IND,
    ROW_NUMBER() OVER (PARTITION BY CIRCUIT_NO ORDER BY CMPY_NO) AS ROWNUM
  FROM SUBQ2
)

SELECT * FROM FINAL_SELECT
WHERE BILL_MONTH_DT = (SELECT date FROM FilterDate)
ORDER BY CIRCUIT_NO, CMPY_NO
'''

M6_query =\
'''
SELECT
[ROW_NUM], [CLEAN_ID], [LAST_MODIFIED_DATE] ,[DOCUMENT_NUMBER],
[LOC1],[LOC1_NAME],[LOC1_ADDR_LN1],[LOC1_CITY],[LOC1_STATE],[LOC1_ZIP],
[LOC2],[LOC2_NAME],[LOC2_ADDR_LN1],[LOC2_CITY],[LOC2_STATE],[LOC2_ZIP],
[EUNAME],[EU_ADDRESS],[EU_CITY],[EU_STATE],[EU_ZIP],[SWC_CLLI],
[SECLOC_EU_ADDRESS],[SECLOC_CITY],[SECLOC_STATE]

FROM [{database}].[{schema}].[{table}]
'''

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


if __name__ == '__main__':
    # Use Databricks to pull CABS
    server_hostname = "dbc-4ee5e339-1e79.cloud.databricks.com"
    http_path = "/sql/1.0/warehouses/2f1507bc956f934c"
    access_token = "dapi188e425a6f70670ad421c4d06a9088c6"

    start_time = time.time()

    connection = databricks.sql.connect(
        server_hostname=server_hostname,
        http_path=http_path,
        access_token=access_token
    )

    cursor = connection.cursor()
    cursor.execute(cabs_query)
    result = cursor.fetchall()

    # Get column names
    columns = [desc[0] for desc in cursor.description]

    # Load into pandas DataFrame
    cabs = pd.DataFrame(result, columns=columns)

    cursor.close()
    connection.close()

    end_time = time.time()
    elapsed_time = (end_time - start_time) / 60

    logging.info(f"CABS: {elapsed_time:.2f} minutes to pull for month = {cabs['BILL_MONTH_DT'].unique()}")
    
    # Re-defining CLEAN_ID because empty from databricks pull
    cabs["CLEAN_ID"] = cabs["CIRCUIT_NO"].str.replace(".", "").str.replace(" ", "").str.replace("-", "")
    
    m6 = timed_execution(
        odbc_read, "M6 ADDRESSES -", server='WADINFWWAPV02', database='WAD_PRD_02', 
        schema='ADDRESS_BILLING', table='M6_ADDRESSES', custom_query=M6_query)    
    
    # Sorting records
    cabs["BILL_MONTH_DT"] = pd.to_datetime(cabs['BILL_MONTH_DT'])
    # Make sure MRC is float type
    cabs["TOTAL_MRC"] = cabs["TOTAL_MRC"].astype(float)
    
    # --Product filters
    ethernet_filter   = (cabs["ETHERNET_TYPE"] == 'Switched Ethernet')

    TDM_filter        = (cabs["SVC_GROUP"].isin(['TDM_DS1', 'TDM_DS1_mux', 'TDM_DS1_noEU', 
                                                'TDM_DS3', 'TDM_DS3_mux', 'TDM_DS3_noEU']))
                        
    SONET_filter      = (cabs["PRODUCT"] == 'ETH OVER SONET')

    wavelength_filter = ((cabs["ETHERNET_TYPE"] == 'Dedicated Ethernet') | (cabs["SVC_GROUP"]=="OCN")) &\
                        (cabs["PRODUCT"] != 'ETH OVER SONET')
                        
    dark_filter       = (cabs["ETHERNET_TYPE"] == 'Dark Fiber')
                        
    COLLO_filter      = (cabs["ETHERNET_TYPE"].str.contains("COLLO", na=False)) |\
                        (cabs["PRODUCT"].str.contains("COLLO", na=False))
                        
    # --Wireline vs wireless filter                    
    wireline_filter   = (cabs["WIRELESS"]=="WIRELINE")
    
    cabs["SEG"] = np.select(
        [(ethernet_filter) & (wireline_filter), (ethernet_filter) & ~(wireline_filter),
        TDM_filter, wavelength_filter, SONET_filter, dark_filter, COLLO_filter, wireline_filter, ~wireline_filter],
        ["WIRELINE_ETH", "WIRELESS_ETH", "TDM", "WAVELENGTH", "SONET", 
        "DARK_FIBER", "COLLO", "WIRELINE_ETH", "WIRELESS_ETH"],
        "MISCEL")
    
    cabs_m6 = pd.merge(cabs, m6, on=["CLEAN_ID"], how='left')
    cabs_m6["LAST_MODIFIED_DATE"] = pd.to_datetime(cabs_m6['LAST_MODIFIED_DATE'])
    
    # Cleaning string formatting of M6 Address columns

    columns_to_strip = [
        "EUNAME", "EU_ADDRESS", "EU_CITY", "EU_STATE", "EU_ZIP",
        "LOC1_NAME", "LOC1_ADDR_LN1", "LOC1_CITY", "LOC1_STATE", "LOC1_ZIP",
        "LOC2_NAME", "LOC2_ADDR_LN1", "LOC2_CITY", "LOC2_STATE", "LOC2_ZIP",
        "SECLOC_EU_ADDRESS", "SECLOC_CITY", "SECLOC_STATE"]

    for col in columns_to_strip:
        # Stripping any leading or trailing white spaces and dashes
        # multiple spaces, tabs, and newlines are changed into a single space
        cabs_m6[col] = cabs_m6[col].str.strip().str.strip('-').str.replace(r'\s+', ' ', regex=True)
        
        # replace empty strings as null
        cabs_m6[col] = cabs_m6[col].replace('', np.nan)
        
    # Creating scoring based on non-null address columns
    # EU is the most definitive end user address, so highest score assigned
    cabs_m6["ADDR_SCORE"] = np.where(~cabs_m6["EU_ADDRESS"].isnull(), 10, 0) + \
                            np.where(~cabs_m6["SECLOC_EU_ADDRESS"].isnull(), 5, 0) + \
                            np.where(~cabs_m6["LOC1_ADDR_LN1"].isnull(), 2, 0) + \
                            np.where(~cabs_m6["LOC2_ADDR_LN1"].isnull(), 2, 0) 

    # Drop address duplicates if CLEAN_ID repeated, keeping the top record
    # Ascending=False sorts the highest addr_score, most recent record, 
    # highest MRC, at the top
    cabs_m6f = cabs_m6.sort_values(["ADDR_SCORE", "LAST_MODIFIED_DATE", "TOTAL_MRC"], ascending=False)\
                    .drop_duplicates(["CLEAN_ID"], keep='first')
                    
                    
    # Handling cases where EU Address is null

    # Prefentially select order by EU -> SECLOC -> LOC2 -> LOC1

    # This flag cabs_m6f["LOC2"].str.len().isin([8, 11]) means
    # see if this NAME field is populated with a CLLI8 or CLLI11 instead of an actual business name

    conds_addr = [ # Always pick EU field first if not null
        ~cabs_m6f["EU_ADDRESS"].isnull(),
        
                # Pick SECLOC field if not NNI (NNIs should map to CO/POI level, not EU)
        (~cabs_m6f["SECLOC_EU_ADDRESS"].isnull()) & (cabs_m6f["SVC_GROUP"] != "ETH_NNI"),
        
                # Pick LOC2 if not CLLI8/11 address
        (~cabs_m6f["LOC2_ADDR_LN1"].isnull()) & (cabs_m6f["LOC2_CITY"] != "UNKNOWN") &\
        (~cabs_m6f["LOC2"].str.len().isin([8, 11])),   
        
                # Pick LOC1 if not CLLI8/11 address
        (~cabs_m6f["LOC1_ADDR_LN1"].isnull()) & (cabs_m6f["LOC1_CITY"] != "UNKNOWN") &\
        (~cabs_m6f["LOC1"].str.len().isin([8, 11])),
        
                # If options exhausted, just pick LOC2 or LOC1 regardless
        ~cabs_m6f["LOC2_ADDR_LN1"].isnull() & (cabs_m6f["LOC2_CITY"] != "UNKNOWN"), 
        ~cabs_m6f["LOC1_ADDR_LN1"].isnull()]       

    cabs_m6f["FINAL_FLAG"] = np.select(conds_addr, [ "EU", "SECLOC", "LOC2", "LOC1", "LOC2", "LOC1"], "UNAVAILABLE")

    cabs_m6f["FINAL_NAME"] = np.select(conds_addr, [ cabs_m6f["EUNAME"], np.nan, 
                                                    cabs_m6f["LOC2_NAME"], cabs_m6f["LOC1_NAME"], 
                                                    cabs_m6f["LOC2_NAME"], cabs_m6f["LOC1_NAME"] ], np.nan)

    cabs_m6f["FINAL_ADDRESS"] = np.select(conds_addr, [ cabs_m6f["EU_ADDRESS"],    cabs_m6f["SECLOC_EU_ADDRESS"],
                                                        cabs_m6f["LOC2_ADDR_LN1"], cabs_m6f["LOC1_ADDR_LN1"], 
                                                        cabs_m6f["LOC2_ADDR_LN1"], cabs_m6f["LOC1_ADDR_LN1"] ], np.nan)

    cabs_m6f["FINAL_CITY"] = np.select(conds_addr, [ cabs_m6f["EU_CITY"],     cabs_m6f["SECLOC_CITY"], 
                                                    cabs_m6f["LOC2_CITY"],   cabs_m6f["LOC1_CITY"],
                                                    cabs_m6f["LOC2_CITY"],   cabs_m6f["LOC1_CITY"] ], np.nan)

    cabs_m6f["FINAL_STATE"] = np.select(conds_addr, [ cabs_m6f["EU_STATE"], cabs_m6f["SECLOC_STATE"], 
                                                    cabs_m6f["LOC2_STATE"], cabs_m6f["LOC1_STATE"],
                                                    cabs_m6f["LOC2_STATE"], cabs_m6f["LOC1_STATE"] ], np.nan)

    cabs_m6f["FINAL_ZIP"] = np.select(conds_addr, [ cabs_m6f["EU_ZIP"], np.nan, 
                                                    cabs_m6f["LOC2_ZIP"], cabs_m6f["LOC1_ZIP"], 
                                                    cabs_m6f["LOC2_ZIP"], cabs_m6f["LOC1_ZIP"] ], np.nan)

    # SECLOC doesn't come with a zip field inherently so
    # We use a simple fuzzy match to fill in the SECLOC ZIP fields if the same address is present in LOC1 or LOC2

    # Fuzzymatch score on street address
    cabs_m6f["LOC1_ZFUZZ"] = cabs_m6f.apply(lambda x: fuzz.token_sort_ratio(x["FINAL_ADDRESS"], x["LOC1_ADDR_LN1"]), axis=1)
    cabs_m6f["LOC2_ZFUZZ"] = cabs_m6f.apply(lambda x: fuzz.token_sort_ratio(x['FINAL_ADDRESS'], x['LOC2_ADDR_LN1']), axis=1)

    # Extracting street number 
    cabs_m6f["LOC1_NUM"] = cabs_m6f["LOC1_ADDR_LN1"].str.extract('(\d+)').astype(str)
    cabs_m6f["LOC2_NUM"] = cabs_m6f["LOC2_ADDR_LN1"].str.extract('(\d+)').astype(str)
    cabs_m6f["FINAL_NUM"] = cabs_m6f["FINAL_ADDRESS"].str.extract('(\d+)').astype(str)

    # Flag for if final zip is null due to source being from SECLOC 
    secloc_flag = (cabs_m6f["FINAL_ZIP"].isnull()) & (cabs_m6f["FINAL_FLAG"] == "SECLOC")

    cabs_m6f["FINAL_ZIP"] = np.select( [
        secloc_flag & (cabs_m6f["LOC2_ZFUZZ"] >= 65) & (cabs_m6f["FINAL_NUM"]==cabs_m6f["LOC2_NUM"]),
        secloc_flag & (cabs_m6f["LOC1_ZFUZZ"] >= 65) & (cabs_m6f["FINAL_NUM"]==cabs_m6f["LOC1_NUM"]) ],
        [ cabs_m6f["LOC2_ZIP"],  cabs_m6f["LOC1_ZIP"]], cabs_m6f["FINAL_ZIP"])

    # String formatting clean-up
    cabs_m6f["FINAL_NAME"]    = cabs_m6f["FINAL_NAME"].str.strip()
    cabs_m6f["FINAL_ADDRESS"] = cabs_m6f["FINAL_ADDRESS"].replace('', np.nan)
    
    # Getting needed columns only
    df = cabs_m6f[[
        'CLEAN_ID', 'BILL_MONTH_DT', 'TOTAL_MRC', 'PRIMARY_CARRIER_NAME', 'SEG', 
        'LAST_MODIFIED_DATE', 'DOCUMENT_NUMBER', 
        'FINAL_FLAG', 'FINAL_NAME', 'FINAL_ADDRESS', 'FINAL_CITY', 'FINAL_STATE', 'FINAL_ZIP']].copy()  
    
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

    # Write final result to WAD_PRD_Integration.ADDRESS_BILLING.ADDR_BILLING_MASTER
    timed_execution(odbc_write, "write to CABS_ADDR_PRD_PIVOT", agg, server='WADINFWWAPV02', database='WAD_PRD_Integration', 
        schema='ADDRESS_BILLING', table='CABS_ADDR_PRD_PIVOT')