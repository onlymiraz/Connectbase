select distinct pon, version, supptype, orderstatus, creationdatetime, submitteddatetime, 
to_char(creationdatetime,'mm/dd/yyyy HH24:MI') creation_dt, to_char(submitteddatetime,'mm/dd/yyyy HH24:MI') submitted_dt, 
activity, ccna 
from whsl_adv_hist.vfo_orderhistoryinfo_thist
where orderstatus in ('Accepted_Submitted','Clarification-Errors','Clarification-Errors_Sent','Cancel Submitted','Post-FOC Jeopardy_Sent','Pre-FOC Jeopardy_Sent')
and pon in (
'1117DS3IPLTIND',
'112713 CAMB BRI',
'1242497BROTHERS',
'12753933 - COMBO'
)
order by pon, creationdatetime

;

