

-- timezone-names.sql
-- Jared Still

clear breaks

col tzoffset format a7
col tzname format a30
col tzabbrev format a15

with tznames as (
	select distinct tzabbrev
		, tz_offset(tzname) tzoffset
	from v$timezone_names
	order by tzabbrev
)
select tz.tzabbrev, tz.tzoffset
from tznames tz
--where tz.tzabbrev = 'PDT'
--where tzoffset = '-08:00'
/

