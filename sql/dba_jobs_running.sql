
@clears
@columns

col job format 99999
col log_user format a10
col priv_user format a10
col schema_user format a10

col what format a20
col interval format a20

set line 200
set pages 60

break on username skip 1

select 
	s.username, 
	jr.sid,
	jr.job,
	jr.failures,
	jr.last_date,
	jr.this_date,
	dj.next_date
from dba_jobs_running jr, v$session s, dba_jobs dj
where jr.sid = s.sid
and jr.job = dj.job
order by username, job
/



