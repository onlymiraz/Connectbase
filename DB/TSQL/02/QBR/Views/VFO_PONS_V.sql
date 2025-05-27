CREATE VIEW QBR.[VFO_PONS_V]
	AS 

	
SELECT
ORIGINAL.*
,pons.acna
,mcl.PRIMARY_CARRIER_NM

FROM(


SELECT PON, MAX(INIT_AS) INIT_ASR, MAX(FIRST_CLEAN) FIRST_CLEAN, MAX(CLEAN_AS) CLEAN_ASR, MAX(INIT_CONF) INIT_CONF, MAX(CLEAN_CONF) CLEAN_CONF,                         
MAX(INIT_DLR) INIT_DLR, MAX(CLEAN_DLR) CLEAN_DLR                            
FROM(                           
--                          
SELECT PON, MIN(DT) INIT_AS, NULL FIRST_CLEAN, MAX(DT) CLEAN_AS, NULL INIT_CONF, NULL CLEAN_CONF, NULL INIT_DLR, NULL CLEAN_DLR                         
FROM (                          
SELECT PON, VERSION, ORDERSTATUS, cast(CREATIONDATETIME as date) DT                            
FROM [QBR].[TBL_WHSL_ADV_HIST_VFO_ORDERHISTORYINFO_THIST] ORD                           
WHERE PON IN (                          
--pons here
select distinct pons.pon from qbr.tbl_vfo_pons pons
)                           
AND ORDERSTATUS IN ('Accepted_Submitted')                           
)a                          
GROUP BY PON                            
--                          
UNION ALL                           
--                          
SELECT PON, NULL INIT_AS,  FIRST_CLEAN, NULL CLEAN_AS, NULL INIT_CONF, NULL CLEAN_CONF, NULL INIT_DLR, NULL CLEAN_DLR                         
FROM (                          
--                          
SELECT SUBQ1.PON, CAST(MAX(VFO2.CREATIONDATETIME) AS DATE) AS FIRST_CLEAN                           
  FROM (                                
--                          
SELECT PON, CAST(MIN(CREATIONDATETIME) AS DATE) FIRST_CONF_DT                           
FROM [QBR].[TBL_WHSL_ADV_HIST_VFO_ORDERHISTORYINFO_THIST] ORD                           
WHERE ORDERSTATUS IN ('Confirmed_Submitted','Confirmed_Sent')                           
AND PON IN (                            
--pons here
select distinct pons.pon from qbr.tbl_vfo_pons pons
)                           
GROUP BY PON                            
) SUBQ1,                            
--                          
  [QBR].[TBL_WHSL_ADV_HIST_VFO_ORDERHISTORYINFO_THIST] VFO2                         
  WHERE SUBQ1.PON = VFO2.PON                            
  AND VFO2.CREATIONDATETIME < SUBQ1.FIRST_CONF_DT                           
  AND VFO2.ORDERSTATUS = 'Accepted_Submitted'                           
  GROUP BY SUBQ1.PON                            
)a                           
--                          
UNION ALL                           
--                          
SELECT PON, NULL INIT_AS, NULL FIRST_CLEAN, NULL CLEAN_AS, MIN(DT) INIT_CONF, MAX(DT) CLEAN_CONF, NULL INIT_DLR, NULL CLEAN_DLR                         
FROM (                          
SELECT PON, VERSION, ORDERSTATUS, cast(CREATIONDATETIME as date) DT                            
FROM [QBR].[TBL_WHSL_ADV_HIST_VFO_ORDERHISTORYINFO_THIST] ORD                           
WHERE PON IN (                          
--pons here
select distinct pons.pon from qbr.tbl_vfo_pons pons
)                           
AND ORDERSTATUS IN ('Confirmed_Submitted','Confirmed_Sent')                         
)a                           
GROUP BY PON                            
--                          
UNION ALL                           
--                          
SELECT PON, NULL INIT_AS, NULL FIRST_CLEAN, NULL CLEAN_AS, NULL INIT_CONF, NULL CLEAN_CONF, MIN(DT) INIT_DLR, MAX(DT) CLEAN_DLR                         
FROM (                          
SELECT PON, VERSION, ORDERSTATUS, cast(CREATIONDATETIME as date) DT                            
FROM [QBR].[TBL_WHSL_ADV_HIST_VFO_ORDERHISTORYINFO_THIST] ORD                           
WHERE PON IN (                          
--pons here
select distinct pons.pon from qbr.tbl_vfo_pons pons
)                           
AND ORDERSTATUS IN ('DLR_Submitted','DLR_Sent')                         
--                          
)  a                         
GROUP BY PON                            
)b                          
GROUP BY PON
)ORIGINAL


left join qbr.tbl_vfo_pons pons
on original.PON = pons.pon

left join dbo.MCL_V mcl
on pons.ACNA = mcl.SECONDARY_ID