--drop table lam_npanxx;

create table lam_npanxx
(
NPANXX           VARCHAR2(255 BYTE),
REGION           VARCHAR2(255 BYTE),
TERRITORY        VARCHAR2(255 BYTE),
LOCAL_MKT        VARCHAR2(255 BYTE),
STATE            VARCHAR2(255 BYTE)
);

select * from lam_npanxx;

commit;

INSERT ALL
into lam_npanxx values ('607651','East','New York','Chenango','NY')
select * from dual;


