CREATE VIEW QBR.[VFO_PONS_V]
AS 
	
with ConfirmedVersions as (
    select 
        PON, 
        VERSION,
        CREATIONDATETIME,
        ROW_NUMBER() over (partition by PON order by CREATIONDATETIME asc) as rn
    from [QBR].[TBL_WHSL_ADV_HIST_VFO_ORDERHISTORYINFO_THIST]
    where ORDERSTATUS in ('Confirmed_Submitted', 'Confirmed_Sent')
),
FirstConfirmed as (
	select 
		PON, 
		VERSION, 
		min(CREATIONDATETIME) as FIRST_CONFIRMED_DATETIME
	from ConfirmedVersions
	where rn = 1
	group by PON, VERSION
)
select 
    ord.PON as PON, 
    min(case when ord.ORDERSTATUS in ('Accepted_Submitted') then CAST(ord.CREATIONDATETIME as date) else NULL end) as INIT_ASR,
    min(case when ord.ORDERSTATUS in ('Accepted_Submitted') AND ord.PON = fc.PON AND ord.VERSION = fc.VERSION then CAST(ord.CREATIONDATETIME as date) else NULL end) as FIRST_CLEAN,
    max(case when ord.ORDERSTATUS in ('Accepted_Submitted') then CAST(ord.CREATIONDATETIME as date) else NULL end) as CLEAN_ASR,
    min(case when ord.ORDERSTATUS in ('Confirmed_Submitted','Confirmed_Sent') then CAST(ord.CREATIONDATETIME as date) else NULL end) as INIT_CONF,
    max(case when ord.ORDERSTATUS in ('Confirmed_Submitted','Confirmed_Sent') then CAST(ord.CREATIONDATETIME as date) else NULL end) as CLEAN_CONF,
    min(case when ord.ORDERSTATUS in ('DLR_Submitted','DLR_Sent') then CAST(ord.CREATIONDATETIME as date) else NULL end) as INIT_DLR,
    max(case when ord.ORDERSTATUS in ('DLR_Submitted','DLR_Sent') then CAST(ord.CREATIONDATETIME as date) else NULL end) as CLEAN_DLR,
    pons.ACNA,
    mcl.PRIMARY_CARRIER_NM
from [QBR].[TBL_WHSL_ADV_HIST_VFO_ORDERHISTORYINFO_THIST] ord
left join FirstConfirmed fc
	on ord.PON = fc.PON and ord.VERSION = fc.VERSION
left join QBR.TBL_VFO_PONS pons 
    on ord.PON = pons.PON
left join dbo.MCL_V mcl 
    on pons.ACNA = mcl.SECONDARY_ID
where ord.PON in (select distinct pon from qbr.TBL_VFO_PONS)
group by ord.PON, pons.ACNA, mcl.PRIMARY_CARRIER_NM