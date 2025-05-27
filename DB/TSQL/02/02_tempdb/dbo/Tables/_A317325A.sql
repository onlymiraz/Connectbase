CREATE TABLE [dbo].[#A317325A] (
    [job_id]                UNIQUEIDENTIFIER NOT NULL,
    [last_run_date]         INT              NOT NULL,
    [last_run_time]         INT              NOT NULL,
    [next_run_date]         INT              NOT NULL,
    [next_run_time]         INT              NOT NULL,
    [next_run_schedule_id]  INT              NOT NULL,
    [requested_to_run]      INT              NOT NULL,
    [request_source]        INT              NOT NULL,
    [request_source_id]     [sysname]        NULL,
    [running]               INT              NOT NULL,
    [current_step]          INT              NOT NULL,
    [current_retry_attempt] INT              NOT NULL,
    [job_state]             INT              NOT NULL
);

