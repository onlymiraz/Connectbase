SELECT t1.name, t1.owning_principal_id, t2.name

FROM sys.server_principals AS t1

JOIN sys.server_principals AS t2

ON t1.owning_principal_id = t2.principal_id

WHERE t1.type = 'R';