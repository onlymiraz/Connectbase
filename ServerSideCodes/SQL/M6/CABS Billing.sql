SELECT DISTINCT --RUN IN EDW_VWMC.  										
  CASE WHEN SUBSTR(NC,1,1) = 'K' THEN 'UNI'										
       WHEN SUBSTR(NC,1,2) = 'VL' THEN 'EVC'										
       WHEN SUBSTR(NC,1,2) = 'SN' THEN 'NNI'										
       WHEN SUBSTR(NC,1,1) = 'O' THEN 'OCN'										
       WHEN SUBSTR(NC,1,2) = 'HC' THEN 'DS1'										
       WHEN SUBSTR(NC,1,2) = 'HF' THEN 'DS3'										
       WHEN SUBSTR(NC,1,1) = 'S' THEN 'SWITCHED'										
       WHEN SUBSTR(NC,1,2) IN ('LD','LG','YN') THEN 'VOICE GRD'										
       WHEN SUBSTR(NC,1,2) = 'LX' THEN 'UNBUNDLED FCLTY'										
       WHEN SUBSTR(NC,1,2) = 'LG' THEN 'DDS 56KBPS'										
       WHEN SUBSTR(CIRCUIT_NO,3,3) = '.LX' THEN 'DEDICATED FCLTYS'										
       WHEN SUBSTR(CIRCUIT_NO,3,3) = '.SQ' THEN 'EQUIP ONLY'										
       ELSE 'OTHER' END AS PRODUCT,										
  CLEAN_ID, ACNA, IXC_NAME, ADDR, substr(EO_CLLI_CD,5,2) STATE, INSTALL_DT, DISCONNECT_DT, PNUM, SPEC, 										
  CIRCUIT_NO, NC, FIRST_BILL_MONTH_DT, LAST_BILL_MONTH_DT										
FROM										
( -- SUBQUERY 2 LIMITS OUTPUT TO ACTIVE CIRCUITS										
  SELECT										
 (select sum(cabs1.CHRGE_AMT) from edw_vwmc.CABS_SPCL_ACCS_BILL_REV_DTL_V cabs1 										
       where SUBQ1.CIRCUIT_NO = cabs1.CIRCUIT_NO and SUBQ1.LAST_BILL_MONTH_DT = cabs1.BILL_MONTH_DT) AS TOTAL_CIR_CHG,									
  SUBQ1.*										
    FROM										
    ( -- SUBQUERY 1 FINDS UNIQUE TERM START AND END DATES FOR CIRCUITS										
      SELECT DISTINCT										
      oreplace(oreplace(oreplace(cabs.CIRCUIT_NO,'.'),'-'),' ') as CLEAN_ID,										
      cabs.ACCT_NO,										
      cabs.CABS_BILLING_NO,										
      cabs.PNUM,
      cabs.SPEC,
      cabs.CIRCUIT_NO,										
      cabs.NC_PRODUCT_CD AS NC,										
      cabs.USOC_PRODUCT_CD AS USOC,										
      cabs.CHRGE_AMT AS USOC_CHG,										
      cabs.ACNA,										
      cabs.IXC_NAME,										
      cabs.IXC_NO,
      cabs.ADDR,
      cabs.EO_CLLI_CD,
      cabs.INSTALL_DT,										
      cabs.DISCONNECT_DT,										
      cabs.TERM_START_DT,										
      cabs.TERM_END_DT,										
      (select min(cabs1.BILL_MONTH_DT) from edw_vwmc.CABS_SPCL_ACCS_BILL_REV_DTL_V cabs1 where										
        cabs.CIRCUIT_NO = cabs1.CIRCUIT_NO) as FIRST_BILL_MONTH_DT,										
      CN.LAST_BILL_MONTH_DT,										
      cabs.SOURCE_GL_ACCT_CD,										
      SUBSTR(cabs.SOURCE_GL_ACCT_CD,20,3) AS GL_CD
      --(select max(cabs2.BILL_MONTH_DT) from edw_vwmc.CABS_SPCL_ACCS_BILL_REV_DTL_V cabs2 where										
      --cabs.CIRCUIT_NO = cabs2.CIRCUIT_NO) as LAST_BILL_MONTH_DT										
  FROM 										
  ( --SUBQUERY ""CN"" TO FIND CIRCUIT NUMBERS MATCHING THOSE LISTED -----------------------------------------------------------------										
  SELECT DISTINCT CABS.CIRCUIT_NO,										
    (select max(cabs_lbm.BILL_MONTH_DT) from edw_vwmc.CABS_SPCL_ACCS_BILL_REV_DTL_V cabs_lbm 										
       where cabs.CIRCUIT_NO = cabs_lbm.CIRCUIT_NO) as LAST_BILL_MONTH_DT										
  FROM  edw_vwmc.CABS_SPCL_ACCS_BILL_REV_DTL_V cabs										
  WHERE cabs.BILL_MONTH_DT = '2022-01-01' -- ENTER DATE FOR RECENTLY BILLED CIRCUITS										
  AND cabs.ACNA in ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM')																				
  AND (SUBSTR(cabs.NC_PRODUCT_CD,1,1) = 'K' OR SUBSTR(cabs.NC_PRODUCT_CD,1,2) IN ('VL','SN')										
  OR SUBSTR(cabs.CIRCUIT_NO,3,2)= '.K' OR SUBSTR(cabs.CIRCUIT_NO,3,3) = '.VL')										
  ) CN ------------------------------------------------------------------------------------------------------------------------------------										
  INNER JOIN edw_vwmc.CABS_SPCL_ACCS_BILL_REV_DTL_V cabs ON CN.CIRCUIT_NO = CABS.CIRCUIT_NO AND CN.LAST_BILL_MONTH_DT = CABS.BILL_MONTH_DT										
  ) SUBQ1 ---------------------------------------------------------------------------------------------------------------------------------										
  WHERE SUBQ1.DISCONNECT_DT is null										
  AND (SUBSTR(NC,1,1) = 'K' OR SUBSTR(NC,1,2) IN ('VL','SN')										
  OR SUBSTR(CIRCUIT_NO,3,2)= '.K' OR SUBSTR(CIRCUIT_NO,3,3) = '.VL')																			
) SUBQ2 -----------------------------------------------------------------------------------------------------------------------------------										
ORDER BY CIRCUIT_NO										
