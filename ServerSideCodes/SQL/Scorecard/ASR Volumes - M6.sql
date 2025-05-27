

select region, count(*)
from (
select case when st in ('AZ','CA','ID','IL','NV','OH','OR','WA','WI')  and substr(icsc,1,2) = 'FV' then 'F9'
            when icsc in ('FV02','FV03','FV04') then 'F9'
			when st in ('OH','WA') then 'F9'
			else 'Other' end region
from (
select pon, ver, request_type, icsc,
       case when state is not null then state
	        when secloc is not null then secloc
			when priloc is not null then priloc
			when substr(proj,1,7) = 'ATTMOB-' then substr(proj,12,2)
			else state end st
from (
select distinct pon, version_identification ver, request_type, access_provider_serv_ctr_code icsc, substr(nl.clli_code,5,2) state, 
       dlr.priloc_state priloc, dlr.secloc_state secloc, asr.project_identification proj
from casdw.access_service_request asr,
     casdw.network_location nl,
	 casdw.design_layout_report dlr
where asr.location_id = nl.location_id(+)
and asr.document_number = dlr.document_number (+) 
and pon is not null
and request_type <> 'X'
and asr.order_type = 'ASR'
and to_char(date_received,'yyyymmdd') = '20120410'
)))
group by region
order by 1 
   
   




