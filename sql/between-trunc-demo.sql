
-- between-trunc-demo.sql
-- Jared Still
--  jkstill@gmail.com
--  2018
--
/*

Demonstrate methods for changing a 'trunc(date|timestamp) between date|timestamp and date|timestamp'
to something that can use an index if available

_bod = beginning of day
_eod = end of day

*/

set feed on term on head on
set linesize 80 trimspool on
set pagesize 100

alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

prompt ====================
prompt ==    Dates   ======
prompt ====================


prompt
prompt This will not use a standard index
prompt A function based index could be created for it, but why?
prompt Just write the SQL properly
prompt

select 
	sysdate
	, trunc(sysdate) trunc_sysdate
	, trunc(sysdate) + (86399/86400) sysdate_eod
	, trunc(sysdate) + 1 tomorrow
from dual
where TRUNC(sysdate) BETWEEN trunc(sysdate) AND trunc(sysdate)
/


prompt
prompt This will not return any rows
prompt

select
	sysdate
	, trunc(sysdate) sysdate_bod
	, trunc(sysdate) + (86399/86400) sysdate_eod
	, trunc(sysdate) + 1 tomorrow
from dual
where sysdate BETWEEN  trunc(sysdate) AND trunc(sysdate)
/


prompt
prompt This query will return a row as the Date range includes the entire day
prompt

select
	sysdate
	, trunc(sysdate) sysdate_bod
	, trunc(sysdate) + (86399/86400) sysdate_eod
	, trunc(sysdate) + 1 tomorrow
from dual
where sysdate BETWEEN trunc(sysdate) and trunc(sysdate) + (86399/86400)
/

prompt
prompt This query will also return a row
prompt The WHERE clause is more future proof as it works regardless of time component
prompt
prompt

select
	sysdate
	, trunc(sysdate) sysdate_bod
	, trunc(sysdate) + (86399/86400) sysdate_eod
	, trunc(sysdate) + 1 tomorrow
from dual
where ( sysdate >=  trunc(sysdate) and sysdate < trunc(sysdate) + 1)
/


prompt ====================
prompt == Timestamps ======
prompt ====================

alter session set nls_timestamp_format = 'YYYY-MM-DD HH24.MI.SSXFF9';
alter session set nls_timestamp_tz_format = 'YYYY-MM-DD HH24.MI.SSXFF9 TZR';

prompt
prompt Timestamp using BETWEEN
prompt


select  
	systimestamp
	, cast(trunc(systimestamp ,'DD') as timestamp) systimestamp_bod
	, (to_timestamp(trunc(systimestamp)) + interval '1' day - interval '0 00:00:00.000000001' day to second(9)) systimestamp_eod
	, (to_timestamp(trunc(systimestamp)) + interval '1' day ) tomorrow
from dual
where systimestamp between cast(trunc(systimestamp) as timestamp)
	and (to_timestamp(trunc(systimestamp)) + interval '1' day - interval '0 00:00:00.000000001' day to second(9))
/



prompt
prompt Timestamp using GE and LT 
prompt


select  
	systimestamp
	, cast(trunc(systimestamp ,'DD') as timestamp) systimestamp_bod
	, (to_timestamp(trunc(systimestamp)) + interval '1' day - interval '0 00:00:00.000000001' day to second(9)) systimestamp_eod
	, (to_timestamp(trunc(systimestamp)) + interval '1' day ) tomorrow
from dual
where 
	( 
		systimestamp >= cast(trunc(systimestamp) as timestamp) 
		and 
		systimestamp < (to_timestamp(trunc(systimestamp)) + interval '1' day )
	)
/


