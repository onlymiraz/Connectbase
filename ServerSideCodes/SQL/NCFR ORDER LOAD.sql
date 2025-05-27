--load from NCFR weekly load file   

drop table ncfrorders;

create table ncfrorders
(
DOCUMENT_NUMBER VARCHAR2(255 BYTE),
PON             VARCHAR2(255 BYTE),
ACT_IND         VARCHAR2(255 BYTE),
DREC            DATE,
DD              DATE,
DDD             DATE,
COMP_DT         DATE,
DD_TASK_COMP    DATE,
NPANXX          VARCHAR2(255 BYTE),
CLLI            VARCHAR2(255 BYTE),
ICSC            VARCHAR2(255 BYTE),
ACNA            VARCHAR2(255 BYTE),
CUSTOMER        VARCHAR2(255 BYTE),
STATE           VARCHAR2(255 BYTE),
PRODUCT         VARCHAR2(255 BYTE),
CKT             VARCHAR2(255 BYTE)
);

select * from NCFRORDERS;

commit;