
-- timestamp-diff-seconds-inline-function.sql
-- get the difference between 2 timestamps in seconds using inline function
-- Jared Still 2024

set term off

col today format a30
col yesterday format a30
@nls_time_format

set term on

with
function timestamp_diff_seconds( begin_timestamp timestamp, end_timestamp timestamp ) 
return number is
	i_diff_interval interval day(9) to second(6);
begin
	i_diff_interval := end_timestamp - begin_timestamp;
	return 
		(extract( day from i_diff_interval )*86400)+
		(extract( hour from i_diff_interval )*3600)+
		(extract( minute from i_diff_interval )*60)+
		(extract( second from i_diff_interval));
end;
dates as (
	select systimestamp today, cast(systimestamp -3.14159 as timestamp with time zone) yesterday from dual
)
select 
	today, 
	yesterday, 
	timestamp_diff_seconds( yesterday, today ) as seconds_diff
from dates
/


