
CREATE PROCEDURE [ProjApproval].[Edit_PreSale_Compiled]
AS
	SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
	BEGIN TRANSACTION

DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__Edit_PreSale_Compiled
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[ProjApproval].[Edit_PreSale_Compiled]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_ProjApproval__Edit_PreSale_Compiled
FROM [LOG].[Tracker]


--By Opp

UPDATE PC SET [CRC Date] = EPC.[CRC Date] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[CRC Date] != ''
UPDATE PC SET [Project Description] = EPC.[Project Description] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Project Description] != ''
UPDATE PC SET [Budget Category] = EPC.[Budget Category] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Budget Category] != ''
UPDATE PC SET [Exchange] = EPC.[Exchange] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Exchange] != ''
UPDATE PC SET [State] = EPC.[State] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[State] != ''
UPDATE PC SET [Total ISP Capital - Fully Loaded] = EPC.[Total ISP Capital - Fully Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Total ISP Capital - Fully Loaded] != ''
UPDATE PC SET [Total OSP Capital - Fully Loaded] = EPC.[Total OSP Capital - Fully Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Total OSP Capital - Fully Loaded] != ''
UPDATE PC SET [Total Capital - Fully Loaded] = EPC.[Total Capital - Fully Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Total Capital - Fully Loaded] != ''
UPDATE PC SET [MRC - Fully Loaded] = EPC.[MRC - Fully Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[MRC - Fully Loaded] != ''
UPDATE PC SET [CIAC - Fully Loaded] = EPC.[CIAC - Fully Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[CIAC - Fully Loaded] != ''
UPDATE PC SET [NPV - Fully Loaded] = EPC.[NPV - Fully Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[NPV - Fully Loaded] != ''
UPDATE PC SET [IRR - Fully Loaded] = EPC.[IRR - Fully Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[IRR - Fully Loaded] != ''
UPDATE PC SET [Payback - Fully Loaded] = EPC.[Payback - Fully Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Payback - Fully Loaded] != ''
UPDATE PC SET [Total ISP Capital - 20% Loaded] = EPC.[Total ISP Capital - 20% Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Total ISP Capital - 20% Loaded] != ''
UPDATE PC SET [Total OSP Capital - 20% Loaded] = EPC.[Total OSP Capital - 20% Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Total OSP Capital - 20% Loaded] != ''
UPDATE PC SET [Total Capital - 20% Loaded] = EPC.[Total Capital - 20% Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Total Capital - 20% Loaded] != ''
UPDATE PC SET [MRC - 20% Loaded] = EPC.[MRC - 20% Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[MRC - 20% Loaded] != ''
UPDATE PC SET [CIAC - 20% Loaded] = EPC.[CIAC - 20% Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[CIAC - 20% Loaded] != ''
UPDATE PC SET [NPV - 20% Loaded] = EPC.[NPV - 20% Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[NPV - 20% Loaded] != ''
UPDATE PC SET [IRR - 20% Loaded] = EPC.[IRR - 20% Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[IRR - 20% Loaded] != ''
UPDATE PC SET [Payback - 20% Loaded] = EPC.[Payback - 20% Loaded] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Payback - 20% Loaded] != ''
UPDATE PC SET [Term in Months] = EPC.[Term in Months] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Term in Months] != ''
UPDATE PC SET [Bandwidth (Number of Units)] = EPC.[Bandwidth (Number of Units)] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Bandwidth (Number of Units)] != ''
UPDATE PC SET [Bandwidth (Unit of Measurement)] = EPC.[Bandwidth (Unit of Measurement)] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Bandwidth (Unit of Measurement)] != ''
UPDATE PC SET [NRC] = EPC.[NRC] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[NRC] != ''
UPDATE PC SET [Monthly Expense] = EPC.[Monthly Expense] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Monthly Expense] != ''
UPDATE PC SET [Capital Request] = EPC.[Capital Request] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Capital Request] != ''
UPDATE PC SET [Capital Request Q1] = EPC.[Capital Request Q1] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Capital Request Q1] != ''
UPDATE PC SET [Capital Request Q2] = EPC.[Capital Request Q2] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Capital Request Q2] != ''
UPDATE PC SET [Capital Request Q3] = EPC.[Capital Request Q3] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Capital Request Q3] != ''
UPDATE PC SET [Capital Request Q4] = EPC.[Capital Request Q4] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Capital Request Q4] != ''
UPDATE PC SET [Capital Cost Future Years] = EPC.[Capital Cost Future Years] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Capital Cost Future Years] != ''
UPDATE PC SET [Street Address] = EPC.[Street Address] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Street Address] != ''
UPDATE PC SET [City] = EPC.[City] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[City] != ''
UPDATE PC SET [ZIP Code] = EPC.[ZIP] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[ZIP] != ''
UPDATE PC SET [Link Code] = EPC.[Link Code] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Link Code] != ''
UPDATE PC SET [Build] = EPC.[Build] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Build] != ''
UPDATE PC SET [Grants Name] = EPC.[Grants Name] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Grants Name] != ''
UPDATE PC SET [Cost Per Household] = EPC.[Cost Per Household] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Cost Per Household] != ''
UPDATE PC SET [Household Forecast] = EPC.[Household Forecast] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Household Forecast] != ''
UPDATE PC SET [Take Rate] = EPC.[Take Rate] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Take Rate] != ''
UPDATE PC SET [Cost To Connect] = EPC.[Cost To Connect] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Cost To Connect] != ''
UPDATE PC SET [Video Enabled State] = EPC.[Video Enabled State] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Video Enabled State] != ''
UPDATE PC SET [Type of Deal] = EPC.[Type of Deal] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Type of Deal] != ''
UPDATE PC SET [Unit Opportunity] = EPC.[Unit Opportunity] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Unit Opportunity] != ''
UPDATE PC SET [Cost Per Unit] = EPC.[Cost Per Unit] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Cost Per Unit] != ''
UPDATE PC SET [Unit Forecast] = EPC.[Unit Forecast] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Unit Forecast] != ''
UPDATE PC SET [Take Rate - Engineering/Proforma] = EPC.[Take Rate - Engineering/Proforma] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Take Rate - Engineering/Proforma] != ''
UPDATE PC SET [ROI Take Rate] = EPC.[ROI Take Rate] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[ROI Take Rate] != ''
UPDATE PC SET [Average Take Rate] = EPC.[Average Take Rate] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Average Take Rate] != ''
UPDATE PC SET [Total Revenue] = EPC.[Total Revenue] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Total Revenue] != ''
UPDATE PC SET [Competitor] = EPC.[Competitor] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Competitor] != ''
UPDATE PC SET [Brownfield/Greenfield] = EPC.[Brownfield/Greenfield] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Brownfield/Greenfield] != ''
UPDATE PC SET [Notes] = EPC.[Notes] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Notes] != ''
UPDATE PC SET [Additional Documents] = EPC.[Additional Documents] FROM ProjApproval.PreSale_Compiled AS PC, ProjApproval.EditScreen_PreSale_Compiled AS EPC  where PC.[Opportunity ID] = EPC.[Opportunity ID] AND EPC.[Additional Documents] != ''

TRUNCATE TABLE ProjApproval.EditScreen_PreSale_Compiled


delete from ProjApproval.PreSale_Compiled
FROM     ProjApproval.PreSale_Compiled INNER JOIN
                  ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed 
				  ON ProjApproval.PreSale_Compiled.[Opportunity ID] = ProjApproval.InputScreen_Projects_ExistingOpportunity_Trimmed.OpportunityID
where ProjApproval.PreSale_Compiled.[Project Number] like 'TBD'



Update ProjApproval.PreSale_Compiled
set build = replace(build, '["', '')
Update ProjApproval.PreSale_Compiled
set build = replace(build, '"]', '')

Update ProjApproval.PreSale_Compiled
set [Type of Deal] = replace([Type of Deal], '["', '')
Update ProjApproval.PreSale_Compiled
set [Type of Deal] = replace([Type of Deal], '"]', '')

Update ProjApproval.PreSale_Compiled
set [Brownfield/Greenfield] = replace([Brownfield/Greenfield], '["', '')
Update ProjApproval.PreSale_Compiled
set [Brownfield/Greenfield] = replace([Brownfield/Greenfield], '"]', '')
UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_ProjApproval__Edit_PreSale_Compiled P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_ProjApproval__Edit_PreSale_Compiled

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@trancount > 0 ROLLBACK TRANSACTION
	EXEC usp_error_handler
	RETURN 55555
END CATCH
