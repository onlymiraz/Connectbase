CREATE VIEW WCF.[TROUBLE_TICKETS_V] AS

SELECT
YEAR(completion_dttm) as Yr,
cast(DATEADD(month, DATEDIFF(month, 0, completion_dttm), 0) as date) as RPT_MTH,
b.END_OFFICE_CLLI_CD,TERR_CD as State_Cd, WRK_ORD_STATUS_TYPE_CD,
TRBL_TICKET_TYPE_CD, a.WIRE_CTR_NM,  
case when SERVICE_CLASS_CD in ('FB1', 'FBLH', 'FCDC', 'FCDHS', 'FCDP', 'FCLB', 'FCLCC', 'FCLCH', 'FCLH', 'FCLR',   
'FCSSB', 'FCSST', 'FCSUB', 'FCSUT', 'FCTXH', 'FHSI', 'FHSIB', 'FHSIR', 'FHSUB', 'FHSUR',   
'FIBER', 'FMADN', 'FR1', 'FRLH', 'FUBLH', 'FUBV', 'FURV', 'FV', 'FVB1', 'FVBLH',   
'FVBV', 'FVCCH', 'FVCDC', 'FVCDP', 'FVCLB', 'FVCLC', 'FVCLH', 'FVCLR', 'FVCTH', 'FVID',   
'FVIDB', 'FVIDR', 'FVMDN', 'FVR1', 'FVRLH', 'FVRV', 'FVUDB', 'FVUDR', 'FXB1', 'FXBLH',   
'FXBV', 'FXBVH', 'FXCCH', 'FXCDC', 'FXCLB', 'FXCLC', 'FXCLH', 'FXCLR', 'FXMDN', 'FXR1',   
'FXRLH', 'FXRV', 'FXV', 'FXVB1', 'FXVBH', 'FXVBV', 'FXVCB', 'FXVCC', 'FXVCD', 'FXVCH',   
'FXVCR', 'FXVHC', 'FXVIB', 'FXVID', 'FXVIR', 'FXVMD', 'FXVR1', 'FXVRH', 'FXVRV', 'FXVUB',   
'FXVUR', 'FXVV', 'FXVVB', 'SFHIB', 'SFVHB', 'SFVHV', 'SFXB1', 'SFXBV', 'SI_PREFIELD', 'VURV', 'VVRV', 'VXRV', 'VXVRV') then 'Fiber'
when SERVICE_CLASS_CD in ('ACIS', 'COPMP', 'CPE_NOC', 'FGA-R', 'FGA-X', 'FIRE', 'IA_PREFIELD', 'SES', 'SWRLB', 'SWRLS', 
'SXUBS', 'WBFWB', 'WBFWV', 'WRFWB', 'WRFWV', 'XBFWB', 'XRFWB', 'PARTS__T', '1B', '2WTS', 
'30', 'ABC', 'ABCB1', 'ABCDI', 'ASRCKT', 'CELL', 'CKT', 'CKTLL', 'CKTLS', 'CKTTP', 
'CXR', 'CXR-A', 'CXR-D', 'CXR-T', 'DOD', 'DR', 'EWOCKT', 'INRNT', 'INW', 'ISRCKT', 'LC',
'LD', 'MWTS', 'NETCKT', 'OWT', 'PAGER', 'PDATA', 'PL-AD', 'PL-AL', 'PL-BA', 'PL-D2', 'PL-D4',
'PL-DD', 'PL-DI', 'PL-DO', 'PL-DS', 'PL-FA', 'PL-FR', 'PL-FX', 'PL-HC', 'PL-IB', 'PL-IT', 
'PL-L2', 'PL-L4', 'PL-LE', 'PL-LL', 'PL-LT', 'PL-ML', 'PL-OP', 'PL-R2', 'PL-R4', 'PL-RD', 
'PL-T1', 'PL-T3', 'PL-TL', 'PL-TM', 'PL-TT', 'PL-TX', 'PL-V2', 'PL-V4', 'PMB1', 'PMR1', 
'PSRCKT', 'RCC', 'RMALRM', 'SAS', 'SN', 'SPL', 'SPLLE', 'SPLNO', 'SW-56', 'T-1', 
'T1', 'TC', 'TEST', 'VM', 'WATII', 'WATOI', 'WTHI', 'WTII', 'WTOI', 'XX') then 'Other' else 'Copper' end as NETWORK
,count([WRK_ORD_NO]) as Total_Tickets
FROM EDW_VWMC.[TBL_TROUBLE_TICKETS] a

INNER JOIN EDW_VWMC.TBL_OFFCL_GEOGRAPHY_SC  b
ON a.VIRTUAL_WIRE_CTR_JOIN_KEY = b.GEOGRAPHY_JOIN_KEY              

where YEAR(completion_dttm) >=2022

GROUP BY
b.END_OFFICE_CLLI_CD,TERR_CD, WRK_ORD_STATUS_TYPE_CD,
TRBL_TICKET_TYPE_CD, a.WIRE_CTR_NM, cast(DATEADD(month, DATEDIFF(month, 0, completion_dttm), 0) as date), YEAR(completion_dttm),
case when SERVICE_CLASS_CD in ('FB1', 'FBLH', 'FCDC', 'FCDHS', 'FCDP', 'FCLB', 'FCLCC', 'FCLCH', 'FCLH', 'FCLR',   
'FCSSB', 'FCSST', 'FCSUB', 'FCSUT', 'FCTXH', 'FHSI', 'FHSIB', 'FHSIR', 'FHSUB', 'FHSUR',   
'FIBER', 'FMADN', 'FR1', 'FRLH', 'FUBLH', 'FUBV', 'FURV', 'FV', 'FVB1', 'FVBLH',   
'FVBV', 'FVCCH', 'FVCDC', 'FVCDP', 'FVCLB', 'FVCLC', 'FVCLH', 'FVCLR', 'FVCTH', 'FVID',   
'FVIDB', 'FVIDR', 'FVMDN', 'FVR1', 'FVRLH', 'FVRV', 'FVUDB', 'FVUDR', 'FXB1', 'FXBLH',   
'FXBV', 'FXBVH', 'FXCCH', 'FXCDC', 'FXCLB', 'FXCLC', 'FXCLH', 'FXCLR', 'FXMDN', 'FXR1',   
'FXRLH', 'FXRV', 'FXV', 'FXVB1', 'FXVBH', 'FXVBV', 'FXVCB', 'FXVCC', 'FXVCD', 'FXVCH',   
'FXVCR', 'FXVHC', 'FXVIB', 'FXVID', 'FXVIR', 'FXVMD', 'FXVR1', 'FXVRH', 'FXVRV', 'FXVUB',   
'FXVUR', 'FXVV', 'FXVVB', 'SFHIB', 'SFVHB', 'SFVHV', 'SFXB1', 'SFXBV', 'SI_PREFIELD', 'VURV', 'VVRV', 'VXRV', 'VXVRV') then 'Fiber'
when SERVICE_CLASS_CD in ('ACIS', 'COPMP', 'CPE_NOC', 'FGA-R', 'FGA-X', 'FIRE', 'IA_PREFIELD', 'SES', 'SWRLB', 'SWRLS', 
'SXUBS', 'WBFWB', 'WBFWV', 'WRFWB', 'WRFWV', 'XBFWB', 'XRFWB', 'PARTS__T', '1B', '2WTS', 
'30', 'ABC', 'ABCB1', 'ABCDI', 'ASRCKT', 'CELL', 'CKT', 'CKTLL', 'CKTLS', 'CKTTP', 
'CXR', 'CXR-A', 'CXR-D', 'CXR-T', 'DOD', 'DR', 'EWOCKT', 'INRNT', 'INW', 'ISRCKT', 'LC',
'LD', 'MWTS', 'NETCKT', 'OWT', 'PAGER', 'PDATA', 'PL-AD', 'PL-AL', 'PL-BA', 'PL-D2', 'PL-D4',
'PL-DD', 'PL-DI', 'PL-DO', 'PL-DS', 'PL-FA', 'PL-FR', 'PL-FX', 'PL-HC', 'PL-IB', 'PL-IT', 
'PL-L2', 'PL-L4', 'PL-LE', 'PL-LL', 'PL-LT', 'PL-ML', 'PL-OP', 'PL-R2', 'PL-R4', 'PL-RD', 
'PL-T1', 'PL-T3', 'PL-TL', 'PL-TM', 'PL-TT', 'PL-TX', 'PL-V2', 'PL-V4', 'PMB1', 'PMR1', 
'PSRCKT', 'RCC', 'RMALRM', 'SAS', 'SN', 'SPL', 'SPLLE', 'SPLNO', 'SW-56', 'T-1', 
'T1', 'TC', 'TEST', 'VM', 'WATII', 'WATOI', 'WTHI', 'WTII', 'WTOI', 'XX') then 'Other' else 'Copper' end

