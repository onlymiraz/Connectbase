import os
import teradatasql
import pyodbc

# Paths to your key and password files
PasswordEncryptionKeyFileName = r'D:\Program Files\Python\teradatasql\samples\s_WAD3Key.properties'
EncryptedPasswordFileName = r'D:\Program Files\Python\teradatasql\samples\s_wad3Pass.properties'

# Verify if the key and password files exist
if not os.path.exists(PasswordEncryptionKeyFileName):
    raise FileNotFoundError(f"Key file not found: {PasswordEncryptionKeyFileName}")
if not os.path.exists(EncryptedPasswordFileName):
    raise FileNotFoundError(f"Password file not found: {EncryptedPasswordFileName}")

# Set the TDGSSCONFIG environment variable
os.environ['TDGSSCONFIG'] = PasswordEncryptionKeyFileName

# Print environment variables for debugging
print("TDGSSCONFIG:", os.getenv('TDGSSCONFIG'))


# Connect to Teradata using the decrypted credentials
encrypted_password = f"ENCRYPTED_PASSWORD(file:{PasswordEncryptionKeyFileName},file:{EncryptedPasswordFileName})"
teradata_conn= teradatasql.connect(
    host='10.209.129.144',
     user='s_WAD3',
     password=encrypted_password,
     encryptdata='true'
)


# Define multiple update queries
update_queries =["DELETE USER_WORK.WCF_DPI_QUERY;","""
INSERT INTO USER_WORK.WCF_DPI_QUERY
sel distinct date as RUN_DT, A.*,B.Office_CLLI8_Site_Id as Address_Office_CLLI8_Site_Id,c.TotalAddresses,FiberCapableAddresses,
CASE WHEN D.Control_Number IS NOT NULL THEN 'Y' ELSE 'N' END AS FTTH_INDICATOR,
OSPPRJ.BUILD_YEAR as BuildYear,
OSPPRJ.ESTIMATED_OPEN_FOR_SALE_QUARTER,
OSPPRJ.TARGET_MONTH,
OSPPRJ.CURRENT_ESTIMATED_OPEN_FOR_SALE_DATE,
E.SUBSTP AS Service_Type,
F.BillingCompanyName,
CASE WHEN TRIM(a.Exchange_Description)='ALAFIA C.O.' THEN G.MSOTOS ELSE '' END AS OrderType,
CASE WHEN TRIM(a.Exchange_Description)='ALAFIA C.O.' THEN G.MSOSDT  ELSE '' END AS OrderTakenDate,
CASE WHEN TRIM(a.Exchange_Description)='ALAFIA C.O.' THEN G.MSOCPD  ELSE '' END AS OrderCompletionDate,
CASE WHEN TRIM(a.Exchange_Description)='ALAFIA C.O.' THEN substring(G.MSOSO#,2,length(G.MSOSO#)) ELSE '' END AS OrderNumber,
CASE WHEN TRIM(a.Exchange_Description)='ALAFIA C.O.' THEN G.MSOBWD  ELSE '' END AS OrderDueDate,
H.LATITUDEVALUE AS LATITUDE,
H.LONGITUDEVALUE AS LONGITUDE
from EDW_VWMC.C2F_EXCHANGE_SUBSCRIBERS A
LEFT JOIN (sel STATE,Exchange_Description,Exchange_Code,Office_CLLI8_Site_Id,
count(distinct concat(PREMISENUMBER,Environment)) as Uniq,
row_number() over ( partition by STATE,Exchange_Description,Exchange_Code 
               order by Uniq desc) lvl
               from EDW_VWMC.C2F_EXCHANGE_SUBSCRIBERS
Where EXCHANGE_CODE is not Null
qualify lvl=1
group by STATE,Exchange_Description,Exchange_Code,Office_CLLI8_Site_Id
) B on A.STATE=B.STATE and A.Exchange_Description=B.Exchange_Description and A.Exchange_Code=B.Exchange_Code
LEFT JOIN (select PSASTA,SAM1HOS,count(distinct concat(HSIENV,PSACN#)) as TotalAddresses,
count(distinct (case when MAXCMEDIA='FIBER' then concat(HSIENV,PSACN#) end)) as FiberCapableAddresses from stg_dpi_vw.PLHSICANHD
group by  PSASTA,SAM1HOS) C on A.STATE=C.PSASTA and A.Exchange_Code=C.SAM1HOS
LEFT JOIN EDW_ADDR_VW.FTTH_ADDR_PREBUILT_TO_DATE_V D ON a.Environment=d.DPI_Environment AND A.PREMISENUMBER=D.Control_Number
LEFT JOIN ( 
           SEL OSP.PROJECT_NUMBER, MAX(BUILD_YEAR) BUILD_YEAR,MAX(ESTIMATED_OPEN_FOR_SALE_QUARTER) ESTIMATED_OPEN_FOR_SALE_QUARTER,max(TARGET_MONTH) TARGET_MONTH,
                                               max(CURRENT_ESTIMATED_OPEN_FOR_SALE_DATE) CURRENT_ESTIMATED_OPEN_FOR_SALE_DATE
           FROM EDW_ADDR_VW.FTTH_OSP_PROJECT_DETAILS_V OSP GROUP BY 1
           ) OSPPRJ
ON D.PROJECT_NUMBER = OSPPRJ.PROJECT_NUMBER
LEFT JOIN EDW_WRK_VWMC.C2F_MK_SUBSCRIBERS_WORK E ON A.TELEPHONENUMBER=E.WTN AND A.Environment=E.MKTENV
LEFT JOIN SAAREPORT_VW.SAAFACTACCOUNTMONTHLYSNAPV F ON A.MASTERACCOUNTNUMBER=F.BillingTelephone AND F.datestart='2022-06-01'
LEFT JOIN stg_dpi_vw.svord_load G ON A.TELEPHONENUMBER=G.MSOPH# AND A.Environment=G.BILL_SUB_SYS AND G.MSOSDT > 20220712
LEFT JOIN STG_DPI_VW.PLHSICANHD H ON A.Environment=H.HSIENV AND A.PREMISENUMBER=H.PSACN#
Where A.EXCHANGE_CODE is not Null;"""]


# Execute each update query
with teradata_conn.cursor() as teradata_cursor:
    for query in update_queries:
        teradata_cursor.execute(query)
    teradata_conn.commit()

# Close connection
teradata_conn.close()
# Insert data into SQL Server
#with sql_server_conn.cursor() as sql_server_cursor:
#    insert_query = "INSERT INTO your_sql_server_table (column1, column2) VALUES (?, ?)"
#    data_to_insert = [('value1', 'value2'), ('value3', 'value4')]
#    sql_server_cursor.executemany(insert_query, data_to_insert)
#    sql_server_conn.commit()

# Close connections
#teradata_conn.close()
#sql_server_conn.close()
