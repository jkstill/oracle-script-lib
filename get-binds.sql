
-- get_bind_values.sql
-- 10g+

col username format a15
col sid format 9999

col datatype_string format a15 head 'DATA TYPE'
col child_nume format 999999 head 'CHILD|NUMBER'
col position format 999 head 'POS'
col name format a20
col value_string format a40
col value_anydata format a40

set line 200

@@get_date_range

col u_sql_id new_value u_sql_id noprint

set term on feed on echo off pause off verify off
prompt Which SQL_ID? :

set term off feed off
select '&1' u_sql_id from dual;
set term on feed on

var v_sql_id varchar2(30)
exec :v_sql_id := '&u_sql_id'

break on inst_id on child_address on child_number on plan_hash_value

with snaps as (
	select 
		min(snap_id) min_snap_id
		, max(snap_id) max_snap_id
	from dba_hist_snapshot
	where begin_interval_time >= to_date(:v_begin_date,'&d_date_format')
	and end_interval_time <= to_date(:v_end_date,'&d_date_format')
)
select
   hs.begin_interval_time
   , b.position
   , b.name
   , b.value_string
   , b.value_anydata
from DBA_HIST_SQLBIND b
join dba_hist_snapshot hs on hs.snap_id = b.snap_id
	and hs.instance_number = b.instance_number
	and hs.dbid = b.dbid
	and hs.snap_id between (select min_snap_id from snaps)
		and (select max_snap_id from snaps)
	and b.sql_id = :v_sql_id
order by hs.begin_interval_time,  b.position
/


undef 1

