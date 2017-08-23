
-- timestamp-diff-seconds.sql
-- get the difference between 2 timestamps in seconds

with dates as (
	select systimestamp today, systimestamp -1.314159 yesterday from dual
)
select
	(extract( day from (today - yesterday) )*24*60*60)+
		(extract( hour from (today - yesterday) )*60*60)+
		(extract( minute from (today - yesterday) )*60)+
		(extract( second from (today - yesterday))) 
	duration_seconds
from dates
/

