
 select fld_lastmodifiedby
 from (select * from (select t1.*, ROW_NUMBER() OVER ( PARTITION BY fld_requestid order by fld_modifieddate desc ) as rownumber from casdw.trouble_ticket_r t1) t2 where t2.rownumber = 1) tt
 where FLD_REQUESTID = 'OP-000000441828';