
create procedure report.usp_Get2020CapitalSummaryData
as
	set statistics io, time on;
	set nocount on;
begin try
	begin transaction
	select GAMTSK 'Prime', GASTSK 'Sub', GAMTRX 'Cost Code', GAJTCD 'Just Code', SUM(GARPT$) 'Spent $', GAACTY 'Year', GAACTP 'Month',
				Category 'Category', Title 'Title', [STATE] 'State', c.dir_indir 'Direct/Indirect', CONCAT(Title, ' ', c.dir_indir) 'Title Lookup',
				GAPRJ# 'Proj #', GAPRJS 'Sub #', GAFUNC 'Func Group', GA.GAREF 'GA Link Code'
				, A.LinkCode 'Link Code 1', A.LinkCodeFrom 'Link Code 2'
	from (select P.ProjectNumber, 
				CAT.Category,
				CRI.CriteriaID, CRI.Title, CRI.InJustificationCode, CRI.InState, CRI.BudgetCategoryID, CRI.SubBudgetCategoryID, CRI.LinkCode, CRI.InFunctionalGroup,
				JC.JustificationCode, 
				ACC.AccountLike, ACC.Prime1, ACC.Sub1, ACC.Prime2, ACC.Sub2,
				LC.LinkCodeFrom
		from report.CapitalSummary2020Criteria CRI
			left join report.CapitalSummary2020Category CAT on CAT.CategoryID = CRI.CategoryID
			left join report.CapitalSummary2020InJustificationCode JC on JC.ID = CRI.InJustificationCodeID
			left join report.CapitalSummary2020InAccount ACC on ACC.AccountID = CRI.InAccountID
			left join report.CapitalSummary2020LinkCodeMap LC ON LC.LinkCodeTo = CRI.LinkCode
			left join forecast.Project P on P.BudgetCategoryID = CRI.BudgetCategoryID and P.SubBudgetCategoryID = CRI.SubBudgetCategoryID
		where CRI.BudgetCategoryID is not null and ((CriteriaID < 66 or CriteriaID > 88) and CriteriaID not in (90, 91, 92))
		union
		select null,
				CAT.Category,
				CRI.CriteriaID, CRI.Title, CRI.InJustificationCode, CRI.InState, CRI.BudgetCategoryID, CRI.SubBudgetCategoryID, CRI.LinkCode, CRI.InFunctionalGroup,
				JC.JustificationCode, 
				ACC.AccountLike, ACC.Prime1, ACC.Sub1, ACC.Prime2, ACC.Sub2,
				LC.LinkCodeFrom
		from report.CapitalSummary2020Criteria CRI
			left join report.CapitalSummary2020Category CAT on CAT.CategoryID = CRI.CategoryID
			left join report.CapitalSummary2020InJustificationCode JC on JC.ID = CRI.InJustificationCodeID
			left join report.CapitalSummary2020InAccount ACC on ACC.AccountID = CRI.InAccountID
			left join report.CapitalSummary2020LinkCodeMap LC ON LC.LinkCodeTo = CRI.LinkCode
		where CRI.BudgetCategoryID is null and (CriteriaID < 66 or CriteriaID > 88) and CriteriaID not in (90, 91, 92)) A
	right join report.GA2019 GA on (A.ProjectNumber is null or A.ProjectNumber = GA.GAPRJ#)
		and ((A.InJustificationCode is not null and GA.GAJTCD = A.InJustificationCode)
				or (A.JustificationCode is not null and GA.GAJTCD = A.JustificationCode))
		and (A.InState is null or A.InState like CONCAT('%|',GA.[STATE],'|%'))
		and (A.LinkCode is null or ((A.LinkCodeFrom is null and GA.GAREF = A.LinkCode) or (A.LinkCodeFrom is not null and GA.GAREF = A.LinkCodeFrom)))
		and (A.InFunctionalGroup is null or A.InFunctionalGroup like CONCAT('%|',GA.GAFUNC,'|%'))
		and (A.AccountLike is null
			or (A.AccountLike = 1 and ((A.Prime1 is not null and A.Sub1 is not null and (GA.GAMTSK like A.Prime1 and RIGHT('000' + CONVERT(varchar(3), GA.GASTSK), 3) like A.Sub1))
				or (A.Prime2 is not null and A.Sub2 is not null and (GA.GAMTSK like A.Prime2 and RIGHT('000' + CONVERT(varchar(3), GA.GASTSK), 3) like A.Sub2))))
			or (A.AccountLike = 0 and not ((A.Prime1 is not null and A.Sub1 is not null and (GA.GAMTSK like A.Prime1 and RIGHT('000' + CONVERT(varchar(3), GA.GASTSK), 3) like A.Sub1))
				or (A.Prime2 is not null and A.Sub2 is not null and (GA.GAMTSK like A.Prime2 and RIGHT('000' + CONVERT(varchar(3), GA.GASTSK), 3) like A.Sub2)))))
	cross apply (select IIF(LEFT(GAMTRX, 1) <> 9, 'Direct', 'Indirect') 'dir_indir') c
	where GAPRJS in (1,4) and GAACTP < 10
	group by GAMTSK, GASTSK, GAMTRX, GAJTCD, GAACTY, GAACTP, Category, Title, [STATE], c.dir_indir
		, GAPRJ#, GAPRJS, GAFUNC, GAREF, A.LinkCode, A.LinkCodeFrom
	commit transaction
end try
begin catch
	exec dbo.usp_error_handler
	return 55555
end catch
