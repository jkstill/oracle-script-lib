
-- awr-top-events.sql
-- get top 5 events per AWR snapshot, per instance
-- Jared Still  jkstill@gmail.com

-- requires https://github.com/jkstill/oracle-script-lib/blob/master/get_date_range.sql

-- prompt for date range
@get_date_range 

-- or just specify it here
--@get_date_range '2016-10-26 10:00:00' '2016-10-26 16:00:00'

break on begin_interval skip 1

with snaps as (
	select 
		min(snap_id) min_snap_id
		, max(snap_id) max_snap_id
	from dba_hist_snapshot
	where begin_interval_time >= to_date(:v_begin_date,'&d_date_format')
	and end_interval_time <= to_date(:v_end_date,'&d_date_format')
),
data as (
	select 
		h.snap_id
		, h.dbid
		, h.instance_number
		, case h.session_state
			when 'ON CPU' then 'CPU'
			else h.event
		end event
	from dba_hist_active_sess_history h
		and h.event != 'ges generic event' -- see MOS 2638401.1
),
agg_data as (
select  distinct
	to_char(hs.begin_interval_time,'&d_date_format') begin_interval
	, d.instance_number
	, d.event
	, count(d.event) over (partition by d.snap_id, d.event, d.instance_number) event_count
from data d
join dba_hist_snapshot hs on hs.snap_id = d.snap_id
	and hs.instance_number = d.instance_number
	and hs.dbid = d.dbid
	and hs.snap_id between (select min_snap_id from snaps)
		and (select max_snap_id from snaps)
--where rownum <= 200
order by begin_interval, event_count desc, instance_number
), 
rank_output as (
	select
		begin_interval
		, instance_number
		, event
		, event_count
		, row_number() over (partition by begin_interval, instance_number order by event_count desc)	 event_rank
	from agg_data
)
select 
		begin_interval
		, instance_number
		, event
		, event_count
from rank_output
where event_rank <= 5
order by begin_interval, event_count desc
/

