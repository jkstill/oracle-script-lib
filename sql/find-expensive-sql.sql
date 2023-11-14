
-- find-expensive-sql.sql
-- Jared Still 2023

/*


Search AWR for expensive SQL statements

Here, 'expensive' is being defined as a high value for LIO / rows_processed

That is a simplifications.

If the rows returned is < than the number of executions for any SQL during an AWR snapshot,
then the number of rows returned will be == to the number of executions

Some SQL are lookups that may be expected to return 0 rows.

When this is run, a log file find-expensive-sql.log is created.

The script opens this file with an editor once the SQL is complete

*/


-- this script does not take into account 'Direct Path Reads'

-- this value controls the minimum number of executions per AWR snapshot
-- that is considered as expensive
--
-- if not here, the most expensive SQL will frequently be
-- SQL that is rarely executed, and may be ad hoc
-- we are interested in frequently executed SQL that performs poorly

set verify off tab off

def n_min_sql_executions=50

-- look back how many days in AWR?
def n_awr_days_back=7

set linesize 300 trimspool on
set pagesize 100

col sql_id format a13 head 'SQL ID'
col end_interval_time format a19 head 'End Interval Time'
col snap_id format 99999999 head 'Snap ID'

col executions format 999,999,990 head 'Executions'
col fetches format 999,999,990 head 'Fetches'
col buffer_gets format 99,999,999,990 head 'Buffer Gets'
col rows_processed format 999,999,990 head  'Rows Procesed'
col disk_reads format 999,999,990 head 'Disk Reads'
col plan_hash_value format 9999999999 head 'Plan|Hash Value'
col rows_per_exe format 99,999,990.9990 head 'Rows:Exe|Ratio'
col rows_per_lio format 99,999,999,990.9990 head 'Rows:LIO|Ratio'
col lios_per_row format 99,999,999,990 head 'LIOs:Row|Ratio'
col command_name format a6 head 'CMD'
col elapsed_time format 99,999,990.90 head 'Elapsed|Time'
col avg_elapsed_time format 99,990.999990 head 'Average|Elapsed|Time'
col objects format a50 wrapped
col instance_number format 9999 head 'INST|NUM'
col con_id format 999 head 'CON|ID'
col con_dbid format 99999999999 head 'CON DBID'
col dbid format 99999999999 head ' DBID'
col sql_length format 999999 head 'SQL Text|Length'
col sql_rank format 99999 head 'SQL|Rank'

clear break
--break on sql_id skip 1 on plan_hash_value

set term off

spool find-expensive-sql.log

with
function get_objects (sql_id_in varchar2, plan_hash_value_in number) return varchar2
as
	c_objects clob;
	v_objects varchar2(4000);
begin

	for objrec in (
		select object_name
		from dba_hist_sql_plan
		where sql_id = sql_id_in
			and plan_hash_value = plan_hash_value_in
			and object_name is not null
	)
	loop
		c_objects := c_objects || ' ' || objrec.object_name;
	end loop;

	-- start at position 2 as pos 1 is a space
	--v_objects := substr(c_objects,2,4000);
	v_objects := dbms_lob.substr(c_objects,4000,2);

	return v_objects;
end;
raw_data as (
	select
		st.sql_id
		, to_char( cast (s.end_interval_time as date), 'yyyy-mm-dd hh24:mi:ss') end_interval_time
		, st.plan_hash_value
		--, s.snap_id
		, st.executions_delta executions
		, st.fetches_delta fetches
		, st.buffer_gets_delta buffer_gets
		/*
		  if rows processed is 0, and there are executions, then likely this is a SQL
		  that is expected to return 0 rows
		  ie. "does this account already exist?"
		  so count each execution as a row when nothing retutned
		*/
		--, st.rows_processed_delta rows_processed
		, case
		when st.rows_processed_delta < st.executions_delta then st.executions_delta
		else st.rows_processed_delta
		end rows_processed
		, st.disk_reads_delta disk_reads
		, st.elapsed_time_delta / power(10,6) elapsed_time
		, st.instance_number
		, st.dbid
		, st.con_id
		, st.con_dbid
	from dba_hist_sqlstat st
	join dba_hist_snapshot s
		on s.snap_id = st.snap_id
		and s.dbid = st.dbid
		and s.con_id = st.con_id
		and s.instance_number = st.instance_number
		and s.end_interval_time	 >= systimestamp - numtodsinterval(&n_awr_days_back,'DAY')
		and st.sql_id is not null
		and st.parsing_user_id != 0
),
rpt_data as (
	select
		sql_id
		, plan_hash_value
		, end_interval_time
		, executions
		, fetches
		, buffer_gets
		, elapsed_time
		, rows_processed
		, disk_reads
		, rows_processed /
			case when executions > 0 then executions
			else	case when rows_processed > 0 then rows_processed
					else 1
					end
			end rows_per_exe
		/* -- lios_per_row is more interesting
		, rows_processed /
			case when buffer_gets > 0 then buffer_gets
			else	case when rows_processed > 0 then rows_processed
					else 1
					end
		end rows_per_lio
		*/
		, buffer_gets /
			case when rows_processed > 0 then rows_processed
			else	case when buffer_gets > 0 then buffer_gets
					else 1
					end
		end lios_per_row
		, instance_number
		, dbid
		, con_id
		, con_dbid
	from raw_data
	order by lios_per_row desc
),
get_expensive_sql as (
	select distinct
		sql_id
		, plan_hash_value
		, max(lios_per_row) over (partition by sql_id, plan_hash_value) lios_per_row
	from rpt_data
	-- this is an important where clause
	-- if not here, the most expensive SQL will frequently be
	-- SQL that is rarely executed, and may be ad hoc
	-- we are interested in frequently executed SQL that performs poorly
	where executions >=	to_number(&n_min_sql_executions)
	order by lios_per_row desc
)
select  distinct
	row_number() over (order by r.lios_per_row desc ) sql_rank
	, r.sql_id
	, r.plan_hash_value
	, r.end_interval_time
	-- uncomment these if needed
	--, r.instance_number
	--, r.con_id
	--, r.con_dbid
	--, r.dbid
	, r.elapsed_time
	, r.elapsed_time / r.executions avg_elapsed_time
	, r.executions
	, r.fetches
	, r.buffer_gets
	, r.rows_processed
	, r.disk_reads
	, r.rows_per_exe
	, r.lios_per_row
	, cn.command_name
	, dbms_lob.getlength(t.sql_text) sql_length
	, get_objects(r.sql_id, r.plan_hash_value) objects
from rpt_data r
join (
		select sql_id, plan_hash_value, lios_per_row
		from get_expensive_sql
		where rownum < 200
	) ml
	on ml.sql_id = r.sql_id
		and ml.plan_hash_value = r.plan_hash_value
		and ml.lios_per_row = r.lios_per_row
	--on ml.sql_id = r.sql_id
	--and ml.lios_per_row = r.lios_per_row
join dba_hist_sqltext t
	on t.sql_id = r.sql_id
	and t.dbid = r.dbid
	and t.con_id = r.con_id
	and t.con_dbid = r.con_dbid
join dba_hist_sqlcommand_name cn
	on cn.dbid = t.dbid
	and cn.con_id = t.con_id
	and cn.con_dbid = t.con_dbid
	and cn.command_type = t.command_type
	and cn.command_name not in ('PL/SQL EXECUTE') -- want to see SQL, not procedures/functions
-- this will tend to favor expensize SQL returning few rows
--order by (lios_per_row*elapsed_time) / rows_processed	 desc
-- this will favor expensive SQL with higher number of executions
--order by (lios_per_row*elapsed_time*rows_processed)	  desc
-- on its own, lios_per_row shows the most expensive SQL, but tends to favor single executions
-- possibley due to ad hoc queries, or seldom run reports
-- this is why n_min_sql_executions is used in the WITH clause 'get_expensive_sql'
order by lios_per_row desc
/

spool off

set term on
ed find-expensive-sql.log

