CREATE VIEW [dbo].[NEUSTAR_ORDERS_V]
	AS SELECT
REPORT_RUN_DATE
          ,ENV
          ,ORDNO
          ,WTN
          ,BTN
          ,CUSTNM
          ,PON
          ,ORD_TYPE
          ,CCNA
          ,SERV_TYPE
          ,STAGE
          ,SO_ACT_COMP_DT
FROM(
SELECT REPORT_RUN_DATE
          ,ENV
          ,ORDNO
          ,WTN
          ,BTN
          ,CUSTNM
          ,PON
          ,ORD_TYPE
          ,CCNA
          ,SERV_TYPE
          ,STAGE
          ,SO_ACT_COMP_DT
          ,ROW_NUMBER() OVER (PARTITION BY ORDNO, ENV ORDER BY REPORT_RUN_DATE asc) AS RN
    FROM dbo.TBL_NEUSTAR_ORDERS
--ORDER BY ORDNO
)A
WHERE A.REPORT_RUN_DATE = (SELECT MAX(REPORT_RUN_DATE) FROM dbo.TBL_NEUSTAR_ORDERS)
AND RN = 1