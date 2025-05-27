select ticket_id, state, clec_id, customer, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, repair_code, disp, assignmentprofile profile, to_char(closed_dt,'MM') mon
from (
select ticket_id, clec_id, customer, ckt_id, product, create_date, cleared_dt, closed_dt,  
       case when disp = 'NTF' then 0 else ttr end ttr,  -- Per Matt Freeman on 1/30/2017  
       repair_code, disp, reqstat, assignmentprofile, state
from (
select distinct ticket_id, clec_id, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, total_duration, repair_code, disp, 
       reqstat, cl.customer, assignmentprofile, state                         
from (
select distinct ticket_id, 
       case when acna is not null then acna
            when acna1 is not null then acna1
            when ccna1 is not null then ccna1
            when acna2 is not null then acna2
            else ccna2 end CLEC_ID,        
       ckt_id,  
       case when service_type_code = 'HC' then 'DS1'
            when service_type_code = 'HF' then 'DS3'
                when substr(circuit,4,5) like '%T1%' then 'DS1'
            when substr(circuit,4,5) like '%T3%' then 'DS3'
            when substr(circuit,1,4) like '%HC%' then 'DS1'
            when substr(circuit,1,4) like '%HF%' then 'DS3'
            when substr(circuit,1,2) = 'R2' then 'Ethernet'
            when substr(circuit,4,2) in ('L1','L2') then 'Ethernet'
            when substr(service_type_code,1,1) in ('X','L') then 'DS0'
            when substr(circuit,3,1) in ('X','L') then 'DS0'
            when substr(service_type_code,1,2) = 'OC' then 'OCN'
            when substr(circuit,1,8) like '%OC%' then 'OCN'
            when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
            when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
            when substr(service_type_code,1,2) = 'SX' then 'Ethernet'
            when substr(circuit,3,1) in ('K','V') then 'Ethernet'
            when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
            else ' ' end product,
       create_date, Cleared_Dt, 
       case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,
       Total_Duration, TTR, a.repair_code, b.disp,reqstat,  
       assignmentprofile,
       case when site_clli6 is not null and site_clli6 <> 'NOT IN' then site_clli6
            when clliz is not null then clliz
            else cllia end clli_code,
       case when site_clli6 is not null and site_clli6 <> 'NOT IN' then substr(site_clli6,5,2)
            when clliz is not null then substr(clliz,5,2)
            when exch_clliz is not null then substr(exch_clliz,5,2) 
            else substr(cllia,5,2) end state 
from (
select a.fld_requestid ticket_id,
       max(substr(a.fld_siteid,1,6)) keep (dense_rank last order by a.fld_modifieddate) site_clli6,
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state,
       max(a.fld_customeraddressstate) keep (dense_rank last order by a.fld_modifieddate) rem_state,
       max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc,        
       max(substr(f.clli_code,5,2)) keep (dense_rank last order by f.last_modified_date) cllia_state,
       max(substr(f2.clli_code,5,2)) keep (dense_rank last order by f2.last_modified_date) clliz_state,
       a.exchange_carrier_circuit_id ckt_id, 
       replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
       max(trim(a.acna)) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(trim(d.acna)) keep (dense_rank last order by d.last_modified_date) acna1, 
       max(trim(d.ccna)) keep (dense_rank last order by d.last_modified_date) ccna1,
       max(trim(d.acna)) keep (dense_rank first order by d.acna) acna2, 
       max(trim(d.ccna)) keep (dense_rank first order by d.ccna) ccna2,
       max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
       max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
       max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
       max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
       max(round(a.h_fld_totalopentime_secs_/3600,2)) keep (dense_rank last order by a.fld_modifieddate) Total_Duration,
       max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
       max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
       max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,
       max(substr(f.clli_code,1,6)) keep (dense_rank last order by f.last_modified_date) cllia,
	   max(substr(f2.clli_code,1,6)) keep (dense_rank last order by f2.last_modified_date) clliz,
       max(f2.clli_code) keep (dense_rank last order by f2.last_modified_date) clli_code1,
	   max(substr(f.exchange_area_clli,1,6)) keep (dense_rank last order by f.last_modified_date) exch_cllia,
	   max(substr(f2.exchange_area_clli,1,6)) keep (dense_rank last order by f2.last_modified_date) exch_clliz,
       max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
       max(trim(a.fld_assignmentprofile)) keep (dense_rank first order by a.fld_modifieddate) assignmentprofile
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e,
     casdw.network_location f,
     casdw.network_location f2
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')
 and substr(a.exchange_carrier_circuit_id,6,2) = 'FS'
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and e.location_id = f.location_id(+)
 and e.location_id_2 = f2.location_id(+)
 and (to_char(dte_closeddatetime,'yyyymm') in ('201805')    --NEED TO CHANGE THIS EACH MONTH (CURRENT AND PREVIOUS MONTHS)
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') in ('201805')))   --NEED TO CHANGE THIS EACH MONTH (CURRENT AND PREVIOUS MONTHS) 
 and (e.type <> 'T' or type is null) 
 and e.status (+) = '6'
group by a.fld_requestid, a.exchange_carrier_circuit_id
) a, 
  trbl_found_remedy b
where a.repair_code = b.trbl_found_desc (+)
and substr(ckt_id,7,1) <> 'U'   
and request_type in ('Agent','Alarm','Customer','Maintenance') 
and reqstat = 'Closed'
)data, 
 rvv827.carrier_list cl
where clec_id = cl.acna(+)
and state = 'IL' 
and data.product in ('DS0','DS1','DS3','OCN') --,'Ethernet')
and (clec_id not in ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',
                     'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ','GOV','FTR') and clec_id is not null)
)data2
)  
where disp in ('CO','FAC','CC','NTF')                   
order by 3,4,5,1;