
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
				  'RCG','SAN','SBS','SBX','SLS','SNC','SNS','SNT','SNW') then 'VERIZON BUSINESS'
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
       state, svc_cd, nc, 
	   case when substr(icsc,1,2) = 'FV' then 'ACQ'
	        when icsc is not null then 'LEG'
	   		when icsc is null and state in ('AZ','CA','ID','IL','IN','MI','NV','NC','OH','OR','SC','WA','WI','WV','KY','MO','MD') then 'ACQ'
			when state in ('DE','GA','IA','MN','ND','NE','NJ','PA','VA') then 'LEG'
			else '??' end area, 
			ordnum, lastmod, trunc(issue_date) issue_date
from (
select ckt, icsc,  
       case when substr(ckt,4,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN') then 'DS0'
	        when substr(ckt,4,2) in ('HC','HX','YB','YG','T1') then 'DS1' 
	        when substr(ckt,4,2) in ('HF','LX','YI','T3') then 'DS3'
			when substr(ckt,4,2) in ('OB','OD','OF','OG','OC') then 'OCN'
			when substr(ckt,4,2) in ('KD','KE','KF','KG','KQ','KR','VL') then 'Ethernet'
			when substr(ckt,6,2) = 'T1' then 'DS1'
			when substr(ckt,6,2) = 'T3' then 'DS3'
			when substr(svc_cd,1,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN') then 'DS0'
			when substr(svc_cd,1,2) in ('HC','HX','YB','YG','T1') then 'DS1'
			when substr(svc_cd,1,2) in ('HF','LX','YI','T3') then 'DS3'
			when substr(svc_cd,1,1) in ('K','V') then 'Ethernet'
			when substr(svc_cd,1,1) = 'O' then 'OCN'
			else rate end prod,
	   case when acna = 'BNK' then ccna
	        when acna is not null then acna
	        else ccna end clec_id,
	   case when zstate is not null then zstate
	        else astate end state,	
	   acna, ccna, svc_cd, nc, issue_date, ordnum, lastmod
from (
select exchange_carrier_circuit_id ckt,
       max(ec_company_code) keep (dense_rank last order by d.last_modified_date) icsc, 
       max(rate_code) keep (dense_rank last order by c.last_modified_date) rate,
	   max(d.acna) keep (dense_rank last order by d.last_modified_date) acna, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna,  
	   MAX(SUBSTR(NL1.CLLI_CODE,5,2)) keep (dense_rank last order by nl1.last_modified_date) astate,
       MAX(SUBSTR(NL2.CLLI_CODE,5,2)) keep (dense_rank last order by nl2.last_modified_date) zstate,
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
	   max(substr(d.order_nbr,1,3)) keep (dense_rank last order by d.last_modified_date) ordnum,
	   max(d.last_modified_userid)  keep (dense_rank last order by d.last_modified_date) lastmod,
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
and substr(c.exchange_carrier_circuit_id,6,2) = 'FS'
group by exchange_carrier_circuit_id
)
where status = '6'
and (zstate = 'IL' or astate = 'IL')
and substr(svc_cd,1,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN',
                		   'HC','HX','YB','YG','T1',
			   			   'HF','LX','YI','T3',
			   			   'OB','OD','OF','OG','OC')
)						   
where clec_id not in ('FLR','CUS','ZZZ','ERR','CQV','BNK','.','254','256','304','306','310','319','600','999',
                    '1ZZ','3','C05','C2','C50','GOV')
							



