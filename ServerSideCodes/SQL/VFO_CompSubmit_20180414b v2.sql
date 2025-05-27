SELECT -- RUN IN CNEPRD
subq3.*,
trunc(subq3.compl_dt) - trunc(subq3.first_conf_dt) AS first_conf_to_compl,
trunc(subq3.first_conf_dt) - trunc(subq3.accept_dt) AS accept_to_first_conf_
FROM
  ( -- SUBQ3 FINDS CORRESPONDING VFO LAST DATE THAT PRECEDES THE FIRST_CONF_DT FOR "Accepted_Submitted" STATUS-------------
  SELECT 
  CAST(MAX(vfo3.creationdatetime) AS DATE) AS accept_dt,
  subq2.*
  FROM
    ( -- SUBQ2 FINDS CORRESPONDING VFO FIRST DATE FOR "Confirmed_Submitted" STATUS AND REMOVES SUPP1s-------------
    SELECT 
    CAST(MIN(vfo2.creationdatetime) AS DATE) AS first_conf_dt,
    subq1.*
    FROM
      ( -- SUBQ1 FINDS DD TASK COMPLETED PONs FOR THE SPECIFIED DATE RANGE -----------------------------------------
      SELECT DISTINCT 
      max(trunc(tsk.actual_completion_date)) KEEP (DENSE_RANK LAST ORDER BY tsk.last_modified_date) AS compl_dt,
      MAX(sr.pon) KEEP (DENSE_RANK LAST ORDER BY sr.stg_ident) AS pon,
      MAX(sr.acna) KEEP (DENSE_RANK LAST ORDER BY sr.stg_ident) AS acna,
      sr.document_number,
      MAX(sr.supplement_type) KEEP (DENSE_RANK LAST ORDER BY sr.stg_ident) AS supp
      FROM WHSL_ADV_HIST.M6_SERV_REQ_THIST SR
      INNER JOIN WHSL_ADV_HIST.M6_TASK_THIST TSK ON sr.document_number = tsk.document_number
      WHERE tsk.task_type = 'DD' 
      and sr.pon in (
      '2401839469194401',
'2402195169193901',
'2418608213403401',
'2439275411863201',
'IQBLH81JMKGWMB01',
'2501579142678601',
'2508844826368301',
'IQBLJFFZQ9GWMB01',
'2523337290337201',
'2523466474247301',
'2529379617216701',
'2529237923272104',
'2539844618798201',
'2539185029578003',
'2524397427425401',
'2542348030223501',
'2555861524272401',
'IQBLJ6K3D5JWMB01',
'IQBLJZ8V3CJWMB02',
'IQBLKGPVGZKWMB01',
'2574652826150401',
'IQBLKGP4HZKWMB01',
'2579555926721701',
'2579568875787501')
      group by sr.document_number
      ) subq1  ------------------------------------------------------------------------------------------------------
    FULL OUTER JOIN WHSL_ADV_HIST.VFO_ORDERHISTORYINFO_THIST VFO2 ON subq1.pon = vfo2.pon
    WHERE vfo2.orderstatus in ('Confirmed_Submitted','Confirmed_Sent')
    AND (subq1.supp <> 1 OR subq1.supp IS NULL)
    GROUP BY subq1.compl_dt, subq1.pon, subq1.acna, subq1.document_number, subq1.supp
    ) subq2  ------------------------------------------------------------------------------------------------------
  FULL OUTER JOIN WHSL_ADV_HIST.VFO_ORDERHISTORYINFO_THIST VFO3 ON subq2.pon = vfo3.pon AND vfo3.creationdatetime < subq2.first_conf_dt
  WHERE vfo3.orderstatus = 'Accepted_Submitted'
  GROUP BY subq2.first_conf_dt, subq2.compl_dt, subq2.pon, subq2.acna, subq2.document_number, subq2.supp
  ) subq3  ------------------------------------------------------------------------------------------------------
ORDER BY subq3.pon

--ALL CENTURYLINK ACNAs FROM MCL
/*
('ATS','AWX','BEY','CAL','CBW','CGP','CPD','CRV','CUZ','CWI','CWK','CWL','CWR','CXE','CXS','CYN','DGL',
 'DTI','EMN','EMW','ENY','EVG','FDC','FNS','GRO','HOG','INA','JJJ','KMM','KMT','LCI','LCZ','LDQ','LDW',
 'LGT','LTL','LWC','MIV','MOV','MVP','NTH','NTX','OMU','ONF','PAC','PHX','QWE','SEP','SMD','SML','SMW',
 'SNK','SNN','SNQ','SPA','SPJ','SPT','STT','SUC','TDX','TED','TLX','TMU','TNM','TRF','TWI','TXZ','ULG',
 'USW','UWC','UWI','UWS','VIM','VNC','VNS','VVS','VWF','WST','XZP','ELU','AJQ','ALN','AQH','ASC','ASI',
 'AVZ','BUC','BUR','BWG','CNK','COS','CTO','CYJ','EAK','EAS','ENW','EPK','ESM','FLS','FOC','GBG','GIE',
 'GSX','GTT','HCU','HCV','HDC','HDE','HFL','HMA','HMD','HNH','HNI','HNJ','HNY','HOR','HPA','HPI','HRH',
 'HSE','HTJ','HWV','HYH','HYS','HYV','ICG','IMR','IPX','IXC','LGG','LHT','LNH','LNK','LSP','LVC','MAD',
 'NCY','NJD','NJF','NNL','NTT','NVN','NWN','PHY','PQC','PUN','RTC','SCH','SGW','SSM','SUR','TDT','TNB',
 'TTW','UNL','VOY','WCA','WCU','WIZ','WLT','WSN','WTC','XCT','AVS','CBU','CHL','CMA','DTU','GCW','GSM',
 'GTC','ICU','IFC','PLI','PTH','TIM','TIW','TQL','TWD','TWF','TWK','XMC')
 */