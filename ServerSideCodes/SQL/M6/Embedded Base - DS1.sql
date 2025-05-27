drop table txds1;

create table TXDS1 nologging nocache as
select ckt, icsc, prod, clec_id,
       case when clec_id in ('ATX','TPM','AAV','SBB','SBZ','SUV') then 'ATT COMMUNICATIONS'
	        when clec_id in ('AAX','ACF','ACH','ADM','AEC','AGS','AGZ','AHA','AHD','AHM','AHO',
	   			  'AIL','AIN','AIS','AKZ','ALY','AMH','AMP','AWS','AWL','AWN','AZE','BAC',
				  'BAK','BAO','BCU','BFL','BGH','BMI','BPN','BSM','CBL','CCB','CDA','CEL',
				  'CEO','CEU','CFN','CIV','CIW','CKQ','CLQ','COW','CQW','CRF','CRJ','CSG',
				  'CSO','CSU','CSX','CTJ','CUO','CUY','CZB','DNC','EKC','ETP','EST','ETX',
				  'FLA','FSC','FSI','FSV','GEE','GLV','GSL','HGN','HLU','HNC','HTN','HWC',
				  'IMP','IND','ISZ','IUW','JCT','LAA','LAC','LBH','LNZ','LSZ','MBN','MBQ',
				  'MCA','MCC','MCE','MCQ','MCV','MCW','MCZ','MFN','MIB','MIR','MLA','MLZ',
				  'MMV','MOB','MOE','MTX','MUI','MWB','MWZ','NBC','NWW','OAK','OCL','ORV',
				  'OSU','PCK','PFM','PIG','RAD','RMC','RMF','RRC','SBG','SBM','SBN','SCU',
				  'SHI','SLL','SMC','SNP','STH','SUF','SWM','SWP','SWT','SWV','SYC','SZM',
				  'TGH','TQU','UMT','VGD','VRA','WBT','WGL','WLG','WLZ','WVO','WWC','ZBM','ZWO') then 'ATT MOBILITY'
			when clec_id in ('FWN','FET') then 'LUMOS'
			when clec_id in ('AJQ','ALN','AQH','ASC','ASI','AVZ','BUC','BUR','BWG','CNK','COS','CTO','EAK',
			      'EAS','ENW','EPK','ESM','FLS','FOC','GBG','GIE','GSX','GTT','HCU','HCV','HDC','HDE','HFL',
				  'HMA','HMD','HNH','HNI','HNJ','HNY','HOR','HPA','HPI','HRH','HSE','HTJ','HWV','HYH','HYS',
  				  'HYV','ICG','IMR','IPX','IXC','LGG','LHT','LNH','LNK','LSP','LVC','MAD','NCY','NJD','NJF',
				  'NNL','NTT','NVN','NWN','PHY','PQC','PUN','RTC','SCH','SGW','SSM','SUR','TDT','TNB','TTW',
				  'UNL','VOY','WCA','WCU','WIZ','WLT','WSN','WTC','XCT') then 'LEVEL 3'
			when clec_id in ('BEY','CAL','CGP','AEH','ATS','AWX','ENY','FDC','INA','JJJ','HOG','CRV',
                  'CWK','DGL','DTI','PAC','PHX','LCZ','LDW','LGT','LTL','TED','USW','UWB',
				  'UWC','UWI','VNS','TLX','QST','QWE','SEP','SML','SPA','MIV') then 'CENTURYLINK/QWEST'
			when clec_id in ('ABW','APT','ICJ','OPT','PSO','WCG','TZV','PWR','SJV') then 'TMOBILE'
			when clec_id in ('ISA','GSP','GTS','LCF','LDU','LSU','NEV','STX','SUA','USP','UTC','UTL',
                  'TNU','ULG','SNK','SPC') then 'SPRINT'
			when clec_id in ('AEY','IGW','GLF','GUS','CXE','CXJ','DCC','DCX','EIP','ONM','LPL','MJC',
                  'NLZ','NXT','SWQ','SZC','WEL','WOW','WSO','UBQ','ROW','SPV') then 'SPRINT PCS'
			when clec_id in ('CBU','CHL','AVS','ICU','IFC','GCW','GSM','GTC','CMA','PLI','XMC','TIM',
                  'TIW','TQL','TWD','TWF','TWK','PTH') then 'TW TELECOM'
			when clec_id in ('AFY','FBL','IUT','CWV','NXO','USH','TQW') then 'XO COMMUNICATIONS'
			when clec_id in ('IOR','UHC','PUA') then 'PAETEC COMMUNICATIONS'
            when clec_id in ('DOB') then 'LOGIX COMMUNICATIONS'
            when clec_id in ('OVC') then 'COVAD COMMUNICATIONS'
            when clec_id in ('OWS') then 'INTELIQUENT'
            when clec_id in ('OXL') then 'SUDDENLINK COMMUNICATIONS'
            when clec_id in ('WAN') then 'WIRELESS ALLIANCE'
            when clec_id in ('WCN') then 'CTCUBE LP'
			when clec_id in ('BFC','BFP','BML','BTL','CBA','CDD','CFO','ADG','ADO','AKJ','AKV','ALS',
				  'ALU','ANI','ANW','APC','API','ATE','ELE','EMI','EXF','FAA','FED','FIB',
				  'ICF','ICI','ICT','IDB','IPC','ISC','ITD','ITT','ITW','JRL','FNE','CML',
				  'CNO','COE','COK','CPQ','CUI','CYG','CYT','CYY','DGX','DNI','EGI','OTN',
				  'LCI','LDD','LDL','LDS','LET','LNT','LSI','LSY','MAI','MAL','MAP','MAS',
				  'MAW','MCG','MCI','MCJ','MCK','MCX','MCY','MEC','MFD','MFS','MFZ','MIC',
				  'MLG','MLL','MPL','MPU','MRA','MSG','MST','MTD','MTF','MTY','MUR','NAS',
				  'NCQ','NFL','NLT','NTK','NTV','NWI','NWS','NYD','SYT','TAG','TCC','TDD',
				  'TEM','TEN','TET','UST','UUN','UVR','VGM','VIN','VUS','WDC','WDM','WTL',
				  'WUA','WUI','TFB','TFY','TGR','TIQ','TMN','TNC','TNO','TNW','TOA','TOM',
				  'TOR','TRI','TRT','TSF','TSG','TTM','TUH','TVT','TXO','TYR','UEL','UNF',
				  'RCG','SAN','SBS','SBX','SLS','SNC','SNS','SNT','SNW','BNK','GIT','GOP') then 'VERIZON BUSINESS'
			when clec_id in ('BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','AAK','AHG','AKR','AOK','AUL',
                  'BAM','BBK','FCO','FCS','IAP','ICN','IDE','IPD','JCC','KOC','FMN','FNT',
				  'GAF','GEX','GMB','GMT','GNL','GTB','GTE','GVU','CLW','CMO','CNL','CNN',
				  'COQ','CRB','CRR','CRY','CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG',
				  'DYT','EBA','ECT','OHC','OMC','PCF','PLP','PPM','LCN','LSC','LTT','MBN',
				  'MCB','MJP','MMH','MMO','NBT','NOH','NVC','NYM','NYR','SRY','SZP','TDQ',
				  'TDU','UTI','UTS','VRZ','ULN','UNV','PTE','PTG','PTI','PTM','PUL','RMB',
				  'RMD','SOT') then 'VERIZON WIRELESS'
			when clec_id in ('BSG','CHJ','ACZ','EXE','HOC','CPO','LTP','NVA','UXW') then 'ONE COMMUNICATIONS'
			WHEN CLEC_ID IN ('AYD','DVN','ELG','OGT','ORO','PCL') THEN 'INTEGRA'
			WHEN CLEC_ID IN ('UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','USC','WCT') THEN 'US CELLULAR'
			else null end CUSTOMER,
       state, svc_cd, nc, SECLOC, SECLOC_ADDRESS, SECLOC_CITY, SECLOC_STATE, location_id, location_id2
from (
select ckt, icsc,  
       case when substr(ckt,4,2) in ('HC','HX','T1') then 'DS1' 
			when substr(ckt,6,2) = 'T1' then 'DS1'
			when substr(svc_cd,1,2) in ('HC','HX','T1') then 'DS1'
			else rate end prod,
	   case when acna = 'BNK' then ccna
	        when acna is not null then acna
	        else ccna end clec_id,
	   case when SECLOC_state is not null then SECLOC_state
            when zstate is not null then zstate
	        else astate end state,	
	   acna, ccna, svc_cd, nc,  SECLOC, SECLOC_ADDRESS,
       SECLOC_CITY, SECLOC_STATE, location_id, location_id2
from (
select exchange_carrier_circuit_id ckt,
       max(ec_company_code) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(rate_code) keep (dense_rank last order by c.last_modified_date) rate,
	   max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna,
       MAX(D.SECONDARY_LOCATION) keep (dense_rank last order by d.last_modified_date) SECLOC,
       MAX(D.SECLOC_END_USER_STREET_ADDRESS) keep (dense_rank last order by d.last_modified_date) SECLOC_ADDRESS,
       MAX(D.SECLOC_CITY) keep (dense_rank last order by d.last_modified_date) SECLOC_CITY,
       MAX(D.SECLOC_STATE) keep (dense_rank last order by d.last_modified_date) SECLOC_STATE,  
	   MAX(SUBSTR(NL1.CLLI_CODE,5,2)) keep (dense_rank last order by nl1.last_modified_date) astate,
       MAX(SUBSTR(NL2.CLLI_CODE,5,2)) keep (dense_rank last order by nl2.last_modified_date) zstate,
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
       max(c.location_id) keep (dense_rank last order by c.last_modified_date) location_id,
       max(c.location_id_2) keep (dense_rank last order by c.last_modified_date) location_id2,
	   max(d.network_channel_code) keep (dense_rank last order by d.last_modified_date) nc,
	   max(d.issue_date) keep (dense_rank last order by d.last_modified_date) issue_date
from circuit c, 
     design_layout_report d, 
	 network_location nl1,
	 network_location nl2
where c.exchange_carrier_circuit_id = d.ecckt
and c.LOCATION_ID = NL1.LOCATION_ID(+)
and c.location_id_2 = nl2.location_id(+)
and c.type <> 'T'
and d.ccna is not null
group by exchange_carrier_circuit_id
)
where substr(ckt,7,1) <> 'U'
and status = '6'
)
where state = 'TX'	
and prod = 'DS1'					   							
;

create table TXDS1b nologging nocache as
select ckt, icsc, prod, clec_id, customer, state, svc_cd, nc, SECLOC, SECLOC_ADDRESS, SECLOC_CITY, SECLOC_STATE, 
       max(addr1.addr_ln1) keep (dense_rank last order by addr1.last_modified_date) addrln1a,
       max(addr1.addr_ln3) keep (dense_rank last order by addr1.last_modified_date) addrln3a,
       max(addr2.addr_ln1) keep (dense_rank last order by addr2.last_modified_date) addrln1b,
       max(addr2.addr_ln3) keep (dense_rank last order by addr2.last_modified_date) addrln3b,
       max(ga1c.instance_value) keep (dense_rank last order by ga1c.last_modified_date) city1,
       max(ga1s.instance_value_abbrev) keep (dense_rank last order by ga1s.last_modified_date) state1,
       max(ga2c.instance_value) keep (dense_rank last order by ga2c.last_modified_date) city2,
       max(ga2s.instance_value_abbrev) keep (dense_rank last order by ga2s.last_modified_date) state2
  from txds1 a,
       net_loc_addr nla2, 
       net_loc_addr nla3,
       address addr1,
       address addr2,
       ga_instance ga1c,
       ga_instance ga1s,
       ga_instance ga2c,
       ga_instance ga2s
  where  a.location_id = nla2.location_id (+)
     and a.location_id2 = nla3.location_id (+)
     and nla2.address_id = addr1.address_id (+)
     and nla3.address_id = addr2.address_id (+)
     and addr1.ga_instance_id_city = ga1c.ga_instance_id (+)  --instance_value
     and addr1.ga_instance_id_state_cd = ga1s.ga_instance_id (+)   --instance_value_abbrev   
     and addr2.ga_instance_id_city = ga2c.ga_instance_id (+)  --instance_value
     and addr2.ga_instance_id_state_cd = ga2s.ga_instance_id (+)   --instance_value_abbrev 
  group by ckt, icsc, prod, clec_id, customer, state, svc_cd, nc, SECLOC, SECLOC_ADDRESS, SECLOC_CITY, SECLOC_STATE
  order by 1;
  
  
  select ckt, prod product, clec_id, customer, replace(addrln1a, 'MSAG ') addrln1a, city1, state1, replace(addrln1b, 'MSAG ') addrln1b, city2, state2, 
         SECLOC, secloc_address, SECLOC_CITY, SECLOC_STATE, svc_cd, nc
  from txds1b
  order by 1     
  ;
 