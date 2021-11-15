
-- rowlock-sqlid-counts.sql 
-- 
-- Jared Still  jkstill@gmail.com

-- requires https://github.com/jkstill/oracle-script-lib/blob/master/get_date_range.sql

-- prompt for date range
--@get_date_range 

set verify off
-- or just specify it here
@get_date_range '2016-09-19 00:00:00' '2016-12-30 16:00:00'


set linesize 200 trimspool on
set pagesize 100 

clear break

@clear_for_spool

col begin_interval_time noprint

spool rowlock-sqlid-counts.csv

prompt instance,sql_id,count

with snaps as (
	select snap_id, instance_number, dbid
	from dba_hist_snapshot
	where begin_interval_time >= to_date(:v_begin_date,'&d_date_format')
	and end_interval_time <= to_date(:v_end_date,'&d_date_format')
)
select  distinct
	nvl(d.instance_number,1)
	|| ',' || d.sql_id
	|| ',' || count(*) over (partition by d.instance_number, d.sql_id)
from dba_hist_active_sess_history d
join dba_hist_event_name n on n.event_id = d.event_id
	and n.event_name = 'enq: TX - row lock contention'
join snaps hs on hs.snap_id = d.snap_id
	and hs.instance_number = d.instance_number
	and hs.dbid = d.dbid
/

spool off

ed rowlock-sqlid-counts.csv

@clears

