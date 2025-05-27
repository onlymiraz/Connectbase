CREATE PROCEDURE CB_MS.usp_TBL_DASHBOARD
/*
	-- Add any parameters for the stored procedure here
	@var1 int,
	@var2 int
*/
AS
	SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY

    DECLARE @EVENTID INT;

    INSERT INTO [LOG].tbl_StoreProc
    (
        [EVENTNAME],
        [EVENTSTART],
        [EVENTTYPE],
        [EVENTDESCRIPTION]
    )
    VALUES
    (
        'CB_MS.usp_TBL_DASHBOARD',
        CAST(GETDATE() AS DATETIME),
        'STORE PROC',
        'SINGLE_INGESTION'
    )

    SET @EVENTID = SCOPE_IDENTITY();

	BEGIN TRANSACTION

    TRUNCATE TABLE CB_MS.TBL_DASHBOARD;

    INSERT INTO CB_MS.TBL_DASHBOARD
    SELECT
    VENDOR_COMPANY
    ,SERVICEABLE_ADDR
    ,FTR_STATE_IND
    ,CASE WHEN ORDERS.PRIMARY_L IS NULL OR ORDERS.PRIMARY_L  = 'NULL' THEN 'N' ELSE 'Y' END AS ORD_IND
    ,a.INQ_SVC_VALID_IND
    ,CASE WHEN LOGIN_ID LIKE '%connectbase.com' 
              OR LOGIN_ID LIKE '%connected2fiber.com' 
              OR LOGIN_ID LIKE '%capestart.com' 
            THEN 'N' ELSE 'Y' END AS EMAIL_VALID_IND
    ,ENGINE
          ,a.LOGIN_ID
          ,a.ROUTE_NAME
          ,a.REQUESTING_COMPANY
          ,a.CLIENT_COMPANY
          ,a.CCNA_X
          ,a.ADDRESS
          ,a.CITY
          ,a.STATE
          ,a.ZIP
          ,a.COUNTY
          ,a.COUNTRY
          ,a.USER_COMPANY
          ,a.TARGET_COMPANY
          ,a.REQUEST_DATE
          ,CASE WHEN ERROR_MESSAGE IN ('READY','EXPIRED') AND VENDOR_COMPANY LIKE '%MASTERSTREAM%' THEN 1
            WHEN VENDOR_COMPANY LIKE '%MASTERSTREAM%' THEN 0
            else RESULT END AS RESULT
          ,a.SERVICENAME
          ,a.SERVICE_TYPE
          ,a.ERROR_MESSAGE
          ,a.TERMS
	      ,A.MIN_ID
	      ,ORDERS.*


    FROM(
    select
    case when file_name like '%cb%' then 'ConnectBase' 
	    when file_name like '%master%' then 'Masterstream'end as VENDOR_COMPANY
    ,CASE WHEN RESULT = '1' then 'y'
	    when ERROR_MESSAGE IN ('READY','EXPIRED') AND file_name like '%master%' THEN 'Y' 
	    ELSE 'N' END AS SERVICEABLE_ADDR
    ,CASE WHEN a.STATE in ('AL', 'AZ', 'CA', 'CT', 'FL', 'GA', 'IA', 'IL' , 'IN', 'MI', 'MN', 'MS', 'NC','NE', 'NM', 'NV', 'NY', 'OH', 'PA', 'SC', 'TN', 'TX', 'UT', 'WI', 'WV') THEN 'Y' ELSE 'N' END FTR_STATE_IND
          ,CASE WHEN COALESCE(a.SERVICE_TYPE,a.SERVICENAME) LIKE '%BROADBAND%' AND a.TARGET_COMPANY_ID = '819' THEN 'N'
    WHEN COALESCE(a.SERVICE_TYPE,a.SERVICENAME) NOT LIKE '%BROADBAND%' AND TARGET_COMPANY_ID = '750' THEN 'N'
    ELSE 'Y' END AS INQ_SVC_VALID_IND
    ,case when file_name like '%master%' then 'MASTERSTREAM'
	    when file_name like '%819%' then '819'
	    when file_name like '%750%' then '750' ELSE FILE_NAME END AS ENGINE
	       ,a.LOGIN_ID
          ,a.ROUTE_NAME
          ,a.REQUESTING_COMPANY
          ,a.CLIENT_COMPANY
          ,a.CCNA_X
          ,a.ADDRESS
          ,a.CITY
          ,a.STATE
          ,a.ZIP
          ,a.COUNTY
          ,a.COUNTRY
          ,a.USER_COMPANY
          ,a.TARGET_COMPANY
          ,CAST(a.REQUEST_DATE AS DATE) as REQUEST_DATE
          ,a.RESULT
          ,a.SERVICENAME
          ,a.SERVICE_TYPE
          ,a.ERROR_MESSAGE
          ,a.TERMS
	      ,MIN(ID) AS MIN_ID
	  

    from WAD_PRD_02.cb_ms.CB_MS_COMBINED_v a 

    group by case when file_name like '%cb%' then 'ConnectBase' 
	    when file_name like '%master%' then 'Masterstream'end
	    ,CASE WHEN RESULT = '1' then 'y'
	    when ERROR_MESSAGE IN ('READY','EXPIRED') AND file_name like '%master%' THEN 'Y' 
	    ELSE 'N' END
	    ,CASE WHEN a.STATE in ('AL', 'AZ', 'CA', 'CT', 'FL', 'GA', 'IA', 'IL' , 'IN', 'MI', 'MN', 'MS', 'NC','NE', 'NM', 'NV', 'NY', 'OH', 'PA', 'SC', 'TN', 'TX', 'UT', 'WI', 'WV') THEN 'Y' ELSE 'N' END
        ,CASE WHEN COALESCE(a.SERVICE_TYPE,a.SERVICENAME) LIKE '%BROADBAND%' AND a.TARGET_COMPANY_ID = '819' THEN 'N'
    WHEN COALESCE(a.SERVICE_TYPE,a.SERVICENAME) NOT LIKE '%BROADBAND%' AND TARGET_COMPANY_ID = '750' THEN 'N'
    ELSE 'Y' END
    ,case when file_name like '%master%' then 'MASTERSTREAM'
	    when file_name like '%819%' then '819'
	    when file_name like '%750%' then '750' ELSE FILE_NAME END
    ,a.LOGIN_ID
          ,a.ROUTE_NAME
          ,a.REQUESTING_COMPANY
          ,a.CLIENT_COMPANY
          ,a.CCNA_X
          ,a.ADDRESS
          ,a.CITY
          ,a.STATE
          ,a.ZIP
          ,a.COUNTY
          ,a.COUNTRY
          ,a.USER_COMPANY
          ,a.TARGET_COMPANY
          ,cast(a.REQUEST_DATE as date)
          ,a.RESULT
          ,a.SERVICENAME
          ,a.SERVICE_TYPE
          ,a.ERROR_MESSAGE
          ,a.TERMS
    )A

    LEFT JOIN (SELECT *

    FROM(
    SELECT
    xref.PRIMARY_CARRIER_NM as primary_l
    ,xref2.PRIMARY_CARRIER_NM as primary_r
    ,CASE WHEN SO_EFF_COMP_DT_R <>'NULL' THEN 'Y' ELSE 'N' END AS COMPLETION_IND
    ,py.*
    ,row_number() over(partition by ORDNO_R,PON_R,WTN_R,BTN_R ORDER BY REQUEST_DATE_L DESC) AS ROW_NUM

    FROM WAD_PRD_02.CB_MS.TBL_PY_OUTPUT PY

    LEFT JOIN WAD_PRD_Playground.DBO.CB_MS_XREF_V XREF
    ON charindex(TRIM(PY.REQUESTING_COMPANY_l),xref.SEARCH_COMPANIES)>0

    LEFT JOIN WAD_PRD_Playground.DBO.CB_MS_XREF_V XREF2
    ON charindex(TRIM(PY.CCNA_R),XREF2.COMBINED_ACNA)>0


    where datediff(day,REQUEST_DATE_l,so_create_dt_r)<= '180'
    and cast(so_create_dt_r as date)>=cast(REQUEST_DATE_l as date)
    and (SERVICENAME_l like '%broadband%'or service_type_l like '%broadband%')
    and RESULT_l = '1'
    and ACT_r = 'n'
    and py.updated_dt = (select max(updated_dt) from WAD_PRD_02.CB_MS.TBL_PY_OUTPUT)
    )A
    WHERE charindex(TRIM(PRIMARY_r),primary_l)>0
    AND ROW_NUM = 1) ORDERS

    ON A.MIN_ID = ORDERS.ID_L
    where CASE WHEN LOGIN_ID LIKE '%connectbase.com' 
              OR LOGIN_ID LIKE '%connected2fiber.com' 
              OR LOGIN_ID LIKE '%capestart.com' 
            THEN 'N' ELSE 'Y' END = 'Y'
		
	COMMIT TRANSACTION

    UPDATE L
    SET L.EVENTEND = CAST(GETDATE() AS DATETIME)
    FROM LOG.tbl_StoreProc L
    WHERE L.EVENTID = @EventID;


END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
GO

