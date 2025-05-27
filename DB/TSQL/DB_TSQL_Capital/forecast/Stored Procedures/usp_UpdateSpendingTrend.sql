CREATE procedure [forecast].[usp_UpdateSpendingTrend]
as
	set xact_abort, nocount off
begin try
	begin transaction
		DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateSpendingTrend
INSERT INTO [LOG].[Tracker]
    ([EVENTNAME]
    ,[EVENTSTART]
    ,[EVENTTYPE]
    ,[EVENTDESCRIPTION])
VALUES
('[forecast].[usp_UpdateSpendingTrend]'
    ,CAST(GETDATE() AS DATETIME)
    ,'STORE PROC'
    ,'Daily capital forecast report')

SELECT MAX(EVENTID) AS LATESTID  INTO LOG.Tracker_Temp_forecast__usp_UpdateSpendingTrend
FROM [LOG].[Tracker]

		
		
		
		DROP TABLE forecast.SpendingTrend
		
		-- Update trend data with forecast export
		MERGE forecast.SpendingTrendData AS E
		USING forecast.ForecastExport AS I
		ON (E.ProjectNumber = I.ProjectNumber AND E.SubprojectNumber = I.SubprojectNumber)
		WHEN MATCHED THEN
			UPDATE
			SET E.BudgetLineNumber = I.BudgetLineNumber,
				E.ClassOfPlant = I.ClassOfPlant,
				E.LinkCode = I.LinkCode,
				E.BudgetCategory = I.BudgetCategory,
				E.JustificationCode = I.JustificationCode,
				E.FunctionalGroup = I.FunctionalGroup,
				E.ProjectDescription = I.ProjectDescription,
				E.ProjectStatusCode = I.ProjectStatusCode,
				E.ApprovalCode = I.ApprovalCode,
				E.EstimatedStartDate = I.EstimatedStartDate,
				E.EstimatedCompleteDate = I.EstimatedCompleteDate,
				E.ActualStartDate = I.ActualStartDate,
				E.TentativeCloseDate = I.TentativeCloseDate,
				E.CloseDate = I.CloseDate,
				AuthorizedDirect = I.AuthorizedDirect,
				AuthorizedIndirect = I.AuthorizedIndirect,
				JanuaryDirect2024 = I.JanuaryDirect,
				JanuaryIndirect2024 = I.JanuaryIndirect,
				FebruaryDirect2024 = I.FebruaryDirect,
				FebruaryIndirect2024 = I.FebruaryIndirect,
				MarchDirect2024 = I.MarchDirect,
				MarchIndirect2024 = I.MarchIndirect,
				AprilDirect2024 = I.AprilDirect,
				AprilIndirect2024 = I.AprilIndirect,
				MayDirect2024 = I.MayDirect,
				MayIndirect2024 = I.MayIndirect,
				JuneDirect2024 = I.JuneDirect,
				JuneIndirect2024 = I.JuneIndirect,
				JulyDirect2024 = I.JulyDirect,
				JulyIndirect2024 = I.JulyIndirect,
				AugustDirect2024 = I.AugustDirect,
				AugustIndirect2024 = I.AugustIndirect,
				SeptemberDirect2024 = I.SeptemberDirect,
				SeptemberIndirect2024 = I.SeptemberIndirect,
				OctoberDirect2024 = I.OctoberDirect,
				OctoberIndirect2024 = I.OctoberIndirect,
				NovemberDirect2024 = I.NovemberDirect,
				NovemberIndirect2024 = I.NovemberIndirect,
				DecemberDirect2024 = I.DecemberDirect,
				DecemberIndirect2024 = I.DecemberIndirect


		WHEN NOT MATCHED THEN
			INSERT (ProjectNumber, SubprojectNumber, BudgetLineNumber, ClassOfPlant, LinkCode, BudgetCategory, JustificationCode, FunctionalGroup, ProjectDescription, ProjectStatusCode, ApprovalCode, ApprovalDate, EstimatedStartDate, EstimatedCompleteDate, ActualStartDate, ReadyForServiceDate, TentativeCloseDate, CloseDate, AuthorizedDirect, AuthorizedIndirect, AuthorizedTotal,
					JanuaryDirect2017, JanuaryIndirect2017, FebruaryDirect2017, FebruaryIndirect2017, MarchDirect2017, MarchIndirect2017, AprilDirect2017, AprilIndirect2017, MayDirect2017, MayIndirect2017, JuneDirect2017, JuneIndirect2017, JulyDirect2017, JulyIndirect2017, AugustDirect2017, AugustIndirect2017, SeptemberDirect2017, SeptemberIndirect2017, OctoberDirect2017, OctoberIndirect2017, NovemberDirect2017, NovemberIndirect2017, DecemberDirect2017, DecemberIndirect2017,
					JanuaryDirect2018, JanuaryIndirect2018, FebruaryDirect2018, FebruaryIndirect2018, MarchDirect2018, MarchIndirect2018, AprilDirect2018, AprilIndirect2018, MayDirect2018, MayIndirect2018, JuneDirect2018, JuneIndirect2018, JulyDirect2018, JulyIndirect2018, AugustDirect2018, AugustIndirect2018, SeptemberDirect2018, SeptemberIndirect2018, OctoberDirect2018, OctoberIndirect2018, NovemberDirect2018, NovemberIndirect2018, DecemberDirect2018, DecemberIndirect2018,
					JanuaryDirect2019, JanuaryIndirect2019, FebruaryDirect2019, FebruaryIndirect2019, MarchDirect2019, MarchIndirect2019, AprilDirect2019, AprilIndirect2019, MayDirect2019, MayIndirect2019, JuneDirect2019, JuneIndirect2019, JulyDirect2019, JulyIndirect2019, AugustDirect2019, AugustIndirect2019, SeptemberDirect2019, SeptemberIndirect2019, OctoberDirect2019, OctoberIndirect2019, NovemberDirect2019, NovemberIndirect2019, DecemberDirect2019, DecemberIndirect2019,
					JanuaryDirect2020, JanuaryIndirect2020, FebruaryDirect2020, FebruaryIndirect2020, MarchDirect2020, MarchIndirect2020, AprilDirect2020, AprilIndirect2020, MayDirect2020, MayIndirect2020, JuneDirect2020, JuneIndirect2020, JulyDirect2020, JulyIndirect2020, AugustDirect2020, AugustIndirect2020, SeptemberDirect2020, SeptemberIndirect2020, OctoberDirect2020, OctoberIndirect2020, NovemberDirect2020, NovemberIndirect2020, DecemberDirect2020, DecemberIndirect2020,
					JanuaryDirect2021, JanuaryIndirect2021, FebruaryDirect2021, FebruaryIndirect2021, MarchDirect2021, MarchIndirect2021, AprilDirect2021, AprilIndirect2021, MayDirect2021, MayIndirect2021, JuneDirect2021, JuneIndirect2021, JulyDirect2021, JulyIndirect2021, AugustDirect2021, AugustIndirect2021, SeptemberDirect2021, SeptemberIndirect2021, OctoberDirect2021, OctoberIndirect2021, NovemberDirect2021, NovemberIndirect2021, DecemberDirect2021, DecemberIndirect2021,
					JanuaryDirect2022, JanuaryIndirect2022, FebruaryDirect2022, FebruaryIndirect2022, MarchDirect2022, MarchIndirect2022, AprilDirect2022, AprilIndirect2022, MayDirect2022, MayIndirect2022, JuneDirect2022, JuneIndirect2022, JulyDirect2022, JulyIndirect2022, AugustDirect2022, AugustIndirect2022, SeptemberDirect2022, SeptemberIndirect2022, OctoberDirect2022, OctoberIndirect2022, NovemberDirect2022, NovemberIndirect2022, DecemberDirect2022, DecemberIndirect2022,
					JanuaryDirect2023, JanuaryIndirect2023, FebruaryDirect2023, FebruaryIndirect2023, MarchDirect2023, MarchIndirect2023, AprilDirect2023, AprilIndirect2023, MayDirect2023, MayIndirect2023, JuneDirect2023, JuneIndirect2023, JulyDirect2023, JulyIndirect2023, AugustDirect2023, AugustIndirect2023, SeptemberDirect2023, SeptemberIndirect2023, OctoberDirect2023, OctoberIndirect2023, NovemberDirect2023, NovemberIndirect2023, DecemberDirect2023, DecemberIndirect2023,
					JanuaryDirect2024, JanuaryIndirect2024, FebruaryDirect2024, FebruaryIndirect2024, MarchDirect2024, MarchIndirect2024, AprilDirect2024, AprilIndirect2024, MayDirect2024, MayIndirect2024, JuneDirect2024, JuneIndirect2024, JulyDirect2024, JulyIndirect2024, AugustDirect2024, AugustIndirect2024, SeptemberDirect2024, SeptemberIndirect2024, OctoberDirect2024, OctoberIndirect2024, NovemberDirect2024, NovemberIndirect2024, DecemberDirect2024, DecemberIndirect2024)
			VALUES (I.ProjectNumber, I.SubprojectNumber, I.BudgetLineNumber, I.ClassOfPlant, I.LinkCode, I.BudgetCategory, I.JustificationCode, I.FunctionalGroup, I.ProjectDescription, I.ProjectStatusCode, I.ApprovalCode, I.ApprovalDate, I.EstimatedStartDate, I.EstimatedCompleteDate, I.ActualStartDate, I.ReadyForServiceDate, I.TentativeCloseDate, I.CloseDate, I.AuthorizedDirect, I.AuthorizedIndirect, (I.AuthorizedDirect + I.AuthorizedIndirect),
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
					I.JanuaryDirect, I.JanuaryIndirect, I.FebruaryDirect, I.FebruaryIndirect, I.MarchDirect, I.MarchIndirect, I.AprilDirect, I.AprilIndirect, I.MayDirect, I.MayIndirect, I.JuneDirect, I.JuneIndirect, I.JulyDirect, I.JulyIndirect, I.AugustDirect, I.AugustIndirect, I.SeptemberDirect, I.SeptemberIndirect, I.OctoberDirect, I.OctoberIndirect, I.NovemberDirect, I.NovemberIndirect, I.DecemberDirect, I.DecemberIndirect);

		-- Create spending trend
		SELECT ProjectNumber,
				--SubprojectNumber,
				MIN(BudgetCategory) AS [BudgetCategory],
				--JustificationCode,
				MIN(ApprovalCode) AS [ApprovalCode],
				ISNULL(MONTH(MIN(ActualStartDate)) + IIF(YEAR(MIN(ActualStartDate)) = 2017, 0, IIF(YEAR(MIN(ActualStartDate)) = 2018, 12, 24)), 90) AS [MonthYearAssignment],
				CAST(MONTH(MIN(ActualStartDate)) AS varchar(6)) + '/' + CAST(YEAR(MIN(ActualStartDate)) AS varchar(6)) AS [StartMonthDate],
				YEAR(MIN(ActualStartDate)) AS [StartYear],
				MONTH(MIN(ActualStartDate)) AS [StartMonth],
				MIN(ActualStartDate) AS [ActualStartDate],
					SUM(AuthorizedDirect) AS [AuthorizedDirect],
					SUM(AuthorizedIndirect) AS [AuthorizedIndirect],
					-- 2017 Gross Adds
					SUM(JanuaryDirect2017) AS [JanuaryDirect2017], SUM(JanuaryIndirect2017) AS [JanuaryIndirect2017],
					SUM(FebruaryDirect2017) AS [FebruaryDirect2017], SUM(FebruaryIndirect2017) AS [FebruaryIndirect2017],
					SUM(MarchDirect2017) AS [MarchDirect2017], SUM(MarchIndirect2017) AS [MarchIndirect2017],
					SUM(AprilDirect2017) AS [AprilDirect2017], SUM(AprilIndirect2017) AS [AprilIndirect2017],
					SUM(MayDirect2017) AS [MayDirect2017], SUM(MayIndirect2017) AS [MayIndirect2017],
					SUM(JuneDirect2017) AS [JuneDirect2017], SUM(JuneIndirect2017) AS [JuneIndirect2017],
					SUM(JulyDirect2017) AS [JulyDirect2017], SUM(JulyIndirect2017) AS [JulyIndirect2017],
					SUM(AugustDirect2017) AS [AugustDirect2017], SUM(AugustIndirect2017) AS [AugustIndirect2017],
					SUM(SeptemberDirect2017) AS [SeptemberDirect2017], SUM(SeptemberIndirect2017) AS [SeptemberIndirect2017],
					SUM(OctoberDirect2017) AS [OctoberDirect2017], SUM(OctoberIndirect2017) AS [OctoberIndirect2017],
					SUM(NovemberDirect2017) AS [NovemberDirect2017], SUM(NovemberIndirect2017) AS [NovemberIndirect2017],
					SUM(DecemberDirect2017) AS [DecemberDirect2017], SUM(DecemberIndirect2017) AS [DecemberIndirect2017],
					-- 2018 Gross Adds
					SUM(JanuaryDirect2018) AS [JanuaryDirect2018], SUM(JanuaryIndirect2018) AS [JanuaryIndirect2018],
					SUM(FebruaryDirect2018) AS [FebruaryDirect2018], SUM(FebruaryIndirect2018) AS [FebruaryIndirect2018],
					SUM(MarchDirect2018) AS [MarchDirect2018], SUM(MarchIndirect2018) AS [MarchIndirect2018],
					SUM(AprilDirect2018) AS [AprilDirect2018], SUM(AprilIndirect2018) AS [AprilIndirect2018],
					SUM(MayDirect2018) AS [MayDirect2018], SUM(MayIndirect2018) AS [MayIndirect2018],
					SUM(JuneDirect2018) AS [JuneDirect2018], SUM(JuneIndirect2018) AS [JuneIndirect2018],
					SUM(JulyDirect2018) AS [JulyDirect2018], SUM(JulyIndirect2018) AS [JulyIndirect2018],
					SUM(AugustDirect2018) AS [AugustDirect2018], SUM(AugustIndirect2018) AS [AugustIndirect2018],
					SUM(SeptemberDirect2018) AS [SeptemberDirect2018], SUM(SeptemberIndirect2018) AS [SeptemberIndirect2018],
					SUM(OctoberDirect2018) AS [OctoberDirect2018], SUM(OctoberIndirect2018) AS [OctoberIndirect2018],
					SUM(NovemberDirect2018) AS [NovemberDirect2018], SUM(NovemberIndirect2018) AS [NovemberIndirect2018],
					SUM(DecemberDirect2018) AS [DecemberDirect2018], SUM(DecemberIndirect2018) AS [DecemberIndirect2018],
					-- 2019 Gross Adds
					SUM(JanuaryDirect2019) AS [JanuaryDirect2019], SUM(JanuaryIndirect2019) AS [JanuaryIndirect2019],
					SUM(FebruaryDirect2019) AS [FebruaryDirect2019], SUM(FebruaryIndirect2019) AS [FebruaryIndirect2019],
					SUM(MarchDirect2019) AS [MarchDirect2019], SUM(MarchIndirect2019) AS [MarchIndirect2019],
					SUM(AprilDirect2019) AS [AprilDirect2019], SUM(AprilIndirect2019) AS [AprilIndirect2019],
					SUM(MayDirect2019) AS [MayDirect2019], SUM(MayIndirect2019) AS [MayIndirect2019],
					SUM(JuneDirect2019) AS [JuneDirect2019], SUM(JuneIndirect2019) AS [JuneIndirect2019],
					SUM(JulyDirect2019) AS [JulyDirect2019], SUM(JulyIndirect2019) AS [JulyIndirect2019],
					SUM(AugustDirect2019) AS [AugustDirect2019], SUM(AugustIndirect2019) AS [AugustIndirect2019],
					SUM(SeptemberDirect2019) AS [SeptemberDirect2019], SUM(SeptemberIndirect2019) AS [SeptemberIndirect2019],
					SUM(OctoberDirect2019) AS [OctoberDirect2019], SUM(OctoberIndirect2019) AS [OctoberIndirect2019],
					SUM(NovemberDirect2019) AS [NovemberDirect2019], SUM(NovemberIndirect2019) AS [NovemberIndirect2019],
					SUM(DecemberDirect2019) AS [DecemberDirect2019], SUM(DecemberIndirect2019) AS [DecemberIndirect2019],
					-- 2020 Gross Adds
					SUM(JanuaryDirect2020) AS [JanuaryDirect2020], SUM(JanuaryIndirect2020) AS [JanuaryIndirect2020],
					SUM(FebruaryDirect2020) AS [FebruaryDirect2020], SUM(FebruaryIndirect2020) AS [FebruaryIndirect2020],
					SUM(MarchDirect2020) AS [MarchDirect2020], SUM(MarchIndirect2020) AS [MarchIndirect2020],
					SUM(AprilDirect2020) AS [AprilDirect2020], SUM(AprilIndirect2020) AS [AprilIndirect2020],
					SUM(MayDirect2020) AS [MayDirect2020], SUM(MayIndirect2020) AS [MayIndirect2020],
					SUM(JuneDirect2020) AS [JuneDirect2020], SUM(JuneIndirect2020) AS [JuneIndirect2020],
					SUM(JulyDirect2020) AS [JulyDirect2020], SUM(JulyIndirect2020) AS [JulyIndirect2020],
					SUM(AugustDirect2020) AS [AugustDirect2020], SUM(AugustIndirect2020) AS [AugustIndirect2020],
					SUM(SeptemberDirect2020) AS [SeptemberDirect2020], SUM(SeptemberIndirect2020) AS [SeptemberIndirect2020],
					SUM(OctoberDirect2020) AS [OctoberDirect2020], SUM(OctoberIndirect2020) AS [OctoberIndirect2020],
					SUM(NovemberDirect2020) AS [NovemberDirect2020], SUM(NovemberIndirect2020) AS [NovemberIndirect2020],
					SUM(DecemberDirect2020) AS [DecemberDirect2020], SUM(DecemberIndirect2020) AS [DecemberIndirect2020],
					-- 2021 Gross Adds
					SUM(JanuaryDirect2021) AS [JanuaryDirect2021], SUM(JanuaryIndirect2021) AS [JanuaryIndirect2021],
					SUM(FebruaryDirect2021) AS [FebruaryDirect2021], SUM(FebruaryIndirect2021) AS [FebruaryIndirect2021],
					SUM(MarchDirect2021) AS [MarchDirect2021], SUM(MarchIndirect2021) AS [MarchIndirect2021],
					SUM(AprilDirect2021) AS [AprilDirect2021], SUM(AprilIndirect2021) AS [AprilIndirect2021],
					SUM(MayDirect2021) AS [MayDirect2021], SUM(MayIndirect2021) AS [MayIndirect2021],
					SUM(JuneDirect2021) AS [JuneDirect2021], SUM(JuneIndirect2021) AS [JuneIndirect2021],
					SUM(JulyDirect2021) AS [JulyDirect2021], SUM(JulyIndirect2021) AS [JulyIndirect2021],
					SUM(AugustDirect2021) AS [AugustDirect2021], SUM(AugustIndirect2021) AS [AugustIndirect2021],
					SUM(SeptemberDirect2021) AS [SeptemberDirect2021], SUM(SeptemberIndirect2021) AS [SeptemberIndirect2021],
					SUM(OctoberDirect2021) AS [OctoberDirect2021], SUM(OctoberIndirect2021) AS [OctoberIndirect2021],
					SUM(NovemberDirect2021) AS [NovemberDirect2021], SUM(NovemberIndirect2021) AS [NovemberIndirect2021],
					SUM(DecemberDirect2021) AS [DecemberDirect2021], SUM(DecemberIndirect2021) AS [DecemberIndirect2021],
					-- 2022 Gross Adds
					SUM(JanuaryDirect2022) AS [JanuaryDirect2022], SUM(JanuaryIndirect2022) AS [JanuaryIndirect2022],
					SUM(FebruaryDirect2022) AS [FebruaryDirect2022], SUM(FebruaryIndirect2022) AS [FebruaryIndirect2022],
					SUM(MarchDirect2022) AS [MarchDirect2022], SUM(MarchIndirect2022) AS [MarchIndirect2022],
					SUM(AprilDirect2022) AS [AprilDirect2022], SUM(AprilIndirect2022) AS [AprilIndirect2022],
					SUM(MayDirect2022) AS [MayDirect2022], SUM(MayIndirect2022) AS [MayIndirect2022],
					SUM(JuneDirect2022) AS [JuneDirect2022], SUM(JuneIndirect2022) AS [JuneIndirect2022],
					SUM(JulyDirect2022) AS [JulyDirect2022], SUM(JulyIndirect2022) AS [JulyIndirect2022],
					SUM(AugustDirect2022) AS [AugustDirect2022], SUM(AugustIndirect2022) AS [AugustIndirect2022],
					SUM(SeptemberDirect2022) AS [SeptemberDirect2022], SUM(SeptemberIndirect2022) AS [SeptemberIndirect2022],
					SUM(OctoberDirect2022) AS [OctoberDirect2022], SUM(OctoberIndirect2022) AS [OctoberIndirect2022],
					SUM(NovemberDirect2022) AS [NovemberDirect2022], SUM(NovemberIndirect2022) AS [NovemberIndirect2022],
					SUM(DecemberDirect2022) AS [DecemberDirect2022], SUM(DecemberIndirect2022) AS [DecemberIndirect2022],
					-- 2023 Gross Adds
					SUM(JanuaryDirect2023) AS [JanuaryDirect2023], SUM(JanuaryIndirect2023) AS [JanuaryIndirect2023],
					SUM(FebruaryDirect2023) AS [FebruaryDirect2023], SUM(FebruaryIndirect2023) AS [FebruaryIndirect2023],
					SUM(MarchDirect2023) AS [MarchDirect2023], SUM(MarchIndirect2023) AS [MarchIndirect2023],
					SUM(AprilDirect2023) AS [AprilDirect2023], SUM(AprilIndirect2023) AS [AprilIndirect2023],
					SUM(MayDirect2023) AS [MayDirect2023], SUM(MayIndirect2023) AS [MayIndirect2023],
					SUM(JuneDirect2023) AS [JuneDirect2023], SUM(JuneIndirect2023) AS [JuneIndirect2023],
					SUM(JulyDirect2023) AS [JulyDirect2023], SUM(JulyIndirect2023) AS [JulyIndirect2023],
					SUM(AugustDirect2023) AS [AugustDirect2023], SUM(AugustIndirect2023) AS [AugustIndirect2023],
					SUM(SeptemberDirect2023) AS [SeptemberDirect2023], SUM(SeptemberIndirect2023) AS [SeptemberIndirect2023],
					SUM(OctoberDirect2023) AS [OctoberDirect2023], SUM(OctoberIndirect2023) AS [OctoberIndirect2023],
					SUM(NovemberDirect2023) AS [NovemberDirect2023], SUM(NovemberIndirect2023) AS [NovemberIndirect2023],
					SUM(DecemberDirect2023) AS [DecemberDirect2023], SUM(DecemberIndirect2023) AS [DecemberIndirect2023],
					-- 2024 Gross Adds
					SUM(JanuaryDirect2024) AS [JanuaryDirect2024], SUM(JanuaryIndirect2024) AS [JanuaryIndirect2024],
					SUM(FebruaryDirect2024) AS [FebruaryDirect2024], SUM(FebruaryIndirect2024) AS [FebruaryIndirect2024],
					SUM(MarchDirect2024) AS [MarchDirect2024], SUM(MarchIndirect2024) AS [MarchIndirect2024],
					SUM(AprilDirect2024) AS [AprilDirect2024], SUM(AprilIndirect2024) AS [AprilIndirect2024],
					SUM(MayDirect2024) AS [MayDirect2024], SUM(MayIndirect2024) AS [MayIndirect2024],
					SUM(JuneDirect2024) AS [JuneDirect2024], SUM(JuneIndirect2024) AS [JuneIndirect2024],
					SUM(JulyDirect2024) AS [JulyDirect2024], SUM(JulyIndirect2024) AS [JulyIndirect2024],
					SUM(AugustDirect2024) AS [AugustDirect2024], SUM(AugustIndirect2024) AS [AugustIndirect2024],
					SUM(SeptemberDirect2024) AS [SeptemberDirect2024], SUM(SeptemberIndirect2024) AS [SeptemberIndirect2024],
					SUM(OctoberDirect2024) AS [OctoberDirect2024], SUM(OctoberIndirect2024) AS [OctoberIndirect2024],
					SUM(NovemberDirect2024) AS [NovemberDirect2024], SUM(NovemberIndirect2024) AS [NovemberIndirect2024],
					SUM(DecemberDirect2024) AS [DecemberDirect2024], SUM(DecemberIndirect2024) AS [DecemberIndirect2024]

		INTO forecast.SpendingTrend
		FROM
		(
			SELECT ProjectNumber, 
					SubprojectNumber,
					IIF(CHARINDEX('Carry-In', BudgetCategory) = 0, BudgetCategory, SUBSTRING(BudgetCategory, 0, CHARINDEX(' Carry-In', BudgetCategory))) AS BudgetCategory,
					JustificationCode,
					ApprovalCode,
					ActualStartDate,
					AuthorizedDirect,
					AuthorizedIndirect,
					-- 2017 Gross Adds
					JanuaryDirect2017, JanuaryIndirect2017,
					FebruaryDirect2017, FebruaryIndirect2017,
					MarchDirect2017, MarchIndirect2017, 
					AprilDirect2017, AprilIndirect2017, 
					MayDirect2017, MayIndirect2017, 
					JuneDirect2017, JuneIndirect2017, 
					JulyDirect2017, JulyIndirect2017, 
					AugustDirect2017, AugustIndirect2017, 
					SeptemberDirect2017, SeptemberIndirect2017, 
					OctoberDirect2017, OctoberIndirect2017,
					NovemberDirect2017, NovemberIndirect2017, 
					DecemberDirect2017, DecemberIndirect2017,
					-- 2018 Gross Adds
					JanuaryDirect2018, JanuaryIndirect2018,
					FebruaryDirect2018, FebruaryIndirect2018,
					MarchDirect2018, MarchIndirect2018, 
					AprilDirect2018, AprilIndirect2018, 
					MayDirect2018, MayIndirect2018, 
					JuneDirect2018, JuneIndirect2018, 
					JulyDirect2018, JulyIndirect2018, 
					AugustDirect2018, AugustIndirect2018, 
					SeptemberDirect2018, SeptemberIndirect2018, 
					OctoberDirect2018, OctoberIndirect2018,
					NovemberDirect2018, NovemberIndirect2018, 
					DecemberDirect2018, DecemberIndirect2018,
					-- 2019 Gross Adds
					JanuaryDirect2019, JanuaryIndirect2019,
					FebruaryDirect2019, FebruaryIndirect2019,
					MarchDirect2019, MarchIndirect2019, 
					AprilDirect2019, AprilIndirect2019, 
					MayDirect2019, MayIndirect2019, 
					JuneDirect2019, JuneIndirect2019, 
					JulyDirect2019, JulyIndirect2019, 
					AugustDirect2019, AugustIndirect2019, 
					SeptemberDirect2019, SeptemberIndirect2019, 
					OctoberDirect2019, OctoberIndirect2019,
					NovemberDirect2019, NovemberIndirect2019, 
					DecemberDirect2019, DecemberIndirect2019,
					-- 2020 Gross Adds
					JanuaryDirect2020, JanuaryIndirect2020,
					FebruaryDirect2020, FebruaryIndirect2020,
					MarchDirect2020, MarchIndirect2020, 
					AprilDirect2020, AprilIndirect2020, 
					MayDirect2020, MayIndirect2020, 
					JuneDirect2020, JuneIndirect2020, 
					JulyDirect2020, JulyIndirect2020, 
					AugustDirect2020, AugustIndirect2020, 
					SeptemberDirect2020, SeptemberIndirect2020, 
					OctoberDirect2020, OctoberIndirect2020,
					NovemberDirect2020, NovemberIndirect2020, 
					DecemberDirect2020, DecemberIndirect2020,
					-- 2021 Gross Adds
					JanuaryDirect2021, JanuaryIndirect2021,
					FebruaryDirect2021, FebruaryIndirect2021,
					MarchDirect2021, MarchIndirect2021, 
					AprilDirect2021, AprilIndirect2021, 
					MayDirect2021, MayIndirect2021, 
					JuneDirect2021, JuneIndirect2021, 
					JulyDirect2021, JulyIndirect2021, 
					AugustDirect2021, AugustIndirect2021, 
					SeptemberDirect2021, SeptemberIndirect2021, 
					OctoberDirect2021, OctoberIndirect2021,
					NovemberDirect2021, NovemberIndirect2021, 
					DecemberDirect2021, DecemberIndirect2021,
					-- 2022 Gross Adds
					JanuaryDirect2022, JanuaryIndirect2022,
					FebruaryDirect2022, FebruaryIndirect2022,
					MarchDirect2022, MarchIndirect2022, 
					AprilDirect2022, AprilIndirect2022, 
					MayDirect2022, MayIndirect2022, 
					JuneDirect2022, JuneIndirect2022, 
					JulyDirect2022, JulyIndirect2022, 
					AugustDirect2022, AugustIndirect2022, 
					SeptemberDirect2022, SeptemberIndirect2022, 
					OctoberDirect2022, OctoberIndirect2022,
					NovemberDirect2022, NovemberIndirect2022, 
					DecemberDirect2022, DecemberIndirect2022,
					-- 2023 Gross Adds
					JanuaryDirect2023, JanuaryIndirect2023,
					FebruaryDirect2023, FebruaryIndirect2023,
					MarchDirect2023, MarchIndirect2023, 
					AprilDirect2023, AprilIndirect2023, 
					MayDirect2023, MayIndirect2023, 
					JuneDirect2023, JuneIndirect2023, 
					JulyDirect2023, JulyIndirect2023, 
					AugustDirect2023, AugustIndirect2023, 
					SeptemberDirect2023, SeptemberIndirect2023, 
					OctoberDirect2023, OctoberIndirect2023,
					NovemberDirect2023, NovemberIndirect2023, 
					DecemberDirect2023, DecemberIndirect2023,
					-- 2024 Gross Adds
					JanuaryDirect2024, JanuaryIndirect2024,
					FebruaryDirect2024, FebruaryIndirect2024,
					MarchDirect2024, MarchIndirect2024, 
					AprilDirect2024, AprilIndirect2024, 
					MayDirect2024, MayIndirect2024, 
					JuneDirect2024, JuneIndirect2024, 
					JulyDirect2024, JulyIndirect2024, 
					AugustDirect2024, AugustIndirect2024, 
					SeptemberDirect2024, SeptemberIndirect2024, 
					OctoberDirect2024, OctoberIndirect2024,
					NovemberDirect2024, NovemberIndirect2024, 
					DecemberDirect2024, DecemberIndirect2024

			FROM forecast.SpendingTrendData
			WHERE SubprojectNumber IS NOT NULL AND BudgetCategory NOT LIKE 'Blanket%' AND 
				 NOT (ProjectStatusCode IN ('CL', 'CX') AND
				  JanuaryDirect2017 + JanuaryIndirect2017 +
				  FebruaryDirect2017 + FebruaryIndirect2017 +
				  MarchDirect2017 + MarchIndirect2017 +
				  AprilDirect2017 + AprilIndirect2017 +
				  MayDirect2017 + MayIndirect2017 +
				  JuneDirect2017 + JuneIndirect2017 +
				  JulyDirect2017 + JulyIndirect2017 +
				  AugustDirect2017 + AugustIndirect2017 +
				  SeptemberDirect2017 + SeptemberIndirect2017 +
				  OctoberDirect2017 + OctoberIndirect2017 +
				  NovemberDirect2017 + NovemberIndirect2017 +
				  DecemberDirect2017 + DecemberIndirect2017 +
				  JanuaryDirect2018 + JanuaryIndirect2018 +
				  FebruaryDirect2018 + FebruaryIndirect2018 +
				  MarchDirect2018 + MarchIndirect2018 +
				  AprilDirect2018 + AprilIndirect2018 +
				  MayDirect2018 + MayIndirect2018 +
				  JuneDirect2018 + JuneIndirect2018 +
				  JulyDirect2018 + JulyIndirect2018 +
				  AugustDirect2018 + AugustIndirect2018 +
				  SeptemberDirect2018 + SeptemberIndirect2018 +
				  OctoberDirect2018 + OctoberIndirect2018 +
				  NovemberDirect2018 + NovemberIndirect2018 +
				  DecemberDirect2018 + DecemberIndirect2018 +
				  JanuaryDirect2019 + JanuaryIndirect2019 +
				  FebruaryDirect2019 + FebruaryIndirect2019 +
				  MarchDirect2019 + MarchIndirect2019 +
				  AprilDirect2019 + AprilIndirect2019 +
				  MayDirect2019 + MayIndirect2019 +
				  JuneDirect2019 + JuneIndirect2019 +
				  JulyDirect2019 + JulyIndirect2019 +
				  AugustDirect2019 + AugustIndirect2019 +
				  SeptemberDirect2019 + SeptemberIndirect2019 +
				  OctoberDirect2019 + OctoberIndirect2019 +
				  NovemberDirect2019 + NovemberIndirect2019 +
				  DecemberDirect2019 + DecemberIndirect2019 +
				  JanuaryDirect2020 + JanuaryIndirect2020 +
				  FebruaryDirect2020 + FebruaryIndirect2020 +
				  MarchDirect2020 + MarchIndirect2020 +
				  AprilDirect2020 + AprilIndirect2020 +
				  MayDirect2020 + MayIndirect2020 +
				  JuneDirect2020 + JuneIndirect2020 +
				  JulyDirect2020 + JulyIndirect2020 +
				  AugustDirect2020 + AugustIndirect2020 +
				  SeptemberDirect2020 + SeptemberIndirect2020 +
				  OctoberDirect2020 + OctoberIndirect2020 +
				  NovemberDirect2020 + NovemberIndirect2020 +
				  DecemberDirect2020 + DecemberIndirect2020+
				  JanuaryDirect2021 + JanuaryIndirect2021 +
				  FebruaryDirect2021 + FebruaryIndirect2021 +
				  MarchDirect2021 + MarchIndirect2021 +
				  AprilDirect2021 + AprilIndirect2021 +
				  MayDirect2021 + MayIndirect2021 +
				  JuneDirect2021 + JuneIndirect2021 +
				  JulyDirect2021 + JulyIndirect2021 +
				  AugustDirect2021 + AugustIndirect2021 +
				  SeptemberDirect2021 + SeptemberIndirect2021 +
				  OctoberDirect2021 + OctoberIndirect2021 +
				  NovemberDirect2021 + NovemberIndirect2021 +
				  DecemberDirect2021 + DecemberIndirect2021+
				  JanuaryDirect2022 + JanuaryIndirect2022 +
				  FebruaryDirect2022 + FebruaryIndirect2022 +
				  MarchDirect2022 + MarchIndirect2022 +
				  AprilDirect2022 + AprilIndirect2022 +
				  MayDirect2022 + MayIndirect2022 +
				  JuneDirect2022 + JuneIndirect2022 +
				  JulyDirect2022 + JulyIndirect2022 +
				  AugustDirect2022 + AugustIndirect2022 +
				  SeptemberDirect2022 + SeptemberIndirect2022 +
				  OctoberDirect2022 + OctoberIndirect2022 +
				  NovemberDirect2022 + NovemberIndirect2022 +
				  DecemberDirect2022 + DecemberIndirect2022 +
				  JanuaryDirect2023 + JanuaryIndirect2023 +
				  FebruaryDirect2023 + FebruaryIndirect2023 +
				  MarchDirect2023 + MarchIndirect2023 +
				  AprilDirect2023 + AprilIndirect2023 +
				  MayDirect2023 + MayIndirect2023 +
				  JuneDirect2023 + JuneIndirect2023 +
				  JulyDirect2023 + JulyIndirect2023 +
				  AugustDirect2023 + AugustIndirect2023 +
				  SeptemberDirect2023 + SeptemberIndirect2023 +
				  OctoberDirect2023 + OctoberIndirect2023 +
				  NovemberDirect2023 + NovemberIndirect2023 +
				  DecemberDirect2023 + DecemberIndirect2023 +
				  JanuaryDirect2024 + JanuaryIndirect2024 +
				  FebruaryDirect2024 + FebruaryIndirect2024 +
				  MarchDirect2024 + MarchIndirect2024 +
				  AprilDirect2024 + AprilIndirect2024 +
				  MayDirect2024 + MayIndirect2024 +
				  JuneDirect2024 + JuneIndirect2024 +
				  JulyDirect2024 + JulyIndirect2024 +
				  AugustDirect2024 + AugustIndirect2024 +
				  SeptemberDirect2024 + SeptemberIndirect2024 +
				  OctoberDirect2024 + OctoberIndirect2024 +
				  NovemberDirect2024 + NovemberIndirect2024 +
				  DecemberDirect2024 + DecemberIndirect2024 = 0)
		) X
		--LEFT JOIN forecast.Project P ON X.ProjectNumber = P.ProjectNumber
		GROUP BY ProjectNumber--, BudgetCategory--, JustificationCode
		HAVING YEAR(MIN(ActualStartDate)) >= 2017 OR (MIN(ApprovalCode) = 'AP' AND MIN(ActualStartDate) IS NULL)
		ORDER BY ProjectNumber

		-- Update integration budget categories
		UPDATE forecast.SpendingTrend
		SET BudgetCategory = IIF(BudgetCategory NOT LIKE 'Integration%', BudgetCategory, IIF(BudgetCategory LIKE '%Core', 'Core Network', IIF(BudgetCategory LIKE '%Facilities', 'Facilities', IIF(BudgetCategory LIKE '%IT', 'IT', 'Inside Plant'))))


UPDATE T
SET T.EVENTEND=CAST(GETDATE() AS DATETIME)
FROM LOG.Tracker T
INNER JOIN LOG.Tracker_Temp_forecast__usp_UpdateSpendingTrend P
ON T.EVENTID = P.LATESTID
DROP TABLE IF EXISTS LOG.Tracker_Temp_forecast__usp_UpdateSpendingTrend


	commit transaction
end try
begin catch
	if @@trancount > 0 rollback transaction
	exec usp_error_handler
	return 55555
end catch