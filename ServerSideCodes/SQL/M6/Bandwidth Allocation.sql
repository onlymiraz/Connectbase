select nni, nni_bdw_gb, sum(evc_bdw_gb) evc_sum, nni_bdw_gb*min_thresh min_thresh, nni_bdw_gb*max_thresh max_thresh
from (
select nni, nni_design_id, nni_status, nni_bdw_gb, evc, evc_design_id, evc_status,
        min_thresh/100 min_thresh, max_thresh/100 max_thresh, evc_bdw/1000 evc_bdw_gb
from (        
select  nni, nni_design_id, nni_status, nni_bdw/1000 nni_bdw_gb, evc, evc_design_id, evc_status, 
        min_thresh, max_thresh, --ccvevc.ca_value evc_bdw, 
        CASE WHEN ccvevc.ca_value_uom = 'G' THEN TO_NUMBER(REGEXP_REPLACE(ccvevc.ca_value,'[^.^0-9'']','')) *1000 
        ELSE TO_NUMBER(REGEXP_REPLACE(ccvevc.ca_value,'[^.^0-9'']','')) END as evc_bdw,
        DENSE_RANK() OVER (PARTITION BY ccvevc.circuit_design_id ORDER BY ccvevc.conn_ca_value_id DESC) AS RANK  
from (       
--*
select distinct parent_circuit nni, parent_circuit_design nni_design_id, parent_circuit_status nni_status, ccv1.ca_value nni_bdw, 
       child_circuit evc, child_circuit_design evc_design_id, child_circuit_status evc_status, ccv2.ca_value min_thresh, ccv3.ca_value max_thresh,
       DENSE_RANK() OVER (PARTITION BY ccv1.circuit_design_id ORDER BY ccv1.conn_ca_value_id DESC) AS RANK1,
       DENSE_RANK() OVER (PARTITION BY ccv2.circuit_design_id ORDER BY ccv2.conn_ca_value_id DESC) AS RANK2,
       DENSE_RANK() OVER (PARTITION BY ccv3.circuit_design_id ORDER BY ccv3.conn_ca_value_id DESC) AS RANK3
from team_oss.vw_parent_child_circuits ckt,
     conn_ca_value ccv1,
     conn_ca_value ccv2,
     conn_ca_value ccv3
where ckt.parent_circuit_design = ccv1.circuit_design_id
  and ckt.parent_circuit_design = ccv2.circuit_design_id
  and ckt.parent_circuit_design = ccv3.circuit_design_id
  and ccv1.ca_value_label = 'SPEED'
  and ccv1.current_row_ind = 'Y'
  and ccv2.ca_value_label = 'QoS Warning Threshold'
  and ccv2.current_row_ind = 'Y'
  and ccv3.ca_value_label = 'QoS Prevention Threshold'
  and ccv3.current_row_ind = 'Y'
  and parent_circuit like '45/SXGS/524483%' --'23/SXGS/609627%' 
--*
)a,
 conn_ca_value ccvevc
where a.evc_design_id = ccvevc.circuit_design_id
  and ca_value_label = 'CIR'
  and rank1 = 1
  and rank2 = 1
  and rank3 = 1
) 
where rank = 1  
)
group by nni, nni_bdw_gb, min_thresh, max_thresh
;