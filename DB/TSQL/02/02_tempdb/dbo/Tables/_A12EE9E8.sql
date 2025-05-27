CREATE TABLE [dbo].[#A12EE9E8] (
    [job_id]                  UNIQUEIDENTIFIER NOT NULL,
    [date_started]            INT              NOT NULL,
    [time_started]            INT              NOT NULL,
    [execution_job_status]    INT              NOT NULL,
    [execution_step_id]       INT              NULL,
    [execution_step_name]     [sysname]        NULL,
    [execution_retry_attempt] INT              NOT NULL,
    [next_run_date]           INT              NOT NULL,
    [next_run_time]           INT              NOT NULL,
    [next_run_schedule_id]    INT              NOT NULL
);

