select month, ticket_id, create_date, cleared_dt, closed_dt, ttr, request_type, repair_code,
       ckt_id, clec_id, customer, site_state, clli_code, priloc, secloc 
from (
select to_char(closed_dt,'yyyymm') month, ticket_id,  
       create_date, 
	   case when Cleared_Dt is not null then Cleared_dt
            else Closed_dt end Cleared_Dt, 
	   case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,
       total_duration, ttr, repair_code,
       ckt_id, clli_code, priloc, secloc, b.disp, customer, request_type, site_state, 
       case when acna is not null then acna
	        when acna1 is not null then acna1
	        when ccna1 is not null then ccna1
			when acna2 is not null then acna2
            else ccna2 end CLEC_ID
from (	   		  
select a.fld_requestid ticket_id, 
       max(substr(a.fld_siteid,5,2)) keep (dense_rank last order by a.fld_modifieddate) site_state, 
	   max(upper(d.ec_company_code)) keep (dense_rank last order by d.last_modified_date) icsc,
	   a.exchange_carrier_circuit_id ckt_id, 
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit,
	   max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,
	   max(d.acna) keep (dense_rank first order by d.last_modified_date) acna2, 
	   max(d.ccna) keep (dense_rank first order by d.last_modified_date) ccna2,
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
	   max(round(a.h_fld_totalopentime_secs_/3600,2)) keep (dense_rank last order by a.fld_modifieddate) Total_Duration,
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
	   max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,  
       max(e.type) keep (dense_rank last order by e.last_modified_date) type,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code,
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
	   max(a.fld_troublereportstate) keep (dense_rank last order by a.fld_modifieddate) trblstat,
	   max(f.clli_code) keep (dense_rank last order by f.last_modified_date) clli_code,
       max(d.primary_location) keep (dense_rank last order by d.last_modified_date) priloc, 
	   max(d.secondary_location) keep (dense_rank last order by d.last_modified_date) secloc,
	   max(a.fld_alocationaccessname2) customer
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e,
	 casdw.network_location f
where a.fld_troublereportstate = 'closed'
 and a.fld_assignmentprofile in ('CNOC','Commercial-CTF','Premier Center')
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and e.location_id = f.location_id(+)
 and (e.type <> 'T' or type is null) 
 and e.status (+) = '6'
 and (to_char(dte_closeddatetime,'yyyymm') = '202312'    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') = '202312'))   --NEED TO CHANGE THIS EACH MONTH
 and(a.exchange_carrier_circuit_id like '61%KRGN%196139%'
or a.exchange_carrier_circuit_id like '50%KQGN%235593%'
or a.exchange_carrier_circuit_id like '45%KRGN%590571%'
or a.exchange_carrier_circuit_id like '%KQGN%976850%'
or a.exchange_carrier_circuit_id like '%KQGN%973272%'
or a.exchange_carrier_circuit_id like '45%KRGN%749225%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%596628%'
or a.exchange_carrier_circuit_id like '%KQGN%978943%'
or a.exchange_carrier_circuit_id like '%KRGN%684263%'
or a.exchange_carrier_circuit_id like '63%L1XN%622853%'
or a.exchange_carrier_circuit_id like '61%L1XN%624487%'
or a.exchange_carrier_circuit_id like '45%L1XN%621582%'
or a.exchange_carrier_circuit_id like '13%L1XN%626547%'
or a.exchange_carrier_circuit_id like '45%L1XN%623986%'
or a.exchange_carrier_circuit_id like '%KQGN%684263%'
or a.exchange_carrier_circuit_id like '%KQGN%946734%'
or a.exchange_carrier_circuit_id like '%KQGN%845261%'
or a.exchange_carrier_circuit_id like '13%L1XN%632744%'
or a.exchange_carrier_circuit_id like '45%L1XN%645005%'
or a.exchange_carrier_circuit_id like '45%L1XN%639194%'
or a.exchange_carrier_circuit_id like '%KQGN%548538%'
or a.exchange_carrier_circuit_id like '%KQGN%652243%'
or a.exchange_carrier_circuit_id like '13%L1XN%646875%'
or a.exchange_carrier_circuit_id like '13%L1XN%650187%'
or a.exchange_carrier_circuit_id like '45%L1XN%656184%'
or a.exchange_carrier_circuit_id like '45%L1XN%669638%'
or a.exchange_carrier_circuit_id like '45%L1XN%655960%'
or a.exchange_carrier_circuit_id like '61%L2XN%671516%'
or a.exchange_carrier_circuit_id like '50%L4XN%676580%'
or a.exchange_carrier_circuit_id like '45%L1XN%676480%'
or a.exchange_carrier_circuit_id like '87%L1XN%677839%'
or a.exchange_carrier_circuit_id like '45%L1XN%678363%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%680691%'
or a.exchange_carrier_circuit_id like '45%L1XN%682350%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%686726%'
or a.exchange_carrier_circuit_id like '%KQGN%957874%'
or a.exchange_carrier_circuit_id like '36%L1XN%688262%'
or a.exchange_carrier_circuit_id like '45%L1XN%693847%'
or a.exchange_carrier_circuit_id like '45%L1XN%692626%'
or a.exchange_carrier_circuit_id like '13%L1XN%697364%'
or a.exchange_carrier_circuit_id like '13%L1XN%697343%'
or a.exchange_carrier_circuit_id like '45%L1XN%698413%'
or a.exchange_carrier_circuit_id like '%BFEC%500938%'
or a.exchange_carrier_circuit_id like '13%L1XN%702490%'
or a.exchange_carrier_circuit_id like '45%L1XN%702847%'
or a.exchange_carrier_circuit_id like '45%L1XN%702765%'
or a.exchange_carrier_circuit_id like '61%KRGN%198281%'
or a.exchange_carrier_circuit_id like '45%L1XN%705251%'
or a.exchange_carrier_circuit_id like '61%L1XN%706732%'
or a.exchange_carrier_circuit_id like '45%L1XN%706820%'
or a.exchange_carrier_circuit_id like '45%L1XN%707875%'
or a.exchange_carrier_circuit_id like '65%L1XN%709420%'
or a.exchange_carrier_circuit_id like '65%L1XN%710837%'
or a.exchange_carrier_circuit_id like '65%L1XN%705591%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%713177%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%709989%'
or a.exchange_carrier_circuit_id like '87%L1XN%712591%'
or a.exchange_carrier_circuit_id like '39%L1XN%710894%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%712208%'
or a.exchange_carrier_circuit_id like '65%L1XN%711123%'
or a.exchange_carrier_circuit_id like '13%L1XN%717994%'
or a.exchange_carrier_circuit_id like '45%L1XN%713527%'
or a.exchange_carrier_circuit_id like '45%L1XN%718486%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%716447%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%717349%'
or a.exchange_carrier_circuit_id like '45%L1XN%387641%'
or a.exchange_carrier_circuit_id like '87%L1XN%718983%'
or a.exchange_carrier_circuit_id like '45%L1XN%721419%'
or a.exchange_carrier_circuit_id like '65%L1XN%716815%'
or a.exchange_carrier_circuit_id like '31%L1XN%720084%'
or a.exchange_carrier_circuit_id like '13%L1XN%713225%'
or a.exchange_carrier_circuit_id like '63%L1XN%717361%'
or a.exchange_carrier_circuit_id like '65%L1XN%717438%'
or a.exchange_carrier_circuit_id like '65%L1XN%713429%'
or a.exchange_carrier_circuit_id like '45%L1XN%715631%'
or a.exchange_carrier_circuit_id like '45%L1XN%424881%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%720759%'
or a.exchange_carrier_circuit_id like '63%L1XN%410030%'
or a.exchange_carrier_circuit_id like '45%L1XN%721151%'
or a.exchange_carrier_circuit_id like '61%KRGN%196139%'
or a.exchange_carrier_circuit_id like '45%L1XN%717383%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%710871%'
or a.exchange_carrier_circuit_id like '65%L1XN%409971%'
or a.exchange_carrier_circuit_id like '45%L1XN%433171%'
or a.exchange_carrier_circuit_id like '50%L1XN%414681%'
or a.exchange_carrier_circuit_id like '45%L1XN%459419%'
or a.exchange_carrier_circuit_id like '45%L1XN%442690%'
or a.exchange_carrier_circuit_id like '45%L1XN%721468%'
or a.exchange_carrier_circuit_id like '45%L1XN%720708%'
or a.exchange_carrier_circuit_id like '65%L1XN%388604%'
or a.exchange_carrier_circuit_id like '45%L1XN%433603%'
or a.exchange_carrier_circuit_id like '45%L1XN%455230%'
or a.exchange_carrier_circuit_id like '65%L1XN%422588%'
or a.exchange_carrier_circuit_id like '45%L1XN%427273%'
or a.exchange_carrier_circuit_id like '45%L1XN%474814%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%457516%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%476338%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%495819%'
or a.exchange_carrier_circuit_id like '65%L4XN%459344%'
or a.exchange_carrier_circuit_id like '65%L1XN%474075%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%542781%'
or a.exchange_carrier_circuit_id like '13%L1XN%720746%'
or a.exchange_carrier_circuit_id like '45%L1XN%713919%'
or a.exchange_carrier_circuit_id like '45%L1XN%535122%'
or a.exchange_carrier_circuit_id like '65%L1XN%481422%'
or a.exchange_carrier_circuit_id like '45%L4XN%550637%'
or a.exchange_carrier_circuit_id like '23%L1XN%539591%'
or a.exchange_carrier_circuit_id like '65%L1XN%562420%'
or a.exchange_carrier_circuit_id like 'FA%L4XN%520952%'
or a.exchange_carrier_circuit_id like '65%L4XN%555875%'
or a.exchange_carrier_circuit_id like '31%L1XN%477263%'
or a.exchange_carrier_circuit_id like '45%L1XN%519217%'
or a.exchange_carrier_circuit_id like '45%L1XN%539735%'
or a.exchange_carrier_circuit_id like '45%L1XN%444734%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%555117%'
or a.exchange_carrier_circuit_id like '45%L1XN%717426%'
or a.exchange_carrier_circuit_id like '31%L1XN%581553%'
or a.exchange_carrier_circuit_id like '45%L1XN%588421%'
or a.exchange_carrier_circuit_id like '13%L1XN%576377%'
or a.exchange_carrier_circuit_id like '87%L1XN%584677%'
or a.exchange_carrier_circuit_id like '45%L1XN%519324%'
or a.exchange_carrier_circuit_id like '61%L1XN%584668%'
or a.exchange_carrier_circuit_id like '45%L1XN%642011%'
or a.exchange_carrier_circuit_id like '45%L1XN%647214%'
or a.exchange_carrier_circuit_id like '45%L1XN%474250%'
or a.exchange_carrier_circuit_id like '13%L1XN%560179%'
or a.exchange_carrier_circuit_id like '65%L1XN%584951%'
or a.exchange_carrier_circuit_id like '45%L1XN%519120%'
or a.exchange_carrier_circuit_id like '13%L1XN%560732%'
or a.exchange_carrier_circuit_id like '13%L4XN%627240%'
or a.exchange_carrier_circuit_id like '13%L4XN%627226%'
or a.exchange_carrier_circuit_id like '36%L1XN%594607%'
or a.exchange_carrier_circuit_id like '61%L1XN%689057%'
or a.exchange_carrier_circuit_id like '65%L1XN%606985%'
or a.exchange_carrier_circuit_id like '13%L1XN%698359%'
or a.exchange_carrier_circuit_id like '13%L1XN%697084%'
or a.exchange_carrier_circuit_id like '13%L1XN%645273%'
or a.exchange_carrier_circuit_id like '13%L1XN%740026%'
or a.exchange_carrier_circuit_id like '30%L1XN%739998%'
or a.exchange_carrier_circuit_id like '65%L1XN%585240%'
or a.exchange_carrier_circuit_id like '13%L1XN%542901%'
or a.exchange_carrier_circuit_id like '13%L1XN%698368%'
or a.exchange_carrier_circuit_id like '13%L1XN%697123%'
or a.exchange_carrier_circuit_id like '13%L1XN%739876%'
or a.exchange_carrier_circuit_id like '31%L4XN%687361%'
or a.exchange_carrier_circuit_id like '13%L1XN%739886%'
or a.exchange_carrier_circuit_id like '31%L1XN%626807%'
or a.exchange_carrier_circuit_id like '63%L1XN%731991%'
or a.exchange_carrier_circuit_id like '30%L1XN%733310%'
or a.exchange_carrier_circuit_id like '65%L1XN%733759%'
or a.exchange_carrier_circuit_id like 'FA%L1XN%688921%'
or a.exchange_carrier_circuit_id like '36%L1XN%712364%'
or a.exchange_carrier_circuit_id like '45%L1XN%819053%'
or a.exchange_carrier_circuit_id like '45%L1XN%743162%'
or a.exchange_carrier_circuit_id like '45%L4XN%753515%'
or a.exchange_carrier_circuit_id like '45%L4XN%759700%'
or a.exchange_carrier_circuit_id like '45%L4XN%759704%'
or a.exchange_carrier_circuit_id like '45%L1XN%856700%'
or a.exchange_carrier_circuit_id like '13%L4XN%833528%'
or a.exchange_carrier_circuit_id like '45%L4XN%825857%'
or a.exchange_carrier_circuit_id like '45%L1XN%806711%'
or a.exchange_carrier_circuit_id like '45%L1XN%879094%'
or a.exchange_carrier_circuit_id like '31%L4XN%776247%'
or a.exchange_carrier_circuit_id like '45%L1XN%827895%'
or a.exchange_carrier_circuit_id like '45%L1XN%844018%'
or a.exchange_carrier_circuit_id like '45%L1XN%838622%'
or a.exchange_carrier_circuit_id like '13%L1XN%887005%'
or a.exchange_carrier_circuit_id like '45%L1XN%943097%'
or a.exchange_carrier_circuit_id like '13%L4XN%988637%'
or a.exchange_carrier_circuit_id like '50%L1XN%984919%'
or a.exchange_carrier_circuit_id like '45%L1XN%000998%'
or a.exchange_carrier_circuit_id like '31%L1XN%012731%'
or a.exchange_carrier_circuit_id like '45%L1XN%992546%'
or a.exchange_carrier_circuit_id like '30%L1XN%011395%'
or a.exchange_carrier_circuit_id like '30%L1XN%758112%'
or a.exchange_carrier_circuit_id like '50%L1XN%027384%'
or a.exchange_carrier_circuit_id like '65%L1XN%926015%'
or a.exchange_carrier_circuit_id like '30%L1XN%054133%'
or a.exchange_carrier_circuit_id like '61%L1XN%016264%'
or a.exchange_carrier_circuit_id like '45%L4XN%995710%'
or a.exchange_carrier_circuit_id like '45%L1XN%024003%'
or a.exchange_carrier_circuit_id like '65%L1XN%027385%'
)
group by a.fld_requestid, a.exchange_carrier_circuit_id
) a, trbl_found_remedy b
where a.repair_code = b.trbl_found_desc (+)    
and reqstat = 'Closed'
--and request_type in ('Agent','Alarm','Customer','Maintenance')
)
--where disp in ('CC','NTF','CO','FAC')
order by 2
;



