
-- sql-exe-times-awr.sql
-- call with sql_id
-- Jared Still - Pythian - still@pythian.com jkstill@gmail.com
-- 2017-11-21


@clears

col u_sql_id new_value u_sql_id noprint
var v_sql_id varchar2(13) 

col total_seconds format 999,999,999,999
col avg_seconds format 99,990.09
col med_seconds format 99,990.09
col executions format 99,999,999,999
col histogram format a100


set linesize 200 trimspool on
set pagesize 100

prompt
prompt SQL_ID: 
prompt

set term off feed off verify off

select '&1' u_sql_id from dual;

set term on feed on

def stats=''
def histo='--'

exec :v_sql_id := '&u_sql_id'

prompt
prompt Remember: AWR is sampled from ASH only every 10 seconds
prompt

with sql_seconds as (
	-- do NOT use distinct here
	select sql_id
		, count(sql_id) over (partition by session_id, session_serial#, sql_exec_id ) seconds
	from dba_hist_active_sess_history h
	join dba_hist_snapshot s on s.snap_id = h.snap_id
		and s.dbid = h.dbid
		and s.instance_number = h.instance_number
	where s.begin_interval_time >= systimestamp - interval '30' day
		and h.sql_id = :v_sql_id
),
stats as (
	select distinct sql_id
		, count(sql_id) over () executions
		, min(seconds) over () min_seconds
		, avg(seconds) over () avg_seconds
		, median(seconds) over () med_seconds
		, max(seconds) over () max_seconds
		, sum(seconds) over () total_seconds
	from sql_seconds
),
histo_data as (
	select sql_id
		, rpad('*',seconds,'*') histogram
		, seconds
	from sql_seconds
), 
histogram as (
select
	count(*) exe_count
	, seconds
	, histogram
from histo_data
group by histogram, seconds
order by 1
)
&stats select sql_id, executions, min_seconds, avg_seconds, med_seconds, total_seconds
&stats from stats
&histo select
	&histo exe_count
	&histo , seconds
	&histo , histogram
&histo from histogram
/


def stats='--'
def histo=''

/

