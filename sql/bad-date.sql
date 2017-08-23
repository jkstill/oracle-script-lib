
-- bad-date.sql
-- Is there a year 0?
-- Oracle thinks there is

alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

select 
	to_date('0001-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss') bd,
	to_date('0001-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')-365 bd365,
	to_date('0001-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss')-366 bd366
from dual
/

