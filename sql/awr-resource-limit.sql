
-- awr-resource-limit.sql
-- Jared Still 2017-08-25
-- jkstill@gmail.com
-- 


set linesize 200 trimspool on
set pagesize 100
set pause off echo off verify off
set head on term on 

col begin_interval_time format a30
col min_sess_per_day format 99,999 head 'MIN|SESS|PER|DAY'
col max_sess_per_day format 99,999 head 'MAX|SESS|PER|DAY'
col avg_sess_per_day format 99,999 head 'AVG|SESS|PER|DAY'
col min_proc_per_day format 99,999 head 'MIN|PROC|PER|DAY'
col max_proc_per_day format 99,999 head 'MAX|PROC|PER|DAY'
col avg_proc_per_day format 99,999 head 'AVG|PROC|PER|DAY'

with processes as (
	select snap_id, CURRENT_UTILIZATION process_count
	from dba_hist_RESOURCE_LIMIT
	where resource_name = 'processes'
),
sessions as (
	select snap_id, CURRENT_UTILIZATION session_count
	from dba_hist_RESOURCE_LIMIT
	where resource_name = 'sessions'
)
select distinct
	sn.begin_interval_time
	, min(s.session_count) over ( partition by trunc(sn.begin_interval_time)) min_sess_per_day
	, max(s.session_count) over ( partition by trunc(sn.begin_interval_time)) max_sess_per_day
	, round(avg(s.session_count) over ( partition by trunc(sn.begin_interval_time)),1) avg_sess_per_day
	, min(p.process_count) over ( partition by trunc(sn.begin_interval_time)) min_proc_per_day
	, max(p.process_count) over ( partition by trunc(sn.begin_interval_time)) max_proc_per_day
	, round(avg(p.process_count) over ( partition by trunc(sn.begin_interval_time)),1) avg_proc_per_day
from dba_hist_snapshot sn
right outer join sessions s on s.snap_id = sn.snap_id
right outer join processes p on p.snap_id = sn.snap_id
order by sn.begin_interval_time
/
