
-- rowlock-sqlid-hist.sql
-- CSV output counts of rowlock enq per sqlid
-- like rowlock-sqlid-counts.sql, but does full outer join on dba_hist
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

spool rowlock-sqlid-hist.csv

prompt timestamp,instance,sql_id,count

select  distinct hs.begin_interval_time,
	to_char(hs.begin_interval_time,'&d_date_format')
	|| ',' || nvl(d.instance_number,1)
	|| ',' || d.sql_id
	|| ',' || count(d.event) over (partition by d.snap_id, d.instance_number, d.sql_id)
from dba_hist_active_sess_history d
join dba_hist_event_name n on n.event_id = d.event_id
	and n.event_name = 'enq: TX - row lock contention'
full outer join dba_hist_snapshot hs on hs.snap_id = d.snap_id
	and hs.instance_number = d.instance_number
	and hs.dbid = d.dbid
where hs.begin_interval_time between
	to_date(:v_begin_date,'&d_date_format')
	and to_date(:v_end_date,'&d_date_format')
order by hs.begin_interval_time
/

spool off

ed rowlock-sqlid-hist.csv

@clears

