
-- awr-top-5-events.sql
-- Jared Still - jkstill@gmail.com 
-- report on the top 5 events (including CPU - excluding idle)
-- just to see where db is spending time
-- output to CSV
-- similar to awr-top-events.sql

define days_back=7
define snap_seconds=3600

--@clears
--set linesize 200 trimspool on
--set pagesize 100

alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

@clear_for_spool

spool awr-top-5-events.csv

with cores as (
	select inst_id, stat_name, value core_count
	-- assumes core count has not changed over time
	-- otherwise use DBA_HIST_OSSTAT
	from gv$osstat
	where stat_name = 'NUM_CPU_CORES'
), 
data as (
	select 
		sh.instance_number
		, trunc(sh.sample_Time,'hh24') sample_time
		, case sh.session_state
			when 'WAITING' then sh.event
			when 'ON CPU' then 'CPU'
			else 'UNKNOWN'
			end time_source
		, cpu.core_count
		, cpu.core_count * &snap_seconds db_seconds_available
		--, count(time_source) over (partition by sh.instance_number, sh.sample_time ) time_used
	from dba_hist_active_sess_history sh
	join cores cpu on cpu.inst_id = sh.instance_number
	where	 
		sample_time > systimestamp - numtodsinterval('&days_back','DAY')
		and
		(
			( sh.session_state = 'WAITING' and sh.wait_class not in ('Idle') )
			or sh.session_state = 'ON CPU' 
	)
	--and rownum < 10000
),
aggs as	(
	select distinct
		instance_number
			, sample_time
			, time_source
			, count(time_source) over (partition by instance_number, sample_time, time_source  order by instance_number, sample_time ) time_used
			--, count(time_source) time_used
			, db_seconds_available
	from data
	--group by instance_number, sample_time, time_source
	order by instance_number, sample_time, time_used desc
),
ranked as (
	select
		instance_number
		, sample_time
		, time_source
		-- times 10 due to 10 second AWR samples
		, time_used * 10 time_used
		, (time_used  * 10 ) / db_seconds_available * 100 pct_time
		, row_number() over (partition by instance_number, sample_time order by time_used desc)  event_rank
	from aggs
)
select 
	--instance_number
	--, sample_time
	--, time_source
	--, time_used
	--, to_char(pct_time,'990.9') pct_time
	--, event_rank
	--
	instance_number
	|| ',' || sample_time
	|| ',' || time_source
	|| ',' || time_used
	|| ',' || to_number(to_char(pct_time,'990.9'))
	|| ',' || event_rank
from ranked
where event_rank <= 5
--order by instance_number, sample_time, event_rank 
order by 1

prompt instance_number,sample_time,time_source,time_used,pct_time,event_rank

/

spool off 

@clears

