
SELECT to_date('01-JAN-1970','dd-mon-yyyy')+(1444173639/60/60/24) from dual;



SELECT DTE_CLOSEdDATETIME
FROM OS3.OS3_OP_REQUEST
WHERE FLD_REQUESTID = 'OP-000000368207'




select c1, C777031006,
 to_date('01-JAN-1970','dd-mon-yyyy')+(C777031010/60/60/24) create1,
 to_date('01-JAN-1970','dd-mon-yyyy')+(C777010106/60/60/24) clear1
from os3.T1074
where substr(C777031006,5,2) in ('FL','TX')
and to_char(to_date('01-JAN-1970','dd-mon-yyyy')+(C777031010/60/60/24),'yyyymm') = '201604'
;