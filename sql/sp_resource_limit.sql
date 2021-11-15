
-- sp_resource_limit.sql
-- Jared Still 2017-08-25
-- jkstill@gmail.com
-- 


set linesize 200 trimspool on
set pagesize 100
set pause off echo off verify off
set head on term on 

col snap_time format a20
col min_sess_per_day format 99,999 head 'MIN|SESS|PER|DAY'
col max_sess_per_day format 99,999 head 'MAX|SESS|PER|DAY'
col avg_sess_per_day format 99,999 head 'AVG|SESS|PER|DAY'
col min_proc_per_day format 99,999 head 'MIN|PROC|PER|DAY'
col max_proc_per_day format 99,999 head 'MAX|PROC|PER|DAY'
col avg_proc_per_day format 99,999 head 'AVG|PROC|PER|DAY'

set feed off term off
alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';
set feed on term on

with processes as (
	select snap_id, CURRENT_UTILIZATION process_count
	from perfstat.STATS$RESOURCE_LIMIT
	where resource_name = 'processes'
),
sessions as (
	select snap_id, CURRENT_UTILIZATION session_count
	from perfstat.STATS$RESOURCE_LIMIT
	where resource_name = 'sessions'
)
select distinct
	sn.snap_time
	, min(s.session_count) over ( partition by trunc(sn.snap_time)) min_sess_per_day
	, max(s.session_count) over ( partition by trunc(sn.snap_time)) max_sess_per_day
	, round(avg(s.session_count) over ( partition by trunc(sn.snap_time)),1) avg_sess_per_day
	, min(p.process_count) over ( partition by trunc(sn.snap_time)) min_proc_per_day
	, max(p.process_count) over ( partition by trunc(sn.snap_time)) max_proc_per_day
	, round(avg(p.process_count) over ( partition by trunc(sn.snap_time)),1) avg_proc_per_day
from perfstat.STATS$snapshot sn
right outer join sessions s on s.snap_id = sn.snap_id
right outer join processes p on p.snap_id = sn.snap_id
order by sn.snap_time
/
