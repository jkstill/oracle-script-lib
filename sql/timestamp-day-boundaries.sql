
-- timestamp-day-boundaries.sql
-- Jared Still  jkstill@gmail.com
--  2018
-- 
-- get the beginning and end of the current day as timestamp 
-- SQLPlus can manage 9 decimal places as of 12.2
-- PL/SQL however can only do 6 decimal places

prompt
prompt SQL Can do 9 decimal places
prompt

select
	cast(trunc(systimestamp) as timestamp) day_begin
	, cast(
		trunc(
			systimestamp 
			+ numtodsinterval('1','DAY')  
		) 
		as timestamp
	) 
	- numtodsinterval('.000000001','SECOND') 
	day_end
from dual
/

prompt
prompt PL/SQL Can do 6 decimal places
prompt
prompt This example looks at the boundaries for the previous day
prompt

set serveroutput on
declare
	i_days_back integer := 1;
	b timestamp;
	e timestamp;
begin
	b := cast(trunc(systimestamp) as timestamp) - numtodsinterval( i_days_back ,'DAY');
	e := 	cast(
				trunc(
					systimestamp
					+ numtodsinterval('1','DAY')
				)
				as timestamp
			)	- numtodsinterval( i_days_back ,'DAY')
				- numtodsinterval('.000001','SECOND');
	dbms_output.put_line('Begin: ' || to_char(b));
	dbms_output.put_line('  End: ' || to_char(e));
end;
/


