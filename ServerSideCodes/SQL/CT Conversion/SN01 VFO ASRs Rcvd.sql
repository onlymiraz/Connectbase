
--For SN01 ASRs Received for CT  
select count(*)
FROM PRDVFODBA.ORDERINFO@TEAM_OSS.OM2SYN_REFUSER
WHERE to_char(SUBMITTEDDATETIME,'yyyymmdd') = '20141118'
AND DIRECTION = 'RECEIVE'
and orderstatus = 'Accepted_Submitted'
and isccode = 'SN01'
and ccna not in ('CUS','SNE')









SELECT  ISCCODE              "Receiver Code",
        CCNA "Customer Code",
        PON "Pon",
        VERSION      "Ver",
        SUPPTYPE "Sup",
        ORDERSTATUS "Status",
        SUBSTR(SERVICETYPE,5) "Svctyp",
        REQTYPE      "Reqtyp",
        ACTIVITY "Act",
        DUEDATE     "DDD",
        INITIATORNAME "Owner",
        MAX(SUBMITTEDDATETIME) "Date Sent/  Received",
       MAX(ORDERINFO.ORDERINFOID) keep (dense_rank last order by ORDERINFO.UPDATEDATETIME) ORD_ID
FROM PRDVFODBA.ORDERINFO@TEAM_OSS.OM2SYN_REFUSER
WHERE trunc(SUBMITTEDDATETIME) BETWEEN TO_DATE('20141020', 'YYYYMMDD') AND TO_DATE( '20141021', 'YYYYMMDD')
AND ISCCODE NOT IN ('CI75','FTRORD')
AND DIRECTION = 'RECEIVE'
GROUP BY  DIRECTION,
          ISCCODE,
          CCNA,
          PON,
          VERSION,
          SUPPTYPE,
          ORDERSTATUS,
          SERVICETYPE,REQTYPE,
          ACTIVITY,
          DUEDATE,
          INITIATORNAME



		 
 