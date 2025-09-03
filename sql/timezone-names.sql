

-- timezone-names.sql
-- Jared Still

clear breaks

col tzoffset format a7
col tzname format a30
col tzabbrev format a15

with tznames as (
	select tzabbrev, tzname
		, tz_offset(tzname) tzoffset
	from v$timezone_names
	order by tzabbrev, tzname
)
select tz.tzabbrev, tz.tzname, tz.tzoffset
from tznames tz
--where tz.tzabbrev = 'PDT'
--where tzoffset = '-08:00'
order by 
	case substr(tz.tzoffset,1,1)
		when '-' then (substr(tz.tzoffset,2,2) * -60 ) + (substr(tz.tzoffset,5) * -1)
		when '+' then (substr(tz.tzoffset,2,2) * 60) + substr(tz.tzoffset,5)
	end
	, tz.tzabbrev
	, tz.tzname
/

