-- get_bind_values.sql
-- 10g+

@@get_date_range

col username format a15
col sid format 9999

col datatype_string format a15 head 'DATA TYPE'
col child_nume format 999999 head 'CHILD|NUMBER'
col position format 999 head 'POS'
col name format a20
col data_type format a15
col value_string format a40
col value_anydata format a40
col bind_string format a40
col begin_interval_time format a25

set line 200


col u_sql_id new_value u_sql_id noprint

set term on feed on echo off pause off verify off
prompt Which SQL_ID? :

set term off feed off
select '&3' u_sql_id from dual;
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
),
awr_bind_data as (
	select
		hs.begin_interval_time
	, b.instance_number
		, b.position
		, b.name
		--, b.value_string
	, anydata.GETTYPENAME(b.value_anydata) data_type
		, case anydata.GETTYPENAME(b.value_anydata)
		when 'SYS.VARCHAR' then	 anydata.accessvarchar(b.value_anydata)
		when 'SYS.VARCHAR2' then anydata.accessvarchar2(b.value_anydata)
		when 'SYS.CHAR' then anydata.accesschar(b.value_anydata)
		when 'SYS.DATE' then to_char(anydata.accessdate(b.value_anydata),'yyyy-mm-dd hh24:mi:ss')
		when 'SYS.TIMESTAMP' then to_char(anydata.accesstimestamp(b.value_anydata),'yyyy-mm-dd hh24:mi:ss')
		when 'SYS.NUMBER' then to_char(anydata.accessnumber(b.value_anydata))
		end bind_string
	from DBA_HIST_SQLBIND b
	join dba_hist_snapshot hs on hs.snap_id = b.snap_id
		and hs.instance_number = b.instance_number
		and hs.dbid = b.dbid
		and hs.snap_id between (select min_snap_id from snaps)
			and (select max_snap_id from snaps)
		and b.sql_id = :v_sql_id
), 
v_bind_data as (
	select
		to_timestamp(b.last_captured) begin_interval_time
	, b.inst_id instance_number
		, b.position
		, b.name
		--, b.value_string
	, anydata.GETTYPENAME(b.value_anydata) data_type
		, case anydata.GETTYPENAME(b.value_anydata)
		when 'SYS.VARCHAR' then	 anydata.accessvarchar(b.value_anydata)
		when 'SYS.VARCHAR2' then anydata.accessvarchar2(b.value_anydata)
		when 'SYS.CHAR' then anydata.accesschar(b.value_anydata)
		when 'SYS.DATE' then to_char(anydata.accessdate(b.value_anydata),'yyyy-mm-dd hh24:mi:ss')
		when 'SYS.TIMESTAMP' then to_char(anydata.accesstimestamp(b.value_anydata),'yyyy-mm-dd hh24:mi:ss')
		when 'SYS.NUMBER' then to_char(anydata.accessnumber(b.value_anydata))
		end bind_string
	from gv$sql_bind_capture b
	where b.sql_id = :v_sql_id
),
all_binds as (
	select
		begin_interval_time
		, instance_number
		, position
		, name
		, data_type
		, bind_string
	from awr_bind_data
	union
	select
		begin_interval_time
		, instance_number
		, position
		, name
		, data_type
		, bind_string
	from v_bind_data
)
select 
	begin_interval_time
	, instance_number
	, max(data_type) data_type
	, position
	, max(name) name
	, max(bind_string) bind_string
from all_binds
group by begin_interval_time, instance_number, position
order by begin_interval_time,	 instance_number, position
/


undef 1
