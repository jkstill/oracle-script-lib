
-- awr-top-events.sql
-- get top 5 events per AWR snapshot, per instance
-- Jared Still  jkstill@gmail.com

-- requires https://github.com/jkstill/oracle-script-lib/blob/master/get_date_range.sql

-- prompt for date range
--@get_date_range 

set verify off
-- or just specify it here
@get_date_range '2017-01-07 00:00:00' '2017-01-07 23:59:59'


set linesize 200 trimspool on
set pagesize 100 

clear break

col begin_interval_time noprint

col p1text format a20
col p2text format a20
col p3text format a20

spool rid.log

with snaps as (
	select snap_id, instance_number, dbid
	from dba_hist_snapshot
	where begin_interval_time >= to_date(:v_begin_date,'&d_date_format')
	and end_interval_time <= to_date(:v_end_date,'&d_date_format')
)
select  distinct
	d.sql_id
	, to_char(p1,'0XXXXXXX') p1
	, p1text
	, to_char(p2,'0XXXXXXX') p2
	, p2text
	, to_char(p3,'0XXXXXXX') p3
	, p3text
	, CURRENT_OBJ#
	, current_block#
	, count(*) over (partition by d.sql_id, p1, p1text, p2, p2text, p3, p3text,current_obj#) block_count
from dba_hist_active_sess_history d
join dba_hist_event_name n on n.event_id = d.event_id
	and n.event_name = 'enq: TX - row lock contention'
join snaps hs on hs.snap_id = d.snap_id
	and hs.instance_number = d.instance_number
	and hs.dbid = d.dbid
order by 1,2,3
/

spool off

ed rid.log


