SELECT DISTINCT  										
  CLEAN_ID, ACNA, IXC_NAME, ADDR, substr(EO_CLLI_CD,5,2) STATE, INSTALL_DT, PNUM, SPEC, 										
  CIRCUIT_NO, NC, BILL_CYCLE_CD, FIRST_BILL_MONTH_DT, LAST_BILL_MONTH_DT, DISCONNECT_DT										
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
      cabs.BILL_CYCLE_CD,
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
  WHERE cabs.BILL_MONTH_DT in ('2022-02-01','2022-03-01') -- ENTER DATE FOR RECENTLY BILLED CIRCUITS	
  and pnum in ('EPAV001ATXSCM792BK','EPAV001999SCM792')
  --and circuit_no = '13.KEGS.535763.   .FTNC.'
  AND cabs.ACNA in ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM')																				
  AND (SUBSTR(cabs.NC_PRODUCT_CD,1,1) = 'K' OR SUBSTR(cabs.NC_PRODUCT_CD,1,2) IN ('VL','SN')										
  OR SUBSTR(cabs.CIRCUIT_NO,3,2)= '.K' OR SUBSTR(cabs.CIRCUIT_NO,3,3) = '.VL')										
  ) CN ------------------------------------------------------------------------------------------------------------------------------------										
  INNER JOIN edw_vwmc.CABS_SPCL_ACCS_BILL_REV_DTL_V cabs ON CN.CIRCUIT_NO = CABS.CIRCUIT_NO AND CN.LAST_BILL_MONTH_DT = CABS.BILL_MONTH_DT										
  ) SUBQ1 ---------------------------------------------------------------------------------------------------------------------------------										
  WHERE --SUBQ1.DISCONNECT_DT is null										
  (SUBSTR(NC,1,1) = 'K' OR SUBSTR(NC,1,2) IN ('VL','SN')										
  OR SUBSTR(CIRCUIT_NO,3,2)= '.K' OR SUBSTR(CIRCUIT_NO,3,3) = '.VL')																			
) SUBQ2 -----------------------------------------------------------------------------------------------------------------------------------										
ORDER BY CIRCUIT_NO										
