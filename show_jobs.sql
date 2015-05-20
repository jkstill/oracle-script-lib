
@clears
@columns

set array 1

col job format 99999
col log_user format a15
col priv_user format a15
col schema_user format a15

col what format a20
col interval format a20
col failures format 999 head 'FAIL|URES'

col which_job_view new_value which_job_view noprint

prompt "Which jobs view? [DBA|ALL]"
set term off feed off
select '&1' which_job_view from dual;
set term on feed on

set line 200
set pages 60

break on schema_user skip 1

select
 schema_user,
 priv_user,
 log_user,
 job,
 last_date,
 --last_sec,
 --this_date,
 --this_sec,
 next_date,
 --next_sec,
 total_time,
 broken,
 interval,
 failures,
 what
 --current_session_label,
 --clearance_hi,
 --clearance_lo,
 --nls_env,
 --misc_env
from &which_job_view._jobs
order by schema_user, next_date
/

undef 1

