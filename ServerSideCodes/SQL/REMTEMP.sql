drop table remtemp
/

create table remtemp
(
ticket_id  		 	        VARCHAR2(255 BYTE),
site_clli6				    VARCHAR2(255 BYTE),
site_state                  VARCHAR2(255 BYTE),
rem_state                   VARCHAR2(255 BYTE),
ckt_id                      VARCHAR2(255 BYTE),
circuit                     VARCHAR2(255 BYTE),
acna                        VARCHAR2(255 BYTE),
request_type                VARCHAR2(255 BYTE),
create_date                 DATE,
cleared_dt                  DATE,
closed_dt                   DATE,
TTR                         VARCHAR2(255 BYTE),
total_duration              VARCHAR2(255 BYTE),
repair_code                 VARCHAR2(255 BYTE),
reqstat                     VARCHAR2(255 BYTE),
location_name               VARCHAR2(255 BYTE),
assignmentprofile           VARCHAR2(255 BYTE)
);

select * from remtemp;

commit;


then use the import wizard in TOAD to load the table