select DISTINCT TYPE, PON, DOCNO, ACNA, ACT_IND, CKT, D_REC, DD, CRDD, 
       case when state is not null then state else npastate end state,
       NC, NC_OPT, NCI, SECNCI, ACTL, SPEC, VTA, PNUM, task_at_ready, TASK_AT_JEOP, JEOP_CODE, JEOP_DESC,
       init, init_tel_no, init_email, dsgcon, dsg_tel_no, lcon, lcon_email, actel 
FROM (
SELECT PON, DOCUMENT_NUMBER DOCNO, ACNA, ACT_IND, CKT, D_REC, DD, CRDD, ICSC,     
	   PROJ, RATE_CODE, NC, NC_OPT, euname, NCI, SECNCI, state, substr(npa.exchange_area_clli,5,2) npastate,
       SPEC, pnum, vta, actl, init, init_tel_no, init_email,
       dsgcon, dsg_tel_no, lcon, lcon_email, actel, cno, task_at_ready, TASK_AT_JEOP, JEOP_CODE, JT.JEOPARDY_REASON_DESCRIPTION JEOP_DESC,
       case when spec = 'EPATHCP' and substr(actl,1,8) not in ('ASBNVACY','ATLNGAMQ','CHCGILDT','ASBNVAEG','DLLSTX97',
                                                               'LSANCAVJ','PLALCA01','SCCSNJ75','MIASFLTT','ENWDCOUH') then 'CORE POP - Invalid ACTL'
            when spec = 'EPATHCP' and substr(actl,1,8) in ('ASBNVACY','ATLNGAMQ','CHCGILDT','ASBNVAEG','DLLSTX97',
                                                           'LSANCAVJ','PLALCA01','SCCSNJ75','MIASFLTT','ENWDCOUH') then 'CORE POP'
            when substr(actl,1,8) in (
            'BLTNCAAD','ELSGCA12','BRBNCA11','CLCYCA11','HLWDCA01','NHWDCA02','LSANCARC','SNPDCA01','LSANCA12',
            'GLDLCA11','CNPKCA01','LSANCA01','BRBNCA13','IRVNCA11','LSANCA06','LSANCA07','LSANCA09','WLMGCA01',
            'TUSTCA11','RVSDCA01','COTNCA11','FNTACA11','SNLOCA01','DLLSTX37','DLLSTXRN','DLLSTXRI','DLLSTXTL',
            'DLLSTXTA','DLLSTXNO','DLLSTXME','FTWOTXED','RONKTXWO','DLLSTXRO','HSTNTXAD','HSTNTXCA','FRSCTXES',
            'DLLSTX97','LSANCAVJ','STTLWAWB','MPLSMNGT','MPLSMNCD','ENWDCOUH','MIASFLTT','NYCMNY83','PLALCA01',
            'LSANCA89','BHLHPAEA','HVTPPABJ','BMBGPAEZ','BMBGPAGH','SUTSPA01','CPHLPAES','HRBGPA29','LMYNPAAY',
            'SRDLPAAC','SRDLPAAE','HZTNPACH','HZTNPADI','HZTNPAED','HZTNPAHY','HZTNPAIU','EWVLPABI','FRFTPAAB',
            'KGTNPAAA','KGTNPAAK','KGTNPADT','KGTNPAEO','EHMTPA26','LNCSPAKN','LNCSPAOX','LNCSPAPH','LNCSPAUG',
            'LBNNPALH','NNTCPAAD','NNTCPABL','NNTCPABM','BEWKPA19','DAVLPABQ','DAVLPAGH','LKHRPAAD','LKHRPAAE',
            'LKHRPAAF','LKHRPAAG','LKHRPAAH','LKHRPAAI','LKHRPAAJ','LKHRPAAK','LKHRPAAL','LKHRPAAM','LKHRPAAN',
            'LKHRPAAO','LKHRPAAP','LKHRPAAQ','LKHRPAAR','LKHRPAAS','LKHRPAAT','LKHRPAAU','LKHRPAAV','LKHRPAAW',
            'LKHRPAAX','LKHRPAAY','LKHRPAAZ','PLNSPAAR','PLNSPAEF','WLBPPABI','WLBPPABJ','WLBRPAKJ','WLBRPAMY',
            'WLBRPANC','WLBRPAPB','WLBRPAPS','WLBSPADA','WLBSPADC','LRKVPAAG','LRKVPAAH','PLTSPAAA','PLMGPAAX',
            'MHBGPAAC','MHTSPAAC','MHTSPAEE','WRDNPABW','DNMRPA24','DNMRPACX','JSSPPA04','SCTNPA13','SCTNPADA',
            'SCTNPAEO','SCTNPAER','SCTNPAIA','SCTNPAPL','SCTNPASC','SCTNPAUE','SCTNPAVH','WPTNPAAX','HRTPPAAN',
            'PLNSPADT','WLBPPAAV','WLBPPABC','WLBRPA15','WLBRPAAK','WLBRPAAV','WLBRPABO','WLBRPAFD','WLBRPAFM',
            'WLBRPAHV','WLBRPAIK','WLBRPAIZ','WLBRPAKN','WLBRPAMI','WLBRPAMP','WLBRPAMS','WLBRPANG','WLBRPANH',
            'WLBRPAOS','WLBRPAWB','WLBRPAXA','WLBSPACC','WLBSPACE','WLBSPACF','WLBSPACG','WLBSPACH','WLBSPACK',
            'WLBOPACJ','WLPTPA46','WLPTPAPC','EXTLPA03','WPTNPAAW','WWYMPAAA','EMGVPAAO','GRNLPA02','WMCTPAAW',
            'YORKPAFE','YORKPAKB','YORKPALQ','YORKPAYK','YORKPAZB','YORKPAZD','YORLPAKJ','YORLPAMK','YORLPAUH',
            'HRBGPAHA'
            )
            then 'CARRIER HOTEL'
            else 'EXCLUDE' end TYPE
FROM
(
SELECT SR.PON,
  SR.DOCUMENT_NUMBER,    
  MAX(SR.ACTIVITY_IND) keep (dense_rank last order by sr.last_modified_date) ACT_IND,
  MAX(SR.SUPPLEMENT_TYPE) keep (dense_rank last order by sr.last_modified_date) SUPP_TYPE,
  MAX(SR.FIRST_ECCKT_ID) keep (dense_rank last order by sr.last_modified_date) CKT,
  max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) D_REC, 
  max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD, 
  max(AUD.crdd) keep (dense_rank last order by aud.last_modified_date) CRDD,
  MAX(ASR.ACCESS_PROVIDER_SERV_CTR_CODE) keep (dense_rank last order by asr.last_modified_date) ICSC,
  MAX(ASR.CASE_NUMBER) keep (dense_rank last order by asr.last_modified_date) CNO,
  MAX(REPLACE(SR.PROJECT_IDENTIFICATION,' ')) keep (dense_rank last order by sr.last_modified_date) PROJ,
  MAX(SR.ACNA) keep (dense_rank last order by sr.last_modified_date) ACNA,
  MAX(CIR.RATE_CODE) keep (dense_rank last order by cir.last_modified_date) RATE_CODE,
  MAX(CIR.SERVICE_TYPE_CODE) keep (dense_rank last order by cir.last_modified_date) svc_code,
  MAX(ASR.NETWORK_CHANNEL_SERVICE_CODE) keep (dense_rank last order by asr.last_modified_date) NC,
  MAX(ASR.NETWORK_CHANNEL_OPTION_CODE) keep (dense_rank last order by asr.last_modified_date) NC_OPT,
  MAX(ASR.NETWORK_CHANNEL_INTERFACE_CODE) keep (dense_rank last order by asr.last_modified_date) NCI,
  MAX(DLR.SEC_NETWORK_CHANNEL_INTERFACE) keep (dense_rank last order by dlr.last_modified_date) SECNCI,
  max(CIR.EXCHANGE_CARRIER_CIRCUIT_ID) keep (dense_rank last order by cir.last_modified_date) CIRCKT,
  max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,
  max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx,
  SALI.EUNAME, 
  substr(sali.state,1,2) state,
  max(asr.service_and_product_enhanc_cod) keep (dense_rank last order by asr.last_modified_date) SPEC,
  det.bill_pnum pnum,
  det.bill_vta vta,
  det.actl,
  det.init,
  det.init_tel_no,
  det.init_email,
  det.dsgcon,
  det.dsg_tel_no,
  sali.lcon,
  eulu.local_contact_email lcon_email,
  sali.actel,
  tsk2.task_type TASK_AT_READY,
  TSK3.TASK_TYPE TASK_AT_JEOP,
  JW.JEOPARDY_REASON_CODE JEOP_CODE
--
FROM SERV_REQ SR, 
     ACCESS_SERVICE_REQUEST ASR, 
     CIRCUIT CIR,
     DESIGN_LAYOUT_REPORT DLR, 
     TASK TSK,
     TASK TSK2,
     TASK_JEOPARDY_WHYMISS JW,
     TASK TSK3,
     ASR_USER_DATA AUD,
     data_ext.asr_sali SALI,
     data_ext.asr_detail det,
     end_user_location_usage eulu
--
WHERE SR.DOCUMENT_NUMBER = ASR.DOCUMENT_NUMBER(+)
AND SR.DOCUMENT_NUMBER = TSK.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = TSK2.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = JW.DOCUMENT_NUMBER (+)
AND JW.TASK_NUMBER = TSK3.TASK_NUMBER (+)
AND SR.DOCUMENT_NUMBER = DLR.DOCUMENT_NUMBER (+)
AND SR.DOCUMENT_NUMBER = AUD.DOCUMENT_NUMBER (+)
AND DLR.CIRCUIT_DESIGN_ID = CIR.CIRCUIT_DESIGN_ID (+)
and SR.DOCUMENT_NUMBER = SALI.DOCUMENT_NUMBER(+)
and sr.document_number = det.document_number (+)
and sr.document_number = eulu.document_number (+)
AND SR.TYPE_OF_SR in ('ASR')
and asr.request_type in ('S','E')
and asr.activity_indicator in ('N','C','R')
AND TSK.TASK_TYPE(+) = 'DD'
and TSK.ACTUAL_COMPLETION_DATE is null
AND TSK2.TASK_STATUS (+) = 'Ready'
AND JW.JEOPARDY_TYPE_CD (+) = 'J'
AND JW.DATE_CLOSED (+) IS NULL
--and substr(asr.service_and_product_enhanc_cod,1,5) = 'EPATH'

and (asr.service_and_product_enhanc_cod in ('EPATHCP','EPATHN','EVPLSN','EVPLPN','EVPLGN','EPLELSN','EPLELPN','ERSNPA','ERSNPN')
 or substr(ASR.NETWORK_CHANNEL_SERVICE_CODE,1,2) = 'SN')
--
GROUP BY SR.DOCUMENT_NUMBER,
  SR.PON, SALI.EUNAME, det.bill_pnum, sali.state, det.actl,
  det.bill_vta,
  det.init,
  det.init_tel_no,
  det.init_email,
  det.dsgcon,
  det.dsg_tel_no,
  sali.lcon,
  eulu.local_contact_email,
  sali.actel,
  tsk2.task_type,
  TSK3.TASK_TYPE,
  JW.JEOPARDY_REASON_CODE
)
--
data, npa_nxx npa, JEOPARDY_TYPE JT
where data.NPA = NPA.NPA (+)
  and data.nxx = npa.nxx (+)
  AND DATA.JEOP_CODE = JT.JEOPARDY_REASON_CODE (+)
  AND JT.JEOPARDY_TYPE_CD (+) = 'J'
and (SUPP_TYPE <> '1' OR SUPP_TYPE IS NULL)
)
where type <> 'EXCLUDE'
 ORDER BY 1 desc,8;
 
 
 
 
 
 
