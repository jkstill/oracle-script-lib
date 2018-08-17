
-- sess_longops.sql
-- 2005/08/25
-- jkstill@gmail.com

@clears
set line 200
set pagesize 100

col pctdone format a7
col opname format a20
col sofar format 99999999
col totalwork format 9999999999999
col target format a20
col target_desc format a10
col username format a10
col units format a10
col time_remaining format a10 head 'TIME|REMAIN|MINUTES'
col start_time format a22 head 'START TIME'
col message format a25

select 
	-- sid
	username
	, opname
	, target
	--, target_desc
	, sofar
	, totalwork
	, to_char((sofar / totalwork) * 100,'90.0')||'%' pctdone
	, units
	, substr('00'||to_char(trunc(time_remaining/60)),-2,2) 
		|| ':' 
		|| substr('00'||to_char(mod(time_remaining,60)),-2,2)
		time_remaining
	, start_time
	--, sysdate 
	--, last_update_time
	--, time_remaining
	--, elapsed_seconds
	--, context
	, message
	--, sql_address
	--, sql_hash_value
	--, qcsid
from v$session_longops
where time_remaining > 0
order by username
/
