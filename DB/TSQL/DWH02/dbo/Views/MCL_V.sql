CREATE VIEW [dbo].[MCL_V]
	AS SELECT * FROM dbo.TBL_MCL_HIST where update_dt = (select max(update_dt) from dbo.TBL_MCL_HIST)