
set pagesize 100
set linesize 200 trimspool on

col ts_mb format 9,999,999
col max_mb format 9,999,999
col used_mb format 9,999,999


with tsdata as (
   select 
		t.tablespace_name 
      , s.snap_id
		, s.instance_number
      , sum(h.tablespace_usedsize * t.block_size/1024/1024) used_mb
      -- date is text and stored in this format: 'MM/DD/YYYY HH24:MI:SS'
      --, trunc(to_date(h.rtime, 'MM/DD/YYYY HH24:MI:SS'),'MM') resize_time
   from dba_hist_tbspc_space_usage     h
      , dba_hist_snapshot              s
      , dba_tablespaces                t
      , v$tablespace ts
		, v$instance i
   where h.snap_id = s.snap_id
      and ts.ts# = h.tablespace_id
      and t.tablespace_name = ts.name
		and i.instance_number = s.instance_number
   group by t.tablespace_name, s.instance_number, s.snap_id
   order by t.tablespace_name, s.snap_id
),
daily_data as (
	select  distinct
		t.tablespace_name
		, t.used_mb
		, trunc(s.begin_interval_time,'MM') start_time
	from tsdata t
	join dba_hist_snapshot s on s.snap_id = t.snap_id
		and s.instance_number = t.instance_number
)
select 
	d.start_time
	, max(d.used_mb) used_mb
from daily_data d
group by d.start_time
order by d.start_time
/


