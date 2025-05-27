select asr_no, pon, vers, sup, reqtype, acna, due_date, act, hdr_icsc, 
       asr_sent_date, asr_sent_time, cnr_sent_date, cnr_sent_time, msg_code, cnr_error_message
from (
SELECT x.document_number ASR_NO, 
       x.external_order_no PON, 
	   x.VERSION VERS, 
	   X.SUP, 
	   x.reqtyp REQTYPE,  
	   sr.acna,
	   sr.desired_due_date DUE_DATE, 
	   asr.ic_circuit_reference,
	   asr.network_channel_service_code nc,
	   sr.first_ecckt_id, 
	   SUBSTR(dbms_lob.SUBSTR( orig_xml, 4000, 1 ),INSTR(x.orig_xml,'<m6:ACT>')+8,INSTR(x.orig_xml,'</m6:ACT>') - (INSTR(x.orig_xml,'<m6:ACT>')+8)) ACT,
SUBSTR(dbms_lob.SUBSTR( orig_xml, 4000, 1 ), INSTR(x.orig_xml,'<m6:ICSC>')+9, 
           INSTR(x.orig_xml,'</m6:ICSC>') - (INSTR(x.orig_xml,'<m6:ICSC>')+9)) HDR_ICSC,
TO_CHAR(TO_DATE(SUBSTR(dbms_lob.SUBSTR( orig_xml, 4000, 1 ), INSTR(x.orig_xml,'<m6:D_SENT>')+11, 
           INSTR(x.orig_xml,'</m6:D_SENT>') - (INSTR(x.orig_xml,'<m6:D_SENT>')+11)),'yyyyMMDD'),'mm/dd/yyyy') ASR_SENT_DATE,
SUBSTR(dbms_lob.SUBSTR( orig_xml, 4000, 1 ), INSTR(x.orig_xml,'<m6:T_SENT>')+11, 
           INSTR(x.orig_xml,'</m6:T_SENT>') - (INSTR(x.orig_xml,'<m6:T_SENT>')+11)) ASR_SENT_TIME,  
TO_CHAR(ml.created_on_date, 'MM/DD/YYYY') CNR_SENT_DATE,
TO_CHAR(ml.created_on_date, 'HH24:MI:SS') CNR_SENT_TIME,
(SELECT vl.form_name FROM asr_om.validation_log vl WHERE vl.document_number = x.document_number AND vl.error_message_id = ml.msg_id AND ROWNUM = 1) MSG_CODE
,ml.addl_info CNR_ERROR_MESSAGE,
x.inserted_dt
FROM asr_om.msg_log ml, asr_om.msg m, asr_om.upstream_req_xml x, serv_req sr, access_service_request asr
WHERE x.asr_om_id = ml.asr_om_id 
AND m.msg_id = ml.msg_id 
and x.document_number = sr.document_number
and sr.document_number = asr.document_number
AND m.msg_type_id = 3 
and substr(x.reqtyp,1,1) in ('S','E')
AND to_char(ml.created_on_date,'yyyymmdd') between '20170605' and '20170618'  
--	or )
and sr.acna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   			'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWS','AWL','AWN','AZE','BAC',
				'BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','CBL','CCB','CDA','CEL',
				'CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
				'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','ETP','EST','ETX',
				'FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','HWC',
				'IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
				'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ',
				'MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV',
				'OSU','PCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN','SCU',
				'SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM',
				'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO')
)
where (substr(nc,1,1) in ('K','V')
      or substr(ic_circuit_reference,4,1) in ('K','V')
      or substr(first_ecckt_id,4,1) in ('K','V')
      or msg_code = 'EVC')
ORDER BY pon, inserted_dt;


