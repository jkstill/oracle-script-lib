
-- awr-top-sqlid-events.sql
-- get top 5 events per AWR snapshot, per sql_id
-- Jared Still  jkstill@gmail.com
--
-- 2016-11-02 jkstill - added enqueue decode

-- requires https://github.com/jkstill/oracle-script-lib/blob/master/get_date_range.sql

-- prompt for date range
@get_date_range

-- or just specify it here
--@get_date_range '2018-07-01 00:00:00' '2018-07-12 08:00:00'

@clears 

set linesize 200 trimspool on
set pagesize 60

col event format a30
col p1text format a20
col p1 format a25
col p2text format a20

spool aws-top-sqlid-event.log

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
		, h.p1text
		, CASE
			WHEN event like 'enq%' THEN
				'0x'||trim(to_char(h.p1, 'XXXXXXXXXXXXXXXX'))||': '||
				chr(bitand(h.p1, 4278190080)/16777216)||
				chr(bitand(h.p1,16711680)/65536)||
				' mode '||bitand(h.p1, power(2,14)-1)
			ELSE NULL 
		END AS p1
		, h.sql_id	
	from dba_hist_active_sess_history h
	where h.sql_id is not null
),
agg_data as (
select  distinct
	to_char(hs.begin_interval_time,'&d_date_format') begin_interval
	, d.instance_number
	, d.sql_id
	, d.event
	, d.p1text
	, d.p1
	, count(d.event) over (partition by d.snap_id, d.sql_id, d.event, d.instance_number) event_count
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
		, sql_id
		, event
		, p1text
		, p1
		, event_count
		, row_number() over (partition by begin_interval, instance_number order by event_count desc)	 event_rank
	from agg_data
)
select 
		begin_interval
		, instance_number
		, sql_id
		, event
		, p1text
		, p1
		, event_count
		, event_rank
from rank_output
where event_rank <= 5
order by begin_interval, event_count desc
/

spool off

ed aws-top-sqlid-event.log
