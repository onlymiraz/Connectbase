CREATE VIEW [dbo].[M6_DAILY_RESTATE_ORDER_CONF_V] AS
SELECT 
    a.*, -- Select all columns from TBL_M6_DAILY_RESTATE_ORDER_CONF
    b.SECONDARY_ID,
    b.PRIMARY_CARRIER_NM, -- Add the Primary_carrier_Nm column from MCL_V
    CASE
        WHEN (a.P_NUM IN ('EIAV005999300495', 'EPAV005999300495', 'EPAV005999300495PP') 
              AND b.Primary_carrier_Nm = 'VERIZON') 
            THEN 'New PNUM'
        WHEN (a.P_NUM IN ('EIAV007999SCM646', 'EIAV007999SCM646SP') 
              AND b.Primary_carrier_Nm = 'SWITCH INC') 
            THEN 'New PNUM'
        WHEN ((a.P_NUM LIKE 'EIAV007%' OR a.P_NUM LIKE 'EPAV007%') 
              AND a.P_NUM NOT LIKE '%ICB%') 
            THEN 'New PNUM'
        WHEN ((a.P_NUM LIKE 'EPAV007%') 
              AND SUBSTRING(a.P_NUM, 17, 2) = 'PP' 
              AND a.P_NUM NOT LIKE '%ICB%') 
            THEN 'New PNUM'
        ELSE 'Old PNUM' 
    END AS P_NUM_CATEGORY -- Add the calculated P_NUM_CATEGORY
FROM 
    dbo.TBL_M6_DAILY_RESTATE_ORDER_CONF a
LEFT JOIN 
    dbo.MCL_V b
ON 
    a.ACNA = b.secondary_id; -- Join condition
GO


