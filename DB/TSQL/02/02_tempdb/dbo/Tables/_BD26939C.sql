CREATE TABLE [dbo].[#BD26939C] (
    [account_name]      [sysname]     NOT NULL,
    [type]              NVARCHAR (10) NOT NULL,
    [privilege]         NVARCHAR (10) NOT NULL,
    [mapped_login_name] [sysname]     NOT NULL,
    [permission_path]   [sysname]     NULL,
    PRIMARY KEY CLUSTERED ([account_name] ASC)
);

