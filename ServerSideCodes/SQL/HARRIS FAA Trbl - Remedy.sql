select distinct ticket_id, state, ckt_id, acna,  
       create_date, 
	   case when Cleared_Dt is not null then Cleared_dt
            else Closed_dt end Cleared_Dt, 
	   case when Closed_Dt is not null then Closed_dt
            else Cleared_dt end Closed_Dt,
prod, request_type, repair_code, ttr, mttr_group, cust, trbl_desc
from (
select ticket_id,
       case when site_id is not null and site_id <> 'NON INVENTORIED CIRCUIT' then substr(site_id,5,2) else priloc end state,
	   ckt_id, request_type, 
	   case when acna is not null then acna
	        when acna1 is not null then acna1
			when ccna1 is not null then ccna1
			when acna2 is not null then acna2
			else ccna2 end acna,
	   create_date, cleared_dt, closed_dt, 	 
       case when service_type_code = 'HC' then 'DS1'
			when service_type_code = 'HF' then 'DS3'
			when substr(circuit,4,4) like '%T1%' then 'DS1'
			when substr(circuit,4,4) like '%T3%' then 'DS3'
			when substr(circuit,1,4) like '%HC%' then 'DS1'
			when substr(circuit,1,4) like '%HF%' then 'DS3'
			when substr(circuit,1,2) = 'R2' then 'Ethernet'
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'
			when substr(circuit,3,1) in ('X','L') then 'DS0'
			when substr(service_type_code,1,2) = 'OC' then 'OCN'
			when substr(circuit,1,6) like '%OC%' then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,2) in ('DR','FD','PE','PL','RT','TC','UC') then 'DS0'
			when substr(circuit,3,2) in ('DH','FL','IP','QG','YB','YG') then 'DS1'
			when rate_code is not null then rate_code
			else ' ' end prod,
       repair_code, ttr,
	   case when TTR <= 3 then '0 to 3'
	        when TTR between 3.01 and 4 then '3 to 4'
		    when TTR between 4.01 and 5 then '4 to 5'
		    when TTR between 5.01 and 7 then '5 to 7'
		    when TTR between 7.01 and 9 then '7 to 9'
		    else '9+' end mttr_group,
       cust, 
	   replace(replace(trbl_desc,chr(10),''),chr(13),'') trbl_desc	
 from (	   	
select a.fld_requestid ticket_id, 
       max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
	   max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc,
	   a.exchange_carrier_circuit_id ckt_id,
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit, 
	   max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,
	   max(d.acna) keep (dense_rank first order by d.acna) acna2, 
	   max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
	   max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,  
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
	   max(a.fld_troublereportstate) keep (dense_rank last order by a.fld_modifieddate) trblstat,
	   max(a.fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) causecode,
	   max(a.fld_complete_faultlocation) keep (dense_rank last order by a.fld_modifieddate) faultloc,
	   max(a.fld_descriptionofsympton) keep (dense_rank last order by a.fld_modifieddate) trbl_desc,
	   max(a.fld_alocationaccessname2) keep (dense_rank last order by a.fld_modifieddate) cust
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 --and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (e.type <> 'T' or type is null) 
 and e.status (+) = '6'
 and (to_char(dte_closeddatetime,'yyyymm') = '202312'    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') = '202312'))   --NEED TO CHANGE THIS EACH MONTH
 and (FLD_ALOCATIONACCESSNAME2 like '%FAA%'
or FLD_ALOCATIONACCESSNAME2 like '%Faa%'
or FLD_ALOCATIONACCESSNAME2 like '%faa%'
or FLD_ALOCATIONACCESSNAME2 like '%Harris%'
or FLD_ALOCATIONACCESSNAME2 like '%HARRIS%'
or FLD_ALOCATIONACCESSNAME2 like '%harris%')
and FLD_ALOCATIONACCESSNAME2 not like '%arrison%'
and FLD_ALOCATIONACCESSNAME2 not like '%ARRISON%'
and FLD_ALOCATIONACCESSNAME2 not like '%arrisville%'
and FLD_ALOCATIONACCESSNAME2 not like '%HARRISVILLE%'
and FLD_ALOCATIONACCESSNAME2 not like '%FINANCIAL%'
and FLD_ALOCATIONACCESSNAME2 not like '%HARRISBURG%'
and FLD_ALOCATIONACCESSNAME2 not like '%Harrisburg%'
and FLD_ALOCATIONACCESSNAME2 not like '%HOSP%'
and FLD_ALOCATIONACCESSNAME2 not like '%BANK%'
and FLD_ALOCATIONACCESSNAME2 not like '%Teeter%'
and FLD_ALOCATIONACCESSNAME2 not like '%Steel%'
and FLD_ALOCATIONACCESSNAME2 not like '%STEEL%'
and FLD_ALOCATIONACCESSNAME2 not like '%steel%'
and FLD_ALOCATIONACCESSNAME2 not like '%Bank%'
and FLD_ALOCATIONACCESSNAME2 not like '%COUNTY%'
and FLD_ALOCATIONACCESSNAME2 not like '%MEDICAL%'
and FLD_ALOCATIONACCESSNAME2 not like '%Technol%'
and FLD_ALOCATIONACCESSNAME2 not like '%SEEDS%'
group by a.fld_requestid, a.exchange_carrier_circuit_id
)
where reqstat = 'Closed' 
--
UNION ALL
--
--LIST OF PREVIOUS CIRCUIT IDS FOR HARRIS TO FIND ANY MORE TROUBLES  
select ticket_id,
       case when site_id is not null and site_id <> 'NON INVENTORIED CIRCUIT' then substr(site_id,5,2) else priloc end state,
	   ckt_id, request_type, 
	   case when acna is not null then acna
	        when acna1 is not null then acna1
			when ccna1 is not null then ccna1
			when acna2 is not null then acna2
			else ccna2 end acna,
	   create_date, cleared_dt, closed_dt, 	 
       case when service_type_code = 'HC' then 'DS1'
			when service_type_code = 'HF' then 'DS3'
			when substr(circuit,4,4) like '%T1%' then 'DS1'
			when substr(circuit,4,4) like '%T3%' then 'DS3'
			when substr(circuit,1,4) like '%HC%' then 'DS1'
			when substr(circuit,1,4) like '%HF%' then 'DS3'
			when substr(circuit,1,2) = 'R2' then 'Ethernet'
			when substr(service_type_code,1,1) in ('X','L') then 'DS0'
			when substr(circuit,3,1) in ('X','L') then 'DS0'
			when substr(service_type_code,1,2) = 'OC' then 'OCN'
			when substr(circuit,1,6) like '%OC%' then 'OCN'
			when substr(service_type_code,1,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,1) in ('K','V') then 'Ethernet'
			when substr(circuit,3,2) in ('DR','FD','PE','PL','RT','TC','UC') then 'DS0'
			when substr(circuit,3,2) in ('DH','FL','IP','QG','YB','YG') then 'DS1'
			when rate_code is not null then rate_code
			else ' ' end prod,
       repair_code, ttr,
	   case when TTR <= 3 then '0 to 3'
	        when TTR between 3.01 and 4 then '3 to 4'
		    when TTR between 4.01 and 5 then '4 to 5'
		    when TTR between 5.01 and 7 then '5 to 7'
		    when TTR between 7.01 and 9 then '7 to 9'
		    else '9+' end mttr_group,
       cust, 
	   replace(replace(trbl_desc,chr(10),''),chr(13),'') trbl_desc	
 from (  	
select a.fld_requestid ticket_id, 
       max(a.fld_siteid) keep (dense_rank last order by a.fld_modifieddate) site_id,
	   max(substr(d.primary_location,5,2)) keep (dense_rank last order by d.last_modified_date) priloc,
	   a.exchange_carrier_circuit_id ckt_id,
	   replace(replace(a.exchange_carrier_circuit_id,' '),'/') circuit, 
	   max(a.acna) keep (dense_rank last order by a.fld_modifieddate) acna,
       max(d.acna) keep (dense_rank last order by d.last_modified_date) acna1, 
	   max(d.ccna) keep (dense_rank last order by d.last_modified_date) ccna1,
	   max(d.acna) keep (dense_rank first order by d.acna) acna2, 
	   max(d.ccna) keep (dense_rank first order by d.ccna) ccna2,
	   max(a.fld_requesttype) keep (dense_rank last order by a.fld_modifieddate) request_type, 
	   max(a.fld_startdate) keep (dense_rank last order by a.fld_modifieddate) CREATE_DATE,
	   max(a.fld_event_end_time) keep (dense_rank last order by a.fld_modifieddate) CLEARED_DT, 
       max(a.dte_closeddatetime) keep (dense_rank last order by a.fld_modifieddate) CLOSED_DT,
	   max(round(a.fld_mttrepair/3600,2)) keep (dense_rank last order by a.fld_modifieddate) ttr,
	   max(fld_complete_repaircode) keep (dense_rank last order by a.fld_modifieddate) repair_code,
	   max(fld_troublefoundint) keep (dense_rank last order by a.fld_modifieddate) trbl_found_cd,
	   max(e.service_type_code) keep (dense_rank last order by e.last_modified_date) service_type_code, 
	   max(e.rate_code) keep (dense_rank last order by e.last_modified_date) rate_code,  
	   max(a.fld_requeststatus) keep (dense_rank last order by a.fld_modifieddate) reqstat,
	   max(a.fld_troublereportstate) keep (dense_rank last order by a.fld_modifieddate) trblstat,
	   max(a.fld_complete_causecode) keep (dense_rank last order by a.fld_modifieddate) causecode,
	   max(a.fld_complete_faultlocation) keep (dense_rank last order by a.fld_modifieddate) faultloc,
	   max(a.fld_descriptionofsympton) keep (dense_rank last order by a.fld_modifieddate) trbl_desc,
	   max(a.fld_alocationaccessname2) keep (dense_rank last order by a.fld_modifieddate) cust
from casdw.trouble_ticket_r a,  
     casdw.design_layout_report d,
     casdw.circuit e
where a.fld_troublereportstate = 'closed'
 --and a.fld_assignmentprofile in ('CNOC','Commercial-CTF')
 and a.exchange_carrier_circuit_id = d.ecckt(+)
 and a.exchange_carrier_circuit_id = e.EXCHANGE_CARRIER_CIRCUIT_ID(+)
 and (e.type <> 'T' or type is null) 
 and e.status (+) = '6'
 and (to_char(dte_closeddatetime,'yyyymm') = '202312'    --NEED TO CHANGE THIS EACH MONTH
    or (dte_closeddatetime is null and to_char(fld_event_end_time,'yyyymm') = '202312'))   --NEED TO CHANGE THIS EACH MONTH
 and (substr(a.exchange_carrier_circuit_id,1,14) in (
'A2/HCGE/468338',
'11/LGGL/540893',
'11/UCNA/339804',
'14/LGGS/969250',
'14/LGXX/000056',
'14/LGXX/000096',
'14/LGXX/000107',
'14/LGXX/000267',
'14/LGXX/000283',
'18/HCGS/076713',
'13/HCGE/649218',
'13/HCGE/866470',
'13/LGGE/575073',
'13/LGGE/575075',
'13/LGGE/575115',
'13/LGGE/575165',
'13/LGGS/575067',
'13/LGGS/575217',
'13/LGGS/575241',
'13/XHGS/578806',
'18/LGGE/515556',
'45/HCGS/571304',
'81/HCGS/793908',
'81/HCGS/923925',
'81/HCGS/965617',
'81/LGGS/720256',
'81/LGGS/720259',
'81/LGGS/720270',
'81/LGGS/720271',
'  /HCGS/726384',
'  /HCGS/784837',
'69/LGGS/301583',
'69/LGGS/301584',
'69/LGGS/301597',
'40/LGGE/604308',
'32/HCXX/100591',
'32/LGXX/95106 ',
'  /HCGE/957729',
'  /HCGE/967319',
'  /HCGE/972247',
'  /HCGS/942170',
'  /HCGS/990464',
'  /LGGE/111753',
'  /LGGE/111757',
'  /LGGE/111852',
'  /LGGE/111853',
'  /LGGE/111854',
'  /LGGS/111744',
'1Q/LGGS/159790',
'30/HCGS/026047',
'30/HCGS/200684',
'30/HCGS/220393',
'30/LGGS/300090',
'30/LGGS/300091',
'30/LGGS/300127',
'30/LGGS/300128',
'30/LGGS/300135',
'  /HCGE/684191',
'  /HCGE/684204',
'  /LGGE/427329',
'  /LGGE/427330',
'  /LGGE/427331',
'  /LGGE/427340',
'  /LGGE/427424',
'  /LGGE/427611',
'10/HCGS/464203',
'1R/IPXZ/069556',
'31/HCGS/128971',
'31/HCGS/536532',
'31/HCGS/548821',
'31/HCGS/560980',
'31/HCGS/569738',
'K1/HCGE/400367',
'K1/HCGE/407629',
'  /HCGE/425818',
'  /HCGE/432927',
'  /HCGE/435974',
'  /LGGE/230454',
'  /LGGE/230462',
'  /LGGE/230475',
'  /LGGE/230476',
'  /LGGE/230477',
'  /LGGE/230480',
'  /LGGE/230585',
'  /LGGE/230629',
'  /LGGE/230637',
'  /LGGE/230638',
'  /LGGE/230714',
'  /XHGE/242387',
'  /XHGE/242681',
'  /XHGE/242816',
'33/HCGE/578879',
'33/LGGS/200166',
'11/HCXX/96652 ',
'11/LGXX/94750 ',
'11/LGXX/94779 ',
'13/LGXX/94700 ',
'13/LGXX/94701 ',
'13/LGXX/94710 ',
'14/LGXX/94632 ',
'15/LGXX/099754',
'15/LGXX/99794 ',
'23/HCGS/525600',
'23/HCGS/526725',
'23/HCGS/559433',
'22/LGGE/312814',
'42/LGXX/94788 ',
'54/LGXX/000191',
'54/LGXX/000192',
'17/HCGS/520652',
'17/LGGS/505127',
'65/HCGS/342206',
'33/HCGL/247959',
'36/HCGS/187946',
'36/HCGS/534129',
'36/HCGS/534131',
'36/LGGS/449158',
'87/DHXX/043522',
'87/DHXX/044851',
'T-29723',
'T-323324',
'T-42082',
'T-42701',
'T-43522',
'T-44851',
'T-45335',
'94/LGGE/208074',
'95/LGGE/203431',
'96/LGGE/203214',
'96/LGGE/203218',
'98/HCGE/215933',
'98/HCGE/217718',
'98/HCGE/221814',
'98/LDGE/200468',
'98/LDGE/200469',
'61/HCGS/509406',
'61/HCGS/511135',
'61/HCGS/514837',
'61/HCGS/764736',
'61/LEGS/170036',
'34/HCGE/417616',
'34/LGGE/405534',
'36/LGGE/404213',
'62/HCGS/159132',
'62/HCGS/163453',
'62/HCGS/168544',
'62/HCGS/563161',
'62/HCGS/566128',
'62/HCGS/576586',
'T4/HCGE/745012',
'T4/HCGE/823073',
'T4/HCGE/835442',
'13/HCGS/623554',
'14/HCGE/151819',
'14/HCGE/915472',
'14/HCGS/128182',
'14/HCGS/128187',
'14/HCGS/128195',
'14/LGGE/622616',
'14/LGGE/622633',
'14/LGGE/622690',
'14/LGGE/622909',
'14/XHGE/160407',
'14/XHGE/160408',
'14/XHGE/160409',
'18/HCGE/620955',
'28/HCGE/888767',
'28/LGGE/617895',
'31/LGGE/606325',
'32/LGGE/604972',
'34/HCGE/615494',
'34/HCGS/629369',
'34/LGGE/602507',
'34/LGGE/602508',
'34/LGGE/602509',
'34/LGGE/602514',
'34/LGGE/602515',
'34/LGGE/602516',
'01/HCGS/559815',
'64/LGXX/000072',
'64/LGXX/000090',
'64/LGXX/000106',
'64/LGXX/000107',
'64/LGXX/000140',
'1B/IPMX/090829',
'39/HCGS/564399',
'41/LGGE/111701',
'41/LGGE/111703',
'41/LGGE/111730',
'41/LGGE/111737',
'41/LGGS/606663',
'40/HCGS/776333',
'40/LGGL/100002',
'42/LGGL/100001',
'50/HCGS/037921',
'50/HCGS/041612',
'50/HCGS/047005',
'50/HCGS/062075',
'50/HCGS/078606',
'50/HCGS/634095',
'50/HCGS/634191',
'50/LGGL/515171',
'50/LGGS/524198',
'54/LGGA/100087',
'54/LGGL/100004',
'54/LGGL/100005',
'54/LGGL/100015',
'54/LGGL/100022',
'54/LGGL/100023',
'54/LGGL/100045',
'56/HCGA/100132',
'56/LGGA/100032',
'56/LGGA/100033',
'56/LGGA/100034',
'90/HCGE/246742',
'T4/LGGE/919171',
'T4/LGGE/919189',
--below are NWF 
'34/LGXX/000138',
'34/LGXX/000139',
'43/XHGS/506917',
'70/LGXX/00550 ',
'70/LGXX/00551 ',
'70/LGXX/00786 ',
'70/LGXX/91831 ',
'72/LGXX/00606 ',
'72/LGXX/01179 ',
'72/LGXX/01259 ',
'74/LGXX/000523',
'74/LGXX/001200',
'74/LGXX/00514 ',
'74/LGXX/00519 ',
'74/LGXX/00692 ',
'74/LGXX/01063 ',
'74/LGXX/01148 ',
'74/LGXX/01201 ',
'74/LGXX/01263 ',
'76/LGXX/01136 ',
'76/LGXX/012673',
'83/LGGS/400016',
'83/LGGS/400018',
'83/LGGS/400031',
'83/LGGS/400032',
'83/LGGS/922661',
'85/LGGS/500024',
'85/LGGS/500025',
'86/HCGS/564167'   
)
or a.exchange_carrier_circuit_id in (
'101  /T1ZF  /CRALIDXXKZZ/PLMNWA07H00',
'101  /T1ZF  /OKHRWAAPHAA/STTLWA06K91',
'213  /T1ZF  /BLTNILUTW01/BLTNILXDK01',
'101  /T1ZF  /CRALIDXXKZZ/PLMNWA07H00',
'102  /T1ZF  /NWBROREZHAA/PTLDOR69K22',
'103  /T1    /BLVLILAD   /MSCTILXEK02',
'109  /T1ZF  /CRALIDXXKZZ/PSFLIDAAWT1',
'213  /T1ZF  /BLTNILUTW01/BLTNILXDK01',
'3000 /T3Z   /TAMQFLASO01/WSSDFLXAK03',
'8002/T1ZF/BLTNILXDK01/BLTNILXDW26',
'101  /T1ZF  /BLCYAZEMHAA/PHNXAZMAK03',
'101  /T1ZF  /DYTNORBGHAA/PTLDOR69K22',
'101  /T1ZF  /GDISNENWK01/PLTNNEABHAA',
'105  /T3    /CLMBOH11FM1/MARNOHXCK02',
'9502 /T1ZF/MGTWWVFYK01/RDVLWVXA',
'140  /T1ZF  /BLTNILXDK01/BLTNILXTF01'
))
group by a.fld_requestid, a.exchange_carrier_circuit_id
)
where reqstat = 'Closed'
)
order by 7;





