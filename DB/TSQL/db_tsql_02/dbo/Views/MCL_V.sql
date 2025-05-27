CREATE VIEW [dbo].[MCL_V]
	AS SELECT * FROM dbo.TBL_MCL_HIST where UPLOAD_TS = (select max(UPLOAD_TS) from dbo.TBL_MCL_HIST)
