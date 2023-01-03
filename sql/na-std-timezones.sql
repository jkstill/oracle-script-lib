
-- na-std-timezones.sql
-- the standard timezones in North America
-- Jared Still

clear breaks
set linesize 200 trimspool on
set pagesize 100

col tzname format a10
col tzabbrev format a10
col tzoffset format a7

break on tzname skip 1

select n.tzname
	, n.tzabbrev
	, tz_offset(n.tzname) tzoffset
from v$timezone_names n
where regexp_like(n.tzname,'[[:alpha:]]{1,}[[:digit:]][[:alpha:]]{1,}')
order by regexp_replace(n.tzname,'([[:alpha:]]{1,})([[:digit:]])([[:alpha:]]{1,})','\2'), tzabbrev
/
