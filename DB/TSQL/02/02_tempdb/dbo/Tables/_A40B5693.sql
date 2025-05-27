CREATE TABLE [dbo].[#A40B5693] (
    [schedule_id]            INT              NOT NULL,
    [schedule_name]          [sysname]        NOT NULL,
    [enabled]                INT              NOT NULL,
    [freq_type]              INT              NOT NULL,
    [freq_interval]          INT              NOT NULL,
    [freq_subday_type]       INT              NOT NULL,
    [freq_subday_interval]   INT              NOT NULL,
    [freq_relative_interval] INT              NOT NULL,
    [freq_recurrence_factor] INT              NOT NULL,
    [active_start_date]      INT              NOT NULL,
    [active_end_date]        INT              NOT NULL,
    [active_start_time]      INT              NOT NULL,
    [active_end_time]        INT              NOT NULL,
    [date_created]           DATETIME         NOT NULL,
    [schedule_description]   NVARCHAR (4000)  NULL,
    [next_run_date]          INT              NOT NULL,
    [next_run_time]          INT              NOT NULL,
    [schedule_uid]           UNIQUEIDENTIFIER NOT NULL
);

