CREATE TABLE [dbo].[#A2230E21] (
    [job_id]                   UNIQUEIDENTIFIER NOT NULL,
    [date_created]             DATETIME         NOT NULL,
    [date_last_modified]       DATETIME         NOT NULL,
    [current_execution_status] INT              NULL,
    [current_execution_step]   NVARCHAR (MAX)   NULL,
    [current_retry_attempt]    INT              NULL,
    [last_run_date]            INT              NOT NULL,
    [last_run_time]            INT              NOT NULL,
    [last_run_outcome]         INT              NOT NULL,
    [next_run_date]            INT              NULL,
    [next_run_time]            INT              NULL,
    [next_run_schedule_id]     INT              NULL,
    [type]                     INT              NOT NULL
);

