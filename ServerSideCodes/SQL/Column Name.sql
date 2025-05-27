
Select table_name, column_name, data_type 
from all_tab_columns 
where table_name in('ACCESS_SERVICE_REQUEST','SERV_REQ','ASR_USER_DATA',
'CIRCUIT','DESIGN_LAYOUT_REPORT','TASK','NETWORK_LOCATION')
order by 1,2; 




Select *
from all_tab_columns 
where column_name like 'HBE%'
order by 1,2;


--For Teradata  
sel * from Dbc.columns where columnname like 'serv%TYP%'
and databasename like 'edw_vwmc%'
ORDER BY 2;


--For ODBC CABS  

select * from qsys2.syscolumns

-- For ENDDR

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS

SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA
