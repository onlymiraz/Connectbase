drop table director_clli_4
/

create table director_clli_3
(
CLLI             VARCHAR2(255 BYTE),
AREA             VARCHAR2(255 BYTE),
STATE            VARCHAR2(255 BYTE),
TERRITORY        VARCHAR2(255 BYTE),
SVP              VARCHAR2(255 BYTE),
DIRECTOR         VARCHAR2(255 BYTE)
);

select * from director_clli_4;

commit;



INSERT ALL
into director_clli_3 values ('ALBMNC','South','NC','North Carolina','Melanie Williams','Bill Wright','Bill Wright')
into director_clli_3 values ('AUBNCA','West','CA','California','Joe Gamble','NorCal','Thomas Novotney')
into director_clli_3 values ('BGVYTX','South','TX','Texas','Pedro Correa','Cort Petterson','Cort Petterson')
into director_clli_3 values ('BVHLCA','West','CA','California','Joe Gamble','Beach Cities','Leticia Solis')
select * from dual;


update director_clli_4
set svp = 'Julie Murtagh'
where area = 'East';



create table director_clli_4 as select * from director_clli_3
/

;

update director_clli_4
set area = 'Midwest'
where state in ('TX');


select distinct area, state, svp
from director_clli_4
order by 1,2;