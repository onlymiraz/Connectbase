select ticket_id, state,  
       case when district in ('MI','WI') then 'Central'
            when district in ('CT','NY','OH','PA','WV') then 'East'
            when district in ('IN','TN') then 'Mid-South'
            when district in ('ID','IL','MN','NE') then 'National'
            when district in ('AZ','TX') then 'South'
            when district in ('FL','NC','SC') then 'Southeast'
            when district in ('CA','OR','WA') then 'West'
            else 'Unknown' end region,
       clec_id, customer, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, trblstatus, wo_id, vnet_id, location_name, trunc(load_date) load_date
from (
select ticket_id, state, clec_id, customer, ckt_id, product, create_date, cleared_dt, closed_dt,  
       ttr, total_duration, repair_code, disp, clli_code,
       case when zdist is not null then zdist
            when zdist is not null then zdist 
            when state in ('CT','NY','OH','PA','WV','MI','WI','TN','IN','ID','IL','NE','MN','AZ','TX','FL','NC','SC','CA','OR','WA') then state
            when state in ('NV','NM') then 'AZ'
            when state in ('UT','MT') then 'ID'
            when state in ('AL','GA','MS') then 'TN'
            when state = 'KY' then 'IN'
            when state = 'IA' then 'NE'
            when state = 'MO' then 'IL'
            when state in ('MD','VA') then 'WV'
            else state end district,
        location_name, assignmentprofile, trblstatus, wo_id, vnet_id, load_date
from (
select distinct ticket_id, state, clec_id, ckt_id, product, create_date, cleared_dt, closed_dt, 
       ttr, total_duration, repair_code, disp, clli_code,
       zclli,  aclli, location_name, cl.customer,
       zdist, zreg, adist, areg, assignmentprofile, trblstatus, wo_id, vnet_id, load_date 
from (
select distinct ticket_id, 
       case when hier.state is not null then hier.state
            when hier2.state is not null then hier2.state
            when icsc = 'RT01' then 'NY'
            when substr(circuit,1,2) = 'R2' then 'NY'
               when clliz is not null 
             and clliz in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then clliz
            when site_state is not null and site_id <> 'NON INVENTORIED CIRCUIT'
             and site_state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then site_state 
            when cllia is not null 
             and cllia in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then cllia
            when priloc is not null 
             and priloc in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX') then priloc
            when icsc = 'FV01' then 'WV'
            when ckt_id like '%/WV%' then 'WV'
            when substr(circuit,1,2) in ('50','54','56') then 'WV'
            else null end state,
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
            when substr(service_type_code,1,1) in ('X','L') then 'DS0'
            when substr(circuit,3,1) in ('X','L') then 'DS0'
            when substr(service_type_code,1,2) = 'OC' then 'OCN'
            when substr(circuit,1,8) like '%OC%' then 'OCN'
            when substr(circuit,3,2) in ('OB','OD','OF','OG') then 'OCN'
            when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
            when substr(circuit,3,1) in ('K','V') then 'Ethernet'
            when rate_code in ('OC3','OC12','OC48','OC192') then 'OCN'
            else ' ' end product,
       case when to_char(Create_Date,'yyyymmdd') between '20151101' and '20160312' then Create_Date-5/24 
            else Create_Date-4/24 end create_date, 
       case when to_char(Cleared_Dt,'yyyymmdd') between '20151101' and '20160312' then Cleared_dt-5/24
            when Cleared_Dt is not null then Cleared_dt-4/24
            when cleared_dt is null and to_char(Closed_Dt,'yyyymmdd') between '20151101' and '20160312' then Closed_dt-5/24
            else Closed_dt-4/24 end Cleared_Dt, 
       case when to_char(Closed_Dt,'yyyymmdd') between '20151101' and '20160312' then Closed_dt-5/24
            when Closed_Dt is not null then Closed_dt-4/24
            when closed_dt is null and to_char(Cleared_Dt,'yyyymmdd') between '20151101' and '20160312' then Cleared_dt-5/24
            else Cleared_dt-4/24 end Closed_Dt,
       Total_Duration, 
       TTR,
       a.repair_code, b.disp,
       clli_code, aclli, zclli, 
       hier.district zdist, hier.region zreg, 
       hier2.district adist, hier2.region areg,       
       trblstatus, wo_id, vnet_id, 
       replace(replace(location_name, chr(13)),chr(10)) location_name, assignmentprofile, load_date
from (
select a.fld_requestid ticket_id, 
       max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
       max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc, 
       max(substr(f.clli_code,5,2)) keep (dense_rank last order by f.last_modified_date) cllia,
       max(substr(f2.clli_code,5,2)) keep (dense_rank last order by f2.last_modified_date) clliz,
       max(f2.clli_code) keep (dense_rank last order by f2.last_modified_date) clli_code,
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
       max(substr(f.exchange_area_clli,1,6)) keep (dense_rank last order by f.last_modified_date) aclli,
       max(substr(f2.exchange_area_clli,1,6)) keep (dense_rank last order by f2.last_modified_date) zclli,
       max(a.FLD_TROUBLEREPORTSTATUS) keep (dense_rank last order by a.fld_modifieddate) trblstatus,
       max(a.fld_alocationaccessname2) location_name,
       max(a.fld_vnet_id) keep (dense_rank last order by a.fld_modifieddate) vnet_id,
       max(a.fld_woid) keep (dense_rank last order by a.fld_modifieddate) wo_id,
       max(trim(a.fld_assignmentprofile)) keep (dense_rank first order by a.fld_modifieddate) assignmentprofile,
       max(a.dw_load_date_time) load_date
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e,
     casdw.network_location f,
     casdw.network_location f2
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF','FTW TSC','CTF TSC')
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and e.location_id = f.location_id(+)
 and e.location_id_2 = f2.location_id(+)
 --and to_char(a.dw_load_date_time,'yyyymm') = '201607'    --IF YOU WANT TO PULL FOR A FULL MONTH USE THIS   
 and to_char(a.dw_load_date_time,'yyyymmdd') >= substr((TO_CHAR(SYSDATE-7,'YYYYMMDD')),1,8)  --THIS PULLS THE PREVIOUS 7 DAYS OF CANCELED TICKETS  
 and substr(a.FLD_TROUBLEREPORTSTATUS,1,8) = 'Canceled'
group by a.fld_requestid, a.exchange_carrier_circuit_id, fld_statusdate
) a, 
  trbl_found_remedy b,
  rvv827.hierarchy hier,
  rvv827.hierarchy hier2
where a.repair_code = b.trbl_found_desc (+)
and zclli = hier.clli_6 (+)
and aclli = hier2.clli_6 (+)
)data, 
 rvv827.carrier_list cl
where clec_id = cl.acna(+)
and data.state in ('NY','PA','CT','WV','MD','VA','SC','NC','IL','MN','OH','IN','KY','MI','CA','OR','WA','AZ','NV','NM','UT','WI','ID','IA','MT','NE','AL','FL','GA','MS','TN','TX')
and (clec_id not in ('FLR','ZTK','BLI','BNK','CMW','COY','CQV','CUS','CZE','CZJ','CZN','CZX','EPX','ERR','EXC','FBA','FCA','FIS',
                     'FLX','GOP','GTO','GVN','IZH','NNR','OGD','RGD','ROU','T05','VAC','VZN','WDK','ZAP','ZWV','ZZZ','GOV') and clec_id is not null)         
)
)                     
order by 16,1;
