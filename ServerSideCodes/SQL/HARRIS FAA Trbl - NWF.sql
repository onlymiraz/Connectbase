select distinct ticket_id, state, ckt_id, acna,  
       create_date, 
       case when Cleared_Dt is not null then Cleared_dt
            else Closed_dt end Cleared_Dt, 
       case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,
prod, request_type, repair_code, ttr, mttr_group, cust, trbl_desc
from (
select ticket_id,
       case when site_id is not null and site_id <> 'NON INVENTORIED CIRCUIT' then substr(site_id,5,2) else priloc end state,
       ckt_id, request_type, 
       case when acna is not null then acna
            when acna1 is not null then acna1
            when ccna1 is not null then ccna1
            when acna2 is not null then acna2
            else ccna2 end acna,
       create_date, cleared_dt, closed_dt,      
       case when service_type_code = 'HC' then 'DS1'
            when service_type_code = 'HF' then 'DS3'
            when substr(circuit,4,4) like '%T1%' then 'DS1'
            when substr(circuit,4,4) like '%T3%' then 'DS3'
            when substr(circuit,1,4) like '%HC%' then 'DS1'
            when substr(circuit,1,4) like '%HF%' then 'DS3'
            when substr(circuit,1,2) = 'R2' then 'Ethernet'
            when substr(service_type_code,1,1) in ('X','L') then 'DS0'
            when substr(circuit,3,1) in ('X','L') then 'DS0'
            when substr(service_type_code,1,2) = 'OC' then 'OCN'
            when substr(circuit,1,6) like '%OC%' then 'OCN'
            when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
            when substr(circuit,3,1) in ('K','V') then 'Ethernet'
            when substr(circuit,3,2) in ('DR','FD','PE','PL','RT','TC','UC') then 'DS0'
            when substr(circuit,3,2) in ('DH','FL','IP','QG','YB','YG') then 'DS1'
            when rate_code is not null then rate_code
            else ' ' end prod,
       repair_code, ttr,
       case when TTR <= 3 then '0 to 3'
            when TTR between 3.01 and 4 then '3 to 4'
            when TTR between 4.01 and 5 then '4 to 5'
            when TTR between 5.01 and 7 then '5 to 7'
            when TTR between 7.01 and 9 then '7 to 9'
            else '9+' end mttr_group,
       cust, 
       replace(replace(trbl_desc,chr(10),''),chr(13),'') trbl_desc    
 from (           
select a.fld_requestid ticket_id, 
       max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc,
       a.exchange_carrier_circuit_id ckt_id,
       replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit, 
       max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 
       max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,
       max(d.acna) keep (dense_rank first order by d.acna) acna2, 
       max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,
       max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
       max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
       max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
       max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
       max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
       max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,
       max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
       max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,  
       max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
       max(a.fld_troublereportstate) keep (dense_rank last order by a.fld_modifieddate) trblstat,
       max(a.fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) causecode,
       max(a.fld_complete_faultlocation) keep (dense_rank last order by a.fld_modifieddate) faultloc,
       max(a.fld_descriptionofsympton) keep (dense_rank last order by a.fld_modifieddate) trbl_desc,
       max(a.fld_alocationaccessname2) keep (dense_rank last order by a.fld_modifieddate) cust
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (e.type <> 'T' or type is null) 
 and e.status (+) = '6'
 and (to_char(dte_closeddatetime,'yyyymm') = '202003'    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') = '202003'))   --NEED TO CHANGE THIS EACH MONTH
 and (FLD_ALOCATIONACCESSNAME2 like '%FAA%'
or FLD_ALOCATIONACCESSNAME2 like '%Faa%'
or FLD_ALOCATIONACCESSNAME2 like '%faa%'
or FLD_ALOCATIONACCESSNAME2 like '%Harris%'
or FLD_ALOCATIONACCESSNAME2 like '%HARRIS%'
or FLD_ALOCATIONACCESSNAME2 like '%harris%')
and FLD_ALOCATIONACCESSNAME2 not like '%arrison%'
and FLD_ALOCATIONACCESSNAME2 not like '%ARRISON%'
and FLD_ALOCATIONACCESSNAME2 not like '%arrisville%'
and FLD_ALOCATIONACCESSNAME2 not like '%HARRISVILLE%'
and FLD_ALOCATIONACCESSNAME2 not like '%FINANCIAL%'
and FLD_ALOCATIONACCESSNAME2 not like '%HARRISBURG%'
and FLD_ALOCATIONACCESSNAME2 not like '%HOSPITAL%'
and FLD_ALOCATIONACCESSNAME2 not like '%BANK%'
and FLD_ALOCATIONACCESSNAME2 not like '%Teeter%'
and FLD_ALOCATIONACCESSNAME2 not like '%Steel%'
and FLD_ALOCATIONACCESSNAME2 not like '%STEEL%'
and FLD_ALOCATIONACCESSNAME2 not like '%steel%'
and FLD_ALOCATIONACCESSNAME2 not like '%Bank%'
group by a.fld_requestid, a.exchange_carrier_circuit_id
)
where reqstat = 'Closed' 
--
UNION ALL
--
--LIST OF PREVIOUS CIRCUIT IDS FOR HARRIS TO FIND ANY MORE TROUBLES  
select ticket_id,
       case when site_id is not null and site_id <> 'NON INVENTORIED CIRCUIT' then substr(site_id,5,2) else priloc end state,
       ckt_id, request_type, 
       case when acna is not null then acna
            when acna1 is not null then acna1
            when ccna1 is not null then ccna1
            when acna2 is not null then acna2
            else ccna2 end acna,
       create_date, cleared_dt, closed_dt,      
       case when service_type_code = 'HC' then 'DS1'
            when service_type_code = 'HF' then 'DS3'
            when substr(circuit,4,4) like '%T1%' then 'DS1'
            when substr(circuit,4,4) like '%T3%' then 'DS3'
            when substr(circuit,1,4) like '%HC%' then 'DS1'
            when substr(circuit,1,4) like '%HF%' then 'DS3'
            when substr(circuit,1,2) = 'R2' then 'Ethernet'
            when substr(service_type_code,1,1) in ('X','L') then 'DS0'
            when substr(circuit,3,1) in ('X','L') then 'DS0'
            when substr(service_type_code,1,2) = 'OC' then 'OCN'
            when substr(circuit,1,6) like '%OC%' then 'OCN'
            when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
            when substr(circuit,3,1) in ('K','V') then 'Ethernet'
            when substr(circuit,3,2) in ('DR','FD','PE','PL','RT','TC','UC') then 'DS0'
            when substr(circuit,3,2) in ('DH','FL','IP','QG','YB','YG') then 'DS1'
            when rate_code is not null then rate_code
            else ' ' end prod,
       repair_code, ttr,
       case when TTR <= 3 then '0 to 3'
            when TTR between 3.01 and 4 then '3 to 4'
            when TTR between 4.01 and 5 then '4 to 5'
            when TTR between 5.01 and 7 then '5 to 7'
            when TTR between 7.01 and 9 then '7 to 9'
            else '9+' end mttr_group,
       cust, 
       replace(replace(trbl_desc,chr(10),''),chr(13),'') trbl_desc    
 from (      
select a.fld_requestid ticket_id, 
       max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc,
       a.exchange_carrier_circuit_id ckt_id,
       replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit, 
       max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 
       max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,
       max(d.acna) keep (dense_rank first order by d.acna) acna2, 
       max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,
       max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
       max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
       max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
       max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
       max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
       max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,
       max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
       max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,  
       max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
       max(a.fld_troublereportstate) keep (dense_rank last order by a.fld_modifieddate) trblstat,
       max(a.fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) causecode,
       max(a.fld_complete_faultlocation) keep (dense_rank last order by a.fld_modifieddate) faultloc,
       max(a.fld_descriptionofsympton) keep (dense_rank last order by a.fld_modifieddate) trbl_desc,
       max(a.fld_alocationaccessname2) keep (dense_rank last order by a.fld_modifieddate) cust
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (e.type <> 'T' or type is null) 
 and e.status (+) = '6'
 and (to_char(dte_closeddatetime,'yyyymm') = '202003'    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') = '202003'))   --NEED TO CHANGE THIS EACH MONTH
 and (substr(a.exchange_carrier_circuit_id,1,14) in ( 
'34/LGXX/000138',
'34/LGXX/000139',
'43/XHGS/506917',
'70/LGXX/00550 ',
'70/LGXX/00551 ',
'70/LGXX/00786 ',
'70/LGXX/91831 ',
'72/LGXX/00606 ',
'72/LGXX/01179 ',
'72/LGXX/01259 ',
'74/LGXX/000523',
'74/LGXX/001200',
'74/LGXX/00514 ',
'74/LGXX/00519 ',
'74/LGXX/00692 ',
'74/LGXX/01063 ',
'74/LGXX/01148 ',
'74/LGXX/01201 ',
'74/LGXX/01263 ',
'76/LGXX/01136 ',
'76/LGXX/012673',
'83/LGGS/400016',
'83/LGGS/400018',
'83/LGGS/400031',
'83/LGGS/400032',
'83/LGGS/922661',
'85/LGGS/500024',
'85/LGGS/500025',
'86/HCGS/564167'   
)
or a.exchange_carrier_circuit_id in (
'101  /T1ZF  /CRALIDXXKZZ/PLMNWA07H00',
'101  /T1ZF  /OKHRWAAPHAA/STTLWA06K91',
'101  /T1ZF  /CRALIDXXKZZ/PLMNWA07H00',
'102  /T1ZF  /NWBROREZHAA/PTLDOR69K22',
'109  /T1ZF  /CRALIDXXKZZ/PSFLIDAAWT1',
'101  /T1ZF  /DYTNORBGHAA/PTLDOR69K22'
))
group by a.fld_requestid, a.exchange_carrier_circuit_id
)
where reqstat = 'Closed'
)
order by 7;





