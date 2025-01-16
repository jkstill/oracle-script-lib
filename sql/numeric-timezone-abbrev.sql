
-- numeric-timezone-abbreviations.sql
-- Jared Still


clear breaks
set linesize 200 trimspool on
set pagesize 100

col tzabbrev format a8
col tzname format a30
col tzoffzet format a7

with tztimes as (
	select n.tzabbrev, n.tzname
		, tz_offset(n.tzname) tzoffset
	from v$timezone_names n
	where regexp_like(n.tzabbrev,'^[+-].*')
	--order by tzabbrev+0
	order by case substr(n.tzabbrev,1,1)
		when '-' then substr(n.tzabbrev,2) * -1
		when '+' then substr(n.tzabbrev,2) * 1
	end
)
select tz.tzabbrev, tz.tzname, tz.tzoffset
from tztimes tz
--where tz.tzoffset = '-04:00'
/

