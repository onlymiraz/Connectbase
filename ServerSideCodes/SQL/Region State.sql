--drop table company;

create table region_state
(
state  		 	 VARCHAR2(255 BYTE),
region           VARCHAR2(255 BYTE)
);

select * from region_state;

commit;

INSERT ALL
into region_state values ('CT','East')
into region_state values ('NY','East')
into region_state values ('PA','East')
into region_state values ('IA','Midwest')
into region_state values ('IL','Midwest')
into region_state values ('IN','Midwest')
into region_state values ('KY','Midwest')
into region_state values ('MI','Midwest')
into region_state values ('MN','Midwest')
into region_state values ('MO','Midwest')
into region_state values ('NE','Midwest')
into region_state values ('OH','Midwest')
into region_state values ('WI','Midwest')
into region_state values ('WV','Midwest')
into region_state values ('VA','Midwest')
into region_state values ('MD','Midwest')
into region_state values ('AL','South')
into region_state values ('FL','South')
into region_state values ('GA','South')
into region_state values ('MS','South')
into region_state values ('NC','South')
into region_state values ('SC','South')
into region_state values ('TN','South')
into region_state values ('TX','South')
into region_state values ('AZ','West')
into region_state values ('CA','West')
into region_state values ('ID','West')
into region_state values ('MT','West')
into region_state values ('NM','West')
into region_state values ('NV','West')
into region_state values ('OR','West')
into region_state values ('UT','West')
into region_state values ('WA','West')
select * from dual;

