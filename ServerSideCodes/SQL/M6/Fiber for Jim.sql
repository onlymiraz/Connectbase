drop table tempethernet2

CREATE TABLE tempethernet2 NOLOGGING NOCACHE AS	
select ckt, design, icsc, rate, type, nc, nci, acna, ccna, state, svc_cd, cllia, clliz, cllialong, cllialat, cllizlong, cllizlat 	
from (	
select exchange_carrier_circuit_id ckt,	
       max(c.circuit_design_id) keep (dense_rank last order by c.last_modified_date) design,	
       max(ec_company_code) keep (dense_rank last order by d.last_modified_date) icsc, 	
       max(rate_code) keep (dense_rank last order by c.last_modified_date) rate, 	
	   max(c.type) keep (dense_rank last order by c.last_modified_date) type, 
	   max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna,
	   max(d.network_channel_code) keep (dense_rank last order by d.last_modified_date) nc, 
	   max(d.network_channel_interface_code) keep (dense_rank last order by d.last_modified_date) nci,  
	   max(substr(nl2.clli_code,5,2)) keep (dense_rank last order by nl2.last_modified_date) state, 
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
	   max(substr(d.order_nbr,1,3)) keep (dense_rank last order by d.last_modified_date) ordnum,
	   max(d.last_modified_userid)  keep (dense_rank last order by d.last_modified_date) lastmod,
	   nl1.clli_code cllia,
	   nl2.clli_code clliz,
	   nl1.longitude cllialong,
	   nl1.latitude cllialat,
	   nl2.longitude cllizlong,
	   nl2.latitude cllizlat
from circuit c, 	
     design_layout_report d, 	
	 network_location nl1,
	 network_location nl2
where c.exchange_carrier_circuit_id = d.ecckt(+)	
and c.LOCATION_ID = NL1.LOCATION_ID(+)	
and c.LOCATION_ID_2 = NL2.LOCATION_ID(+)	
and c.type <> 'T'
and substr(d.network_channel_interface_code,5,1) = 'F'	
--and service_type_code not in ('VM','KA','KB','KC','KM','KX','KY','VR')	
--and substr(exchange_carrier_circuit_id,4,2) <> 'VM'	
--and substr(exchange_carrier_circuit_id,4,1) in ('V','K')	
group by exchange_carrier_circuit_id,nl1.clli_code,	
	   nl2.clli_code,
	   nl1.longitude,
	   nl1.latitude,
	   nl2.longitude,
	   nl2.latitude
)	
where substr(ckt,7,1) <> 'U'	
and status = '6'	
	
	

	
select ckt, rate, acna, ccna, 
case when ccna in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AUA','AUR',
'AUZ','AWL','AWN','AXD','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BNY','BPN','BSM','BTE','CBL','CCB','CDA','CDP','CEJ',
'CEO','CEU','CFN','CGH','CIF','CIV','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO','CSU','CSX','CTJ','CUO','CXA','CZB',
'DBY','DIC','DNC','DUT','EKC','EST','ETP','ETX','EWC','FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLN','HLU','HNC',
'HRN','HTN','HWC','IFP','IMP','IND','ISZ','IUW','JCT','KYR','LAA','LAC','LBH','LHR','LNZ','LSZ','MBQ','MCA','MCC','MCE',
'MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MKN','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MUM','MWB','MWZ','NBC','NHO',
'NPW','OAK','OCL','ORV','OSU','PCK','PCW','PFM','PIG','PKG','RAD','RFC','RMC','RMF','RRC','SBG','SBM','SBN','SCU','SCZ',
'SHI','SLL','SMC','SNP','STH','SUF','SVU','SWM','SWP','SWT','SWV','SYC','SYG','SZM','TGH','TQU','UMT','VGD','VRA','WBT',
'WCX','WGL','WLG','WLZ','WVO','WWC','YBG') then 'ATT MOBILITY'
when ccna in ('AEY','CXJ','DCC','DCX','EIP','GLF','GUS','IGW','LPL','MJC','NLZ','NXT','ONM','ROW','SWQ','SZC','UBQ','WEL','WOW','WSO') then 'SPRINT PCS'
when ccna in ('ABW','APT','ICJ','OPT','PSO','PWR','SJV','TZV','WCG') then 'TMOBILE'
when ccna in ('CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','UCU','USC','WCT') then 'US CELLULAR'
else 'VERIZON WIRELESS' end carrier,
state, svc_cd, nc, nci, cllia, clliz, cllialong, cllialat, cllizlong, cllizlat, 	
max(clr_pri_nl_addr_ln1) keep (dense_rank last order by issue_nbr) pri_addr, 	
max(clr_pri_nl_addr_ln3) keep (dense_rank last order by issue_nbr) pri_addr_city,	
max(clr_sec_nl_addr_ln1) keep (dense_rank last order by issue_nbr) sec_addr, 	
max(clr_sec_nl_addr_ln3) keep (dense_rank last order by issue_nbr) sec_addr_city,	
max(issue_nbr) keep (dense_rank last order by issue_nbr) issue  	
from tempethernet2 t, circuit_layout_report clr	
where t.design = clr.circuit_design_id (+)  
AND CCNA IN (
'AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO','AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AUA','AUR',
'AUZ','AWL','AWN','AXD','AZE','BAC','BAK','BAO','BCU','BFL','BGH','BNY','BPN','BSM','BTE','CBL','CCB','CDA','CDP','CEJ',
'CEO','CEU','CFN','CGH','CIF','CIV','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG','CSO','CSU','CSX','CTJ','CUO','CXA','CZB',
'DBY','DIC','DNC','DUT','EKC','EST','ETP','ETX','EWC','FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLN','HLU','HNC',
'HRN','HTN','HWC','IFP','IMP','IND','ISZ','IUW','JCT','KYR','LAA','LAC','LBH','LHR','LNZ','LSZ','MBQ','MCA','MCC','MCE',
'MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MKN','MLA','MLZ','MMV','MOB','MOE','MTX','MUI','MUM','MWB','MWZ','NBC','NHO',
'NPW','OAK','OCL','ORV','OSU','PCK','PCW','PFM','PIG','PKG','RAD','RFC','RMC','RMF','RRC','SBG','SBM','SBN','SCU','SCZ',
'SHI','SLL','SMC','SNP','STH','SUF','SVU','SWM','SWP','SWT','SWV','SYC','SYG','SZM','TGH','TQU','UMT','VGD','VRA','WBT',
'WCX','WGL','WLG','WLZ','WVO','WWC','YBG',
'AEY','CXJ','DCC','DCX','EIP','GLF','GUS','IGW','LPL','MJC','NLZ','NXT','ONM','ROW','SWQ','SZC','UBQ','WEL','WOW','WSO',
'ABW','APT','ICJ','OPT','PSO','PWR','SJV','TZV','WCG',
'CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','UCU','USC','WCT',
'AAK','AHG','AKR','AOK','AUL','BAM','BBK','BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','CLW','CMO','CNL','CNN','COQ','CRB',
'CRR','CRY','CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG','DYT','EBA','ECT','FCO','FCS','FMN','FNT','GAF','GEX','GMB',
'GMT','GNL','GTB','GTE','GVU','IAP','ICN','IDE','IPD','JCC','KOC','LCN','LSC','LTT','MBN','MCB','MJP','MMH','MMO','NBT',
'NOH','NVC','NYM','NYR','OHC','OMC','PCF','PLP','PPM','PTE','PTG','PTI','PTM','PUL','RMB','RMD','SOT','SRY','SZP','TDQ',
'TDU','ULN','UNV','UTI','UTS','VRZ')
group by ckt, rate, acna, ccna, state, svc_cd, nc, nci,cllia, clliz, cllialong, cllialat, cllizlong, cllizlat	


