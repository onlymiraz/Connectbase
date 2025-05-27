CREATE TABLE [forecast].[Subproject] (
    [ProjectNumber]               INT           NOT NULL,
    [SubprojectNumber]            SMALLINT      NOT NULL,
    [BudgetLineNumber]            INT           NULL,
    [ProjectStatusCodeID]         INT           NULL,
    [ProjectStatusCode]           CHAR (2)      NULL,
    [ApprovalDate]                DATE          NULL,
    [EstimatedStartDate]          DATE          NULL,
    [EstimatedCompleteDate]       DATE          NULL,
    [ActualStartDate]             DATE          NULL,
    [ReadyForServiceDate]         DATE          NULL,
    [TentativeCloseDate]          DATE          NULL,
    [CloseDate]                   DATE          NULL,
    [SubprojectStatusID]          INT           NULL,
    [SubprojectStatus]            VARCHAR (50)  NULL,
    [VarassetStatus]              VARCHAR (100) NULL,
    [VarassetStatusModifiedDate]  DATE          NULL,
    [VarassetClosingIssue]        VARCHAR (100) NULL,
    [VarassetScheduledFinishDate] DATE          NULL,
    [VarassetWorkOrderStatus]     VARCHAR (50)  NULL,
    [CarryIn]                     BIT           NULL,
    [ProjectYear]                 INT           NULL,
    [SentToClosing]               VARCHAR (25)  NULL,
    [ModifiedBy]                  VARCHAR (10)  NULL,
    [ModifiedDate]                DATETIME      NULL,
    CONSTRAINT [PK_Subproject] PRIMARY KEY CLUSTERED ([ProjectNumber] ASC, [SubprojectNumber] ASC) WITH (PAD_INDEX = ON),
    CONSTRAINT [FK_Subproject_Project] FOREIGN KEY ([ProjectNumber]) REFERENCES [forecast].[Project] ([ProjectNumber])
);


GO
CREATE trigger [forecast].[tgr_SubprojectInsert]
on forecast.Subproject after insert
as
	SET XACT_ABORT, NOCOUNT ON
begin
	INSERT INTO forecast.SubprojectAuthorized (ProjectNumber, SubprojectNumber, Direct, Indirect)
	SELECT ProjectNumber, SubprojectNumber, 0.0, 0.0 FROM inserted
	
	INSERT INTO forecast.SubprojectCIAC (ProjectNumber, SubprojectNumber, Budget, Spend)
	SELECT ProjectNumber, SubprojectNumber, 0.0, 0.0 FROM inserted
	
	INSERT INTO forecast.SubprojectFinancial (ProjectNumber, SubprojectNumber, SpendingNotNeeded, AdditionalDollarsNeeded)
	SELECT ProjectNumber, SubprojectNumber, 0.0, 0.0 FROM inserted
	
	INSERT INTO forecast.SubprojectFutureYear (ProjectNumber, SubprojectNumber, SpendInfinium, Spend)
	SELECT ProjectNumber, SubprojectNumber, 0.0, 0.0 FROM inserted
	
	INSERT INTO forecast.SubprojectPriorYear (ProjectNumber, SubprojectNumber, Spend)
	SELECT ProjectNumber, SubprojectNumber, 0.0 FROM inserted

	INSERT INTO forecast.GrossAddsDirect (ProjectNumber, SubprojectNumber, [Year], January, February, March, April, May, July, August, September, October, November, December)
	SELECT ProjectNumber, SubprojectNumber, YEAR(GETDATE()), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 FROM inserted
	
	INSERT INTO forecast.GrossAddsIndirect (ProjectNumber, SubprojectNumber, [Year], January, February, March, April, May, July, August, September, October, November, December)
	SELECT ProjectNumber, SubprojectNumber, YEAR(GETDATE()), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 FROM inserted
end