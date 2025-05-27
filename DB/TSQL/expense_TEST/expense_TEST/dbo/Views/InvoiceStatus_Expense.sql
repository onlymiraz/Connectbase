create view InvoiceStatus_Expense as
SELECT distinct GAVEND,GAINV#,GAVOUC,sum(cast(GALIN$ as float)) buks_LIN,sum(cast(GARPT$ as float)) buks_RPT
  FROM [ExpenseForecast].[Raw_PJExpense]
  --where GAVOUC='03720220502070'
  --where GAPRJ#='2472867'
  --where GAINV#='0190000062472867'
  group by GAVEND,GAINV#,GAVOUC