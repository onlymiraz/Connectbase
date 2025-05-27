
SELECT VENDOR, TSP, ATT_CKT, ECCKT, CARRIER
FROM (
SELECT 'FRONTIER COMMUNICATIONS' VENDOR, A.CIRCUIT_DESIGN_ID, TSP, C.ATT_CKT, ECCKT, C.STATUS,
       CASE WHEN ACNA IN ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM') THEN 'ATT COMMUNICATIONS'
            WHEN CCNA IN ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM') THEN 'ATT COMMUNICATIONS'
            ELSE 'ATT MOBILITY' END CARRIER
FROM (
SELECT CIRCUIT_DESIGN_ID, ECCKT, ACNA, CARRIER, CCNA, ISSUE_STATUS, ISSUE_NBR, TSP
FROM (
SELECT CIRCUIT_DESIGN_ID,
       ECCKT,
       ACNA,
       INTEREXCHANGE_CARRIER_NAME CARRIER,
       CCNA,
       ISSUE_STATUS,
       ISSUE_NBR,
       REPLACE(TELECOM_SERVICE_PRIORITY,' ','') TSP,
       ROW_NUMBER() OVER (partition by CIRCUIT_DESIGN_ID order by ISSUE_NBR DESC) r
FROM DESIGN_LAYOUT_REPORT
) WHERE R = 1 
  AND (CCNA IN ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM',
               'AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH',
               'AMP','AWL','AWN','AWS','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','BWI','CBL','CCB',
               'CDA','CEL','CEO','CEU','CFN','CGL','CIV','CIW','CKQ','CLQ','COW','CPF','CQW','CRF','CRJ','CSG','CSO',
               'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','EST','ETP','ETX','FLA','FSC','FSI','FSV','GEE','GLV',
               'GMB','GSL','HGN','HLU','HNC','HTN','HWC','IAS','IFP','IMP','IND','ISZ','IUW','JCR','JCT','LAA','LAC',
               'LBH','LNZ','LSZ','MBN','MBQ','MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIR','MLA','MLZ','MMV',
               'MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NHL','NHO','NSI','NWW','OAK','OCL','ORV','OSU','PCK','PFM',
               'PIG','RAD','RMC','RMF','RRC','SBG','SBJ','SBM','SBN','SBT','SCU','SHI','SLL','SMC','SNP','SSL','STH',
               'SUF','SWC','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','TZV','UMT','VGB','VGD','VRA','WBT','WGL',
               'WLG','WLZ','WVO','WWC','ZAQ','ZAW','ZBM','ZCI','ZWO')
 OR ACNA IN ('AAV','AVA','ATX','LOA','SBB','SBZ','SUV','TPM',
               'AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH',
               'AMP','AWL','AWN','AWS','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','BWI','CBL','CCB',
               'CDA','CEL','CEO','CEU','CFN','CGL','CIV','CIW','CKQ','CLQ','COW','CPF','CQW','CRF','CRJ','CSG','CSO',
               'CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','EST','ETP','ETX','FLA','FSC','FSI','FSV','GEE','GLV',
               'GMB','GSL','HGN','HLU','HNC','HTN','HWC','IAS','IFP','IMP','IND','ISZ','IUW','JCR','JCT','LAA','LAC',
               'LBH','LNZ','LSZ','MBN','MBQ','MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIR','MLA','MLZ','MMV',
               'MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NHL','NHO','NSI','NWW','OAK','OCL','ORV','OSU','PCK','PFM',
               'PIG','RAD','RMC','RMF','RRC','SBG','SBJ','SBM','SBN','SBT','SCU','SHI','SLL','SMC','SNP','SSL','STH',
               'SUF','SWC','SWM','SWP','SWT','SWV','SYC','SZM','TGH','TQU','TZV','UMT','VGB','VGD','VRA','WBT','WGL',
               'WLG','WLZ','WVO','WWC','ZAQ','ZAW','ZBM','ZCI','ZWO'))     
) A,
  (SELECT CIRCUIT_DESIGN_ID, CKT, ATT_CKT, STATUS
   FROM (
    SELECT CIRCUIT_DESIGN_ID, EXCHANGE_CARRIER_CIRCUIT_ID CKT, STATUS, ACCESS_CUSTOMER_CKT_REF ATT_CKT,
       ROW_NUMBER() OVER (partition by EXCHANGE_CARRIER_CIRCUIT_ID order by LAST_MODIFIED_DATE DESC) r
    FROM CIRCUIT)
   WHERE r = 1) C
 WHERE A.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID
    AND SUBSTR(TSP,1,3) = 'TSP')
WHERE STATUS NOT IN ('8','A')    
ORDER BY 4
;

 