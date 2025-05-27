select c1,  REGEXP_REPLACE (c800006024,'[[:cntrl:]]*') closeout
from os3.t1074
where c1 in (
'OP-000000879831';


select substr(exchange_carrier_circuit_id,1,14) ckt, exchange_carrier_circuit_id, street_nbr||' '||street_nm||' '||street_suf address, ga1.instance_value city, ga2.instance_value_abbrev st, postal_cd 
from CIRCUIT CIR,
     net_loc_addr nla,
     address a,
     mv_ga_instance ga1,
     mv_ga_instance ga2
where cir.location_id = nla.location_id
and nla.address_id = a.address_id
and ga_instance_id_city = ga1.ga_instance_id
and ga_instance_id_state_cd = ga2.ga_instance_id
and substr(exchange_carrier_circuit_id,1,14) in (
'FA/KRGN/949098')
;

--To change timezone from EST to Eastern 

CAST(FROM_TZ(CAST(a.fld_startdate AS TIMESTAMP), 'GMT') AT TIME ZONE 'US/Eastern' AS DATE) AS CREATE
;




SELECT GA.INSTANCE_VALUE_ABBREV STATE,
       C1.CIRCUIT_DESIGN_ID EVC_CKT_ID,
       C1.EXCHANGE_CARRIER_CIRCUIT_ID EVC_CIRCUIT,
       C1.STATUS,
       D.ISSUE_STATUS,
       NSCR.NS_CON_REL_STATUS_CD,
       C2.CIRCUIT_DESIGN_ID UNI_CKT_ID,
       C2.EXCHANGE_CARRIER_CIRCUIT_ID UNI_CIRCUIT,
       C2.LOCATION_ID UNI_LOC_A,
       C2.LOCATION_ID_2 UNI_LOC_Z,
       NSCP1.NS_COMP_NM ORIG_ELEMENT_NM,
       NSCP2.NS_COMP_NM TERM_ELEMENT_NM,
       C2.RATE_CODE
 FROM CIRCUIT C1,
      SERV_ITEM SI,
      (SELECT DISTINCT *
       FROM (SELECT d.design_id,
                    d.issue_nbr,
                    d.serv_item_id,
                    d.issue_status,
          ROW_NUMBER() OVER (PARTITION BY serv_item_id ORDER BY issue_status ASC) r
          FROM asap.design D)
          WHERE r = 1) D,
      (SELECT DISTINCT *
       FROM (SELECT d.location_id,
                    d.address_id,
                    d.active_ind,
          ROW_NUMBER() OVER (PARTITION BY location_id ORDER BY address_id DESC) r
          FROM asap.net_loc_addr d
          WHERE active_ind = 'Y')
             WHERE r = 1) NLA,
      ADDRESS A,
      GA_INSTANCE GA,
      NS_CONNECTION NSC1,
      NS_CON_REL NSCR,
      CIRCUIT C2,
      NS_CONNECTION NSC2,
      NS_COMPONENT NSCP1,
      NS_COMPONENT NSCP2
  WHERE C1.CIRCUIT_DESIGN_ID = NSC1.CIRCUIT_DESIGN_ID
    AND C1.CIRCUIT_DESIGN_ID = SI.CIRCUIT_DESIGN_ID
    AND SI.SERV_ITEM_ID = D.SERV_ITEM_ID
    AND C1.LOCATION_ID = NLA.LOCATION_ID
    AND NLA.ADDRESS_ID = A.ADDRESS_ID
    AND A.GA_INSTANCE_ID_STATE_CD = GA.GA_INSTANCE_ID
    AND NSC1.CIRCUIT_DESIGN_ID = NSCR.CIRCUIT_DESIGN_ID_CHILD
    AND NSCR.CIRCUIT_DESIGN_ID_PARENT = C2.CIRCUIT_DESIGN_ID
    AND C2.CIRCUIT_DESIGN_ID = NSC2.CIRCUIT_DESIGN_ID
    AND NSC2.NS_COMP_ID_PARENT = NSCP1.NS_COMP_ID
    AND NSC2.NS_COMP_ID_CHILD = NSCP2.NS_COMP_ID
    AND (NSC1.NS_COMP_ID_PARENT = NSC2.NS_COMP_ID_PARENT
     OR NSC1.NS_COMP_ID_CHILD = NSC2.NS_COMP_ID_PARENT
     OR NSC1.NS_COMP_ID_CHILD = NSC2.NS_COMP_ID_CHILD)
    AND NSCR.NS_CON_REL_STATUS_CD <> '4'
    AND C1.CIRCUIT_DESIGN_ID IN (
--'9555699')
     SELECT CIRCUIT_DESIGN_ID FROM CIRCUIT
      WHERE SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID,1,14) IN (
'FA/VLXP/193437')
     )
;




select c.exchange_carrier_circuit_id, ns_comp_nm
from circuit c, ns_connection nsc, ns_component nscp
where c.circuit_design_id = nsc.circuit_design_id
and nsc.ns_comp_id_child = nscp.ns_comp_id
and substr(exchange_carrier_circuit_id,1,14) in (
'81/KFGS/500644')
;



SELECT distinct CIR.EXCHANGE_CARRIER_CIRCUIT_ID CKT,                
  max(status) keep (dense_rank last order by cir.last_modified_date) status,                
  replace(addr.addr_ln1,'MSAG ')||', '||addr.addr_ln3 as ORIG_LOC,                
  replace(addr2.addr_ln1,'MSAG ')||', '||addr2.addr_ln3 as TERM_LOC                
from CIRCUIT CIR,                
     net_loc_addr nla,                 
     address addr,                
     net_loc_addr nla2,                 
     address addr2                
where cir.location_id = nla.location_id (+)                
  and nla.address_id = addr.address_id (+)                
  and cir.location_id_2 = nla2.location_id (+)                
  and nla2.address_id = addr2.address_id (+)                
  and nla.active_ind (+) = 'Y'                
  and nla2.active_ind (+) = 'Y'                
  AND substr(CIR.EXCHANGE_CARRIER_CIRCUIT_ID,1,14) in (                
'21/KFGS/551679',
'50/KFGS/559432')                
GROUP BY CIR.EXCHANGE_CARRIER_CIRCUIT_ID, addr.addr_ln1, addr.addr_ln3, addr2.addr_ln1, addr2.addr_ln3                
order by 1                
;                


select document_number, type_of_sr, act, acna, acna_name, 
       REGEXP_REPLACE (end_user,'[[:cntrl:]]*') end_user,
       REGEXP_REPLACE (end_user2,'[[:cntrl:]]*') end_user2,
       dd_task_comp_dt, dd, task_type, work_queue_id, ckt_count
  from (     
select sr.document_number, type_of_sr, acna, acna_name, activity_ind,
       max(nl.location_name) keep (dense_rank last order by nl.last_modified_date) end_user,
       max(nl2.location_name) keep (dense_rank last order by nl2.last_modified_date) end_user2,
       trunc(t.actual_completion_date) dd_task_comp_dt, desired_due_date dd, 
       t2.task_type, t2.work_queue_id, count(src.circuit_design_id) ckt_count 
from serv_req sr,
     task t,
     task t2,
     service_request_circuit src,
     end_user_location_usage eulu,
     srsi_sr_loc ssl,
     network_location nl,
     network_location nl2,
     sr_loc srl
where sr.document_number = t.document_number
 and sr.document_number = t2.document_number
 and sr.document_number = src.document_number (+)
 and sr.document_number = eulu.document_number (+)
 and eulu.document_number = ssl.document_number (+)
 and eulu.usage_type = ssl.serv_loc_use (+)
 and eulu.serv_item_id = ssl.serv_item_id(+)
 and ssl.location_id = nl.location_id (+)
 and sr.document_number = srl.document_number (+)
 and srl.location_id = nl2.location_id (+)
 and srl.serv_loc_use(+) = 'PRILOC'
 and sr.supplement_type = '1'
 and to_char(t.actual_completion_date,'yyyy') in ('2017','2018')
 and t.task_type = 'DD'
 and substr(t2.work_queue_id,1,3) = 'RFC'
group by sr.document_number, type_of_sr, acna, acna_name, t.actual_completion_date, 
         desired_due_date, t2.task_type, t2.work_queue_id, nl.location_name, nl2.location_name
)
order by 1         
; 


select cir.exchange_carrier_circuit_id, node_name, netype.ne_type_id, ne_type_nm                
from circuit cir,                
     ns_connection nscon,                
     ns_component nscomp,                
     network_node node,                
     ne_type netype                
where cir.circuit_design_id = nscon.circuit_design_id                
  and (nscon.ns_comp_id_parent = nscomp.ns_comp_id                
  or nscon.ns_comp_id_child = nscomp.ns_comp_id)                
  and nscomp.network_node_id = node.network_node_id                
  and node.ne_type_id = netype.ne_type_id                
  and exchange_carrier_circuit_id in (                 
'101CL/GE10  /BRPTCT0114W/SMFRCTDS0CW'                
)      
:

--to pull out a value that follows ViryanetCallId in Notes text  
REGEXP_REPLACE(SUBSTR(note_text, INSTR(note_text,' ',INSTR(note_text,'ViryanetCallId'),1)+1,
         (CASE WHEN INSTR(note_text,' ',INSTR(note_text,'ViryanetCallId'),2)>0 THEN INSTR(note_text,' ',INSTR(note_text,'ViryanetCallId'),2) ELSE LENGTH(note_text)+1 END)
         -INSTR(note_text,' ',INSTR(note_text,'ViryanetCallId'),1)-1), '[^a-zA-Z0-9'']','') AS VNET