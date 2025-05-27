--pulls the RUIDS based on the last order and pulls in the UNI-NNI indicator 
select evc, docno, cir.exchange_carrier_circuit_id uni, cir.status, 
       case when cud.uni_or_nni = '435' then 'UNI'
            when cud.uni_or_nni = '436' then 'NNI'
            else 'CHECK' end UNI_TYPE
from (
--
select a.exchange_carrier_circuit_id evc, a.docno, rel_uni_ident ruid,
       REGEXP_REPLACE(rel_uni_ident,'[^a-zA-Z0-9'']','') RUID3 
from
( 
select max(src.document_number) docno, c.exchange_carrier_circuit_id
from service_request_circuit src, circuit c, serv_req sr
where src.circuit_design_id = c.circuit_design_id
and src.document_number = sr.document_number
and order_compl_dt is not null
and (sr.supplement_type <> 1 or sr.supplement_type is null)
and substr(c.exchange_carrier_circuit_id,1,21) in (
'30/VLXP/004291/   /FT')
group by c.exchange_carrier_circuit_id
) a, evc_uni_map eum
where a.docno = eum.document_number
--
) b, 
  (SELECT DISTINCT *        
      FROM (select circuit_design_id,         
                   exchange_carrier_circuit_id,
                   REGEXP_REPLACE(exchange_carrier_circuit_id,'[^a-zA-Z0-9'']','') ckt,         
                   status,        
                   ROW_NUMBER() OVER (PARTITION BY exchange_carrier_circuit_id ORDER BY last_modified_date DESC) r        
               FROM circuit )        
                   WHERE r = 1) cir,                           
  circuit_user_data cud
where b.ruid3 = cir.ckt
and cir.circuit_design_id = cud.circuit_design_id (+)
order by 1, 5 desc;
;





--if you have the EVC  

select EVC, evc_id, status_cd,uni, uni_id, mod_dt,                                            
       case when svc_cd = 'KP' then 1
            when svc_cd = 'KD' then 2                                            
            when svc_cd = 'KQ' then 3                                            
            when svc_cd = 'KE' then 4                                            
            when svc_cd = 'KR' then 5                                            
            when svc_cd = 'KF' then 6                                            
            when svc_cd = 'KS' then 7                                            
            when svc_cd = 'KG' then 8                                            
            when svc_cd = 'SX' then 9                                            
            when svc_cd = 'SN' then 9                                            
            else 0 end lev, uni_stat,
       case when cud.uni_or_nni = '435' then 'UNI'
            when cud.uni_or_nni = '436' then 'NNI'
            else 'CHECK' end UNI_TYPE                                                           
 from (                                          
-----------------------------                                             
select c1.exchange_carrier_circuit_id EVC, c1.circuit_design_id evc_id, ns_con_rel_status_cd status_cd,                                            
       c2.exchange_carrier_circuit_id UNI, c2.circuit_design_id uni_id, c2.last_modified_date mod_dt, substr(c2.exchange_carrier_circuit_id,4,2) SVC_CD, c2.status uni_stat                                                          
from ns_con_rel ncr,                                                        
     circuit c1,                                                        
     circuit c2                                                       
where ncr.CIRCUIT_DESIGN_ID_child = c1.circuit_design_id                                                         
and ncr.CIRCUIT_DESIGN_ID_PARENT = c2.circuit_design_id                                              
AND SUBSTR(C2.EXCHANGE_CARRIER_CIRCUIT_ID,4,1) IN ('K','S')                                                       
and substr(c1.exchange_carrier_circuit_id,1,21) in (                                            
'87/VLXP/025344/   /CZ',
'87/VLXP/025346/   /CZ')  
) a, circuit_user_data cud
where a.uni_id = cud.circuit_design_id (+)                                                                                               
order by 1,7                                                        
;                                            

--If you have the UNI 

select c1.exchange_carrier_circuit_id UNI, c1.circuit_design_id UNI_id, ns_con_rel_status_cd status_cd,                                            
       c2.exchange_carrier_circuit_id EVC, c2.circuit_design_id evc_id, c2.last_modified_date mod_dt                                                          
from ns_con_rel ncr,                                                        
     circuit c1,                                                        
     circuit c2                                                       
where ncr.CIRCUIT_DESIGN_ID_PARENT = c1.circuit_design_id                                                         
and ncr.CIRCUIT_DESIGN_ID_CHILD = c2.circuit_design_id                                                                                                   
and substr(c1.exchange_carrier_circuit_id,1,14) in (                                            
'12/KDGS/700029')
order by 1,4 
;

--other option if you have the EVC 

SELECT EVC_CIRCUIT, STATUS, ISSUE_STATUS, UNI_CIRCUIT,                    
       CASE WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'KP' THEN '1'                    
            WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'KD' THEN '2'                    
            WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'KQ' THEN '3'                    
            WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'KE' THEN '4'                    
            WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'KR' THEN '5'                    
            WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'KF' THEN '6'                    
            WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'KS' THEN '7'                    
            WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'KG' THEN '8'                    
            WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'SN' THEN '9'                    
            WHEN SUBSTR(UNI_CIRCUIT,4,2) = 'SX' THEN '9'                    
            ELSE 'CHECK' END LEV,					
       RATE_CODE     					
FROM (					
SELECT C1.EXCHANGE_CARRIER_CIRCUIT_ID EVC_CIRCUIT,					
       C1.STATUS,					
       D.ISSUE_STATUS,					
       C2.EXCHANGE_CARRIER_CIRCUIT_ID UNI_CIRCUIT,					
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
      WHERE SUBSTR(EXCHANGE_CARRIER_CIRCUIT_ID,1,20) IN (					
'FA/VLXP/588061/   /S')					
     ))					
ORDER BY 1,5     					
;					

--TO IDENTIFY THE RUIDS BASED ON THE LAST ORDER  
select a.exchange_carrier_circuit_id, a.docno, rel_uni_ident
from
( 
select max(src.document_number) docno, c.exchange_carrier_circuit_id
from service_request_circuit src, circuit c, serv_req sr
where src.circuit_design_id = c.circuit_design_id
and src.document_number = sr.document_number
and order_compl_dt is not null
and (sr.supplement_type <> 1 or sr.supplement_type is null)
and substr(c.exchange_carrier_circuit_id,1,20) in (
'65/VLXP/132169/   /F',
'65/VLXP/132170/   /F')
group by c.exchange_carrier_circuit_id
) a, evc_uni_map eum
where a.docno = eum.document_number
order by 1,3
;




-- To see if there is an ACTL (NNI)  
select distinct ecckt, 
       MAX(access_cust_terminal_location) KEEP (DENSE_RANK LAST ORDER BY ISSUE_NBR) ACTL
from design_layout_report
where substr(ecckt,1,14) in (
'FA/KRGN/581103'
)
group by ecckt;
