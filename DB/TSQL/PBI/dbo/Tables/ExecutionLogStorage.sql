CREATE TABLE [dbo].[ExecutionLogStorage] (
    [LogEntryId]        BIGINT           IDENTITY (1, 1) NOT NULL,
    [InstanceName]      NVARCHAR (38)    NOT NULL,
    [ReportID]          UNIQUEIDENTIFIER NULL,
    [UserName]          NVARCHAR (260)   NULL,
    [ExecutionId]       NVARCHAR (64)    NULL,
    [RequestType]       TINYINT          NOT NULL,
    [Format]            NVARCHAR (26)    NULL,
    [Parameters]        NTEXT            NULL,
    [ReportAction]      TINYINT          NULL,
    [TimeStart]         DATETIME         NOT NULL,
    [TimeEnd]           DATETIME         NOT NULL,
    [TimeDataRetrieval] INT              NOT NULL,
    [TimeProcessing]    INT              NOT NULL,
    [TimeRendering]     INT              NOT NULL,
    [Source]            TINYINT          NOT NULL,
    [Status]            NVARCHAR (40)    NOT NULL,
    [ByteCount]         BIGINT           NOT NULL,
    [RowCount]          BIGINT           NOT NULL,
    [AdditionalInfo]    XML              NULL,
    PRIMARY KEY CLUSTERED ([LogEntryId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ExecutionLog]
    ON [dbo].[ExecutionLogStorage]([TimeStart] ASC, [LogEntryId] ASC);


GO

CREATE TRIGGER [dbo].[trg_SendEmailOnRefreshFailure]
ON [dbo].[ExecutionLogStorage]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Notify only for failed data refresh actions
    IF EXISTS (SELECT 1 FROM inserted WHERE ReportAction = 19 AND Status NOT LIKE 'rsSuccess')
    BEGIN
        DECLARE @subject NVARCHAR(255) = 'Power BI Refresh Failure Notification';
        DECLARE @body NVARCHAR(MAX) = 'A Power BI report refresh has failed. Details include:<br><br>';

        -- Collect and send email for every failed entry, formatted as HTML with bold keys and trimmed instance names
        ;WITH FailedEntries AS (
            SELECT DISTINCT
                i.ExecutionId,
                e.InstanceName,
                e.ItemPath,
                e.UserName,
                i.RequestType,
                i.TimeStart,
                i.TimeEnd,
                i.Status
            FROM inserted i
            INNER JOIN dbo.ExecutionLog3 e ON i.ExecutionId = e.ExecutionId
            WHERE i.ReportAction = 19 AND i.Status NOT LIKE 'rsSuccess'
        )
        SELECT @body = @body + 
                       '<b>Execution ID:</b> ' + CHAR(9) + CAST(f.ExecutionId AS NVARCHAR(128)) + '<br>' +
                       '<b>Instance Name:</b> ' + CHAR(9) + LTRIM(CAST(f.InstanceName AS NVARCHAR(255))) + '<br>' +
                       '<b>Full Item Path:</b> ' + CHAR(9) + CAST(f.ItemPath AS NVARCHAR(4000)) + '<br>' +
                       '<b>User Name:</b> ' + CHAR(9) + CAST(f.UserName AS NVARCHAR(255)) + '<br>' +
                       '<b>Request Type:</b> ' + CHAR(9) + CAST(f.RequestType AS NVARCHAR(50)) + '<br>' +
                       '<b>Time Start:</b> ' + CHAR(9) + CAST(f.TimeStart AS NVARCHAR(50)) + '<br>' +
                       '<b>Time End:</b> ' + CHAR(9) + CAST(f.TimeEnd AS NVARCHAR(50)) + '<br>' +
                       '<b>Status:</b> ' + CHAR(9) + CAST(f.Status AS NVARCHAR(50)) + '<br><br>'
        FROM FailedEntries f;

        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'WAD_PBI',  -- Use your configured email profile name
            @recipients = 'DL_WAD_Logs@ftr.com',  -- Use your recipient email
            @subject = @subject,
            @body = @body,
            @body_format = 'HTML';  -- Specify that the email body is in HTML format
    END
END;

GO
GRANT DELETE
    ON OBJECT::[dbo].[ExecutionLogStorage] TO [RSExecRole]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ExecutionLogStorage] TO [RSExecRole]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ExecutionLogStorage] TO [RSExecRole]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ExecutionLogStorage] TO [RSExecRole]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ExecutionLogStorage] TO [RSExecRole]
    AS [dbo];

