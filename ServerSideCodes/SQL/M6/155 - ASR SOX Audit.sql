select distinct docno, pon, ckt, asr_init, asr_clean, dd_task_comp, cad_task_comp, icsc, acna, state, request_type, act                
 from (                      
select distinct document_number docno, pon, ckt, asr_init, drec asr_clean, dd, dd_comp dd_task_comp, cad_comp cad_task_comp,                 
       project, icsc, acna, state, request_type, act, clli_code, npa, nxx        
from (                
select distinct document_number, trunc(asr_init) asr_init, trunc(drec) drec, dd, dd_comp, cad_comp,     
        pon, icsc, acna, project, clli_code,         
        case when state is not null then state        
             when clliz is not null then substr(clliz,5,2)        
             else substr(cllia,5,2) end state,    
        supp, ckt, expedite, npa, nxx, request_type, act        
from (                
select sr.document_number,                 
       asr.request_type,                 
       max(asr.project_identification) keep (dense_rank last order by asr.last_modified_date) project,             
       max(asr.date_time_sent) keep (dense_rank last order by asr.last_modified_date) drec,                 
       max(asr.desired_due_date) keep (dense_rank last order by asr.last_modified_date) DD,               
       max(asr.network_channel_service_code) keep (dense_rank last order by asr.last_modified_date) nc,             
       max(asr.pon) keep (dense_rank last order by asr.last_modified_date) pon,              
       max(access_provider_serv_ctr_code) icsc,             
       max(sr.acna) acna,              
       max(asr.activity_indicator) keep (dense_rank last order by asr.last_modified_date) act,             
       max(nl1.clli_code) keep (dense_rank last order by nl1.last_modified_date) clli_code,             
       max(substr(nl1.clli_code,1,6)) keep (dense_rank last order by nl1.last_modified_date) cllia,            
       max(substr(nl2.clli_code,1,6)) keep (dense_rank last order by nl2.last_modified_date) clliz,             
       trunc(t.actual_completion_date) DD_COMP,            
       trunc(t2.actual_completion_date) CAD_COMP,
       max(asr.supplement_type) keep (dense_rank last order by asr.last_modified_date) supp,            
       --max(sr.first_ecckt_id) keep (dense_rank last order by sr.last_modified_date) ckt,  
       C.EXCHANGE_CARRIER_CIRCUIT_ID CKT,          
       max(expedite_indicator) keep (dense_rank last order by asr.last_modified_date) expedite,            
       max(asr.npa) keep (dense_rank last order by asr.last_modified_date) npa,            
       max(asr.nxx) keep (dense_rank last order by asr.last_modified_date) nxx,
       min(nts.last_modified_date) keep (dense_rank first order by nts.last_modified_date) asr_init,
       substr(npa.exchange_area_clli,5,2) state            
from access_service_request asr,                
     serv_req sr,            
     network_location nl1,            
     network_location nl2,                
     task t,
     task t2,            
     circuit c,
     service_request_circuit src,
     notes nts,
     NPA_NXX NPA             
where sr.document_number = asr.document_number          
  AND SR.DOCUMENT_NUMBER = SRC.DOCUMENT_NUMBER (+)
  AND SRC.CIRCUIT_DESIGN_ID = C.CIRCUIT_DESIGN_ID (+)                  
  and c.location_id = nl1.location_id(+)                
  and c.location_id_2 = nl2.location_id(+)                
  and sr.document_number = t.document_number
  and sr.document_number = t2.document_number
  AND SR.DOCUMENT_NUMBER = NTS.DOCUMENT_NUMBER (+) 
  AND ASR.NPA = NPA.NPA (+)
  and asr.nxx = npa.nxx (+)               
and to_char(t2.actual_completion_date,'yyyymm') in ('202312')
  and t.actual_completion_date is not null                               
  and asr.order_type = 'ASR'                       
  and t.task_type = 'DD'     
  and t2.task_type = 'CAD' 
  and sr.acna not in ('ZTK') --,'ZZZ','ZWV','FLR')         
group by sr.document_number, asr.request_type, t.actual_completion_date, t2.actual_completion_date, npa.exchange_area_clli,
         C.EXCHANGE_CARRIER_CIRCUIT_ID                
)                   
)                
where (supp <> 1 or supp is null)                 
)                   
order by 7, 1;
