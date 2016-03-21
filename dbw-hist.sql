-- dbw-hist.sql
-- this works properly only if there are multiple db writers

col end_interval_time format a30
col waitgraph format a50
col cpugraph format a50
col cw_ratio format a6	head 'C/W|RATIO'
set linesize 200 trimspool on
set pagesize 60

-- set the divisor to scale the output if needed
def divisor=10


with data as (
select distinct
	snap_id
	, sum(decode(session_state,'WAITING',1,0)) WAIT
	, sum(decode(session_state,'ON CPU',1,0)) CPU
from dba_hist_active_sess_history
where session_type = 'BACKGROUND'
	and program like '%(DBW_)'
group by grouping sets(snap_id)
having group_id() < 1
)
select
	s.snap_id, s.end_interval_time
	, round(d.cpu / (d.wait + d.cpu) * 100,0) 
		|| '/' || round(d.wait / (d.wait + d.cpu) * 100,0) cw_ratio
	, rpad('C',ceil(d.cpu/&&divisor),'C')	cpugraph
	, rpad('W',ceil(d.wait/&&divisor),'W') waitgraph
from data d
join dba_hist_snapshot s on s.snap_id = d.snap_id
order by d.snap_id
/
