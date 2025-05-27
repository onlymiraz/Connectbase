drop table APRlines;



--create table APRLines nologging nocache as
select ckt, prod, clec_id, customer, state, svc_cd, status, si_status, uni_or_nni
from (
select distinct ckt, prod, clec_id,
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
			when clec_id in ('BEY','CAL','CGP','AEH','ATS','AWX','ENY','FDC','INA','JJJ','HOG','CRV',
                  'CWK','DGL','DTI','PAC','PHX','LCZ','LDW','LGT','LTL','TED','USW','UWB',
				  'UWC','UWI','VNS','TLX','QST','QWE','SEP','SML','SPA','MIV',
                  'AJQ','ALN','AQH','ASC','ASI','AVZ','BUC','BUR','BWG','CNK','COS','CTO','EAK',
			      'EAS','ENW','EPK','ESM','FLS','FOC','GBG','GIE','GSX','GTT','HCU','HCV','HDC','HDE','HFL',
				  'HMA','HMD','HNH','HNI','HNJ','HNY','HOR','HPA','HPI','HRH','HSE','HTJ','HWV','HYH','HYS',
  				  'HYV','ICG','IMR','IPX','IXC','LGG','LHT','LNH','LNK','LSP','LVC','MAD','NCY','NJD','NJF',
				  'NNL','NTT','NVN','NWN','PHY','PQC','PUN','RTC','SCH','SGW','SSM','SUR','TDT','TNB','TTW',
				  'UNL','VOY','WCA','WCU','WIZ','WLT','WSN','WTC','XCT','CBU','CHL','AVS','ICU','IFC','GCW',
                  'GSM','GTC','CMA','PLI','XMC','TIM','TIW','TQL','TWD','TWF','TWK','PTH') then 'LUMEN TECHNOLOGIES'
			when clec_id in ('ABW','APT','ICJ','OPT','PSO','WCG','TZV','PWR','SJV') then 'TMOBILE'
			when clec_id in ('ISA','GSP','GTS','LCF','LDU','LSU','NEV','STX','SUA','USP','UTC','UTL',
                  'TNU','ULG','SNK','SPC') then 'SPRINT'
			when clec_id in ('AEY','IGW','GLF','GUS','CXE','CXJ','DCC','DCX','EIP','ONM','LPL','MJC',
                  'NLZ','NXT','SWQ','SZC','WEL','WOW','WSO','UBQ','ROW','SPV') then 'SPRINT PCS'
			when clec_id in ('AEJ','AVJ','AWH','BMJ','CJG','CND','ENA','EXE','FDN','FDW',
			      'FRG','GBU','KDL','LDM','LTT','MWR','MZJ','NLG','NNN','NSC','OLP','PFT',
				  'TAD','VAU','VLO','WSJ','YOH','YVA','ALG','AMM','ARJ','CAB','CCK','CDN',
				  'CPK','DLM','DOV','FEL','IOR','LCG','LDN','LDO','LDR','LMI','LOG','LWK',
				  'NKH','OCB','OVT','PHG','PUA','SGY','TVC','TVN','UHC','VLR','VPM',
                  'HOC','UXW','CPO','NVA','LTP','DLT','BTI','NGE') THEN 'WINDSTREAM'            --INCLUDES EARTHLINK  
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
				  'RCG','SAN','SBS','SBX','SLS','SNC','SNS','SNT','SNW',
                  'AFY','FBL','IUT','CWV','NXO','USH','TQW') then 'VERIZON BUSINESS'
			when clec_id in ('BLG','CCE','CCQ','CEL','CEX','CGO','CKZ','AAK','AHG','AKR','AOK','AUL',
                  'BAM','BBK','FCO','FCS','IAP','ICN','IDE','IPD','JCC','KOC','FMN','FNT',
				  'GAF','GEX','GMB','GMT','GNL','GTB','GTE','GVU','CLW','CMO','CNL','CNN',
				  'COQ','CRB','CRR','CRY','CUE','CUM','CUP','CXV','CYC','DMR','DTC','DUG',
				  'DYT','EBA','ECT','OHC','OMC','PCF','PLP','PPM','LCN','LSC','LTT','MBN',
				  'MCB','MJP','MMH','MMO','NBT','NOH','NVC','NYM','NYR','SRY','SZP','TDQ',
				  'TDU','UTI','UTS','VRZ','ULN','UNV','PTE','PTG','PTI','PTM','PUL','RMB',
				  'RMD','SOT','BAL') then 'VERIZON WIRELESS'
			WHEN CLEC_ID IN ('AYD','AYX','DVN','ELG','FBN','GIR','GVA','IFB','IFH','IOC','IOV','MAF','MFR','MFW','MFY','MIX','NRI','OEY','OGT','ORO',
                             'PCL','PXM','REN','RKO','SHD','UIC','WOL','WUS','YOB','MEN','MSK','UCN') THEN 'ZAYO BANDWIDTH'
			WHEN CLEC_ID IN ('UCU','CIW','CKE','CLO','CNC','DTW','MKT','NIL','RVY','TNR','UCL','USC','WCT') THEN 'US CELLULAR'
            WHEN CLEC_ID IN ('TFU','NVE','AZC','DSG','SHO','TZJ') then 'TELEPACIFIC COMMUNICATIONS'
            when clec_id in ('AFW','AXJ','CRZ','GRM','LRS','PYQ','TTU','UWT','VAF','VLK') then 'BIRCH TELECOM'
            when clec_id in ('NKV') then 'NITEL'
            when clec_id in ('GIM') then 'GRANITE TELECOMMUNICATIONS'
            when clec_id in ('MTV') then 'METTEL'
            when clec_id in ('DSE','EPO','GBS','GBW','IZC','LKG','MOQ','NAO','OER','OVC','SXY','UVA') then 'GLOBAL TELECOM'
            when clec_id in ('BHS','DUK','HFB','OIO','VNH') then 'CHARTER COMMUNICATIONS'
            WHEN CLEC_ID IN ('BPH','COJ','JCV','JNC','OMD','OMQ') THEN 'COMCAST'
			else null end CUSTOMER,
       state, svc_cd, status, si_status, uni_or_nni
from (
select ckt,   
       case when substr(ckt,1,2) = 'R2' then 'Ethernet'
	   		when substr(ckt,4,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN') then 'DS0'
	        when substr(ckt,4,2) in ('HC','HX','YB','YG','T1') then 'DS1' 
	        when substr(ckt,4,2) in ('HF','LX','YI','T3') then 'DS3'
			when substr(ckt,4,2) in ('OB','OD','OF','OG','OC') then 'OCN'
			when substr(ckt,4,2) in ('KD','KE','KF','KG','KM','KQ','KR','KS','KJ','VL','SX') then 'Ethernet'
			when substr(ckt,6,2) = 'T1' then 'DS1'
			when substr(ckt,6,2) = 'T3' then 'DS3'
			when substr(svc_cd,1,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN') then 'DS0'
			when substr(svc_cd,1,2) in ('HC','HX','YB','YG','T1') then 'DS1'
			when substr(svc_cd,1,2) in ('HF','LX','YI','T3') then 'DS3'
			when substr(svc_cd,1,1) in ('K','V') then 'Ethernet'
			when substr(svc_cd,1,1) = 'O' then 'OCN'
			else rate end prod,
	   case when acna1 = 'BNK' and acna2 = 'BNK' then ccna2
	        when acna1 = 'BNK' and acna2 is not null then acna2
	        when acna1 is not null then acna1
			when acna2 is not null then acna2
	        else ccna1 end clec_id,
	   case when zstate is not null and zstate <> 'EF' then zstate
            when icsc = 'RT01' then 'NY'
            when icsc = 'SN01' then 'CT'
            when state3 is not null then state3
            when substr(ckt,1,2) in ('81','45') and svc_cd = 'VL' then 'CA'
            when substr(ckt,1,2) in ('69','65') and svc_cd = 'VL' then 'FL'
            when substr(ckt,1,2) in ('12','13') and svc_cd = 'VL' then 'TX'
            else astate end state,	
	   acna2, ccna2, svc_cd, status, si_status, uni_or_nni
from (
select ckt, 
       max(icsc) icsc,
       max(rate) rate,
       max(acna1) acna1,
       max(ccna1) ccna1,
       max(acna2) acna2,
       max(ccna2) ccna2,
       max(astate) astate,
       max(zstate) zstate,
       max(state3) state3,
       max(svc_cd) svc_cd,
       max(status) status,
       max(si_status) si_status,
       max(uni_or_nni) uni_or_nni
from ( 
select exchange_carrier_circuit_id ckt,
       max(ec_company_code) keep (dense_rank first order by d.last_modified_date) icsc, 
       max(rate_code) keep (dense_rank last order by c.last_modified_date) rate,
	   max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,  
	   max(d.acna) keep (dense_rank first order by d.acna) acna2, 
	   max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,
	   MAX(SUBSTR(NL1.CLLI_CODE,5,2)) keep (dense_rank last order by nl1.last_modified_date) astate,
       MAX(SUBSTR(NL2.CLLI_CODE,5,2)) keep (dense_rank last order by nl2.last_modified_date) zstate,
       null state3,
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
       si.status si_status,
       cud.uni_or_nni
from circuit c, 
     design_layout_report d, 
	 network_location nl1,
	 network_location nl2,
     serv_item si,
     circuit_user_data cud
where c.exchange_carrier_circuit_id = d.ecckt
and c.LOCATION_ID = NL1.LOCATION_ID(+)
and c.location_id_2 = nl2.location_id(+)
and c.circuit_design_id = si.circuit_design_id
and c.circuit_design_id = cud.circuit_design_id (+)
and c.type <> 'T'
and si.status = '6' and c.status <> '8'
and d.ccna is not null
--and c.EXCHANGE_CARRIER_CIRCUIT_ID = '  /DHEC/975680/   /CZUC/   '
group by exchange_carrier_circuit_id, si.status, cud.uni_or_nni
--
UNION ALL
--
select exchange_carrier_circuit_id ckt,
       max(asr.access_provider_serv_ctr_code) keep (dense_rank first order by asr.last_modified_date) icsc,  
       max(c.rate_code) keep (dense_rank last order by c.last_modified_date) rate,
	   max(sr.acna) keep (dense_rank last order by sr.last_modified_date) acna1, 
	   max(sr.ccna) keep (dense_rank last order by sr.last_modified_date) ccna1,
	   max(sr.acna) keep (dense_rank first order by sr.acna) acna2, 
	   max(sr.ccna) keep (dense_rank first order by sr.ccna) ccna2,  
	   MAX(SUBSTR(NL1.CLLI_CODE,5,2)) keep (dense_rank last order by nl1.last_modified_date) astate,
       MAX(SUBSTR(NL2.CLLI_CODE,5,2)) keep (dense_rank last order by nl2.last_modified_date) zstate,
       max(substr(npa.exchange_area_clli,5,2)) keep (dense_rank last order by npa.last_modified_date) state3,
	   max(c.service_type_code) keep (dense_rank last order by c.last_modified_date) svc_cd,
	   max(c.status) keep (dense_rank last order by c.last_modified_date) status,
       si.status si_status,
       null uni_or_nni
from circuit c, design d, network_location nl1, network_location nl2, ASAP.design_ord_summ dos,
     asap.serv_req sr, asap.access_service_request asr, npa_nxx npa, serv_item si	   
where c.exchange_carrier_circuit_id = d.ckt_ident
and c.LOCATION_ID = NL1.LOCATION_ID(+)	  
and c.LOCATION_ID_2 = NL2.LOCATION_ID(+)
and d.design_ord_sum_id =  dos.design_ord_sum_id
and dos.document_number =  sr.document_number
and dos.document_number = asr.document_number
and c.circuit_design_id = si.circuit_design_id
and asr.npa = npa.npa (+)
and asr.nxx = npa.nxx (+)		   
and c.type <> 'T'
and si.status = '6' and c.status <> '8'
and substr(c.service_type_code,1,2) = 'VL'
--and c.EXCHANGE_CARRIER_CIRCUIT_ID = '  /DHEC/975680/   /CZUC/   '
group by exchange_carrier_circuit_id, si.status
)
group by ckt
)
where substr(ckt,7,1) <> 'U'
and SI_STATUS = '6' AND STATUS <> '8'
and substr(svc_cd,1,2) in ('LC','LD','LE','LF','LG','LH','LJ','LK','LN','LY','XA','XB','XC','XD','XE','XG','XH','YN',
                		   'HC','HX','YB','YG','T1',
			   			   'HF','LX','YI','T3',
			   			   'OB','OD','OF','OG','OC',
						   'KD','KE','KF','KG','KQ','KM','KR','KS','KJ','VL','SX')
)						   
where (clec_id not in ('FLR','CUS','ZZZ','ERR','CQV','BNK','.','254','256','304','306','310','319','600','999',
                       '1ZZ','3','C05','C2','C50','GOV','XYY','SNE')
	   and substr(clec_id,1,1) <> 'Z')
)
order by 1,5
;				  
							



select customer, prod, count(*)
from APRlines
where prod in ('DS0','DS1','DS3','OCN','Ethernet')
--and customer = 'LUMOS'
--and AREA = 'ACQ'
group by customer, prod
order by 1,2;



select ckt, icsc, prod, clec_id, customer, state, svc_cd, nc, area
from aprlines
order by 1;



 	   

--To see if any of the VLXP circuits have been Disconnected    
select sr.document_number, type_of_sr, first_ecckt_id, acna, activity_ind, actual_completioN_date 
from serv_req sr,
     task t
where sr.document_number = t.document_number
and t.task_type = 'DD'
and first_ecckt_id like '%/VLXP%'
and activity_ind = 'D'
and to_char(actual_completion_date,'yyyymm') in ('201502')
and (supplement_type <> 1 or supplement_type is null)   


