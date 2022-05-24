
-- stats-sqlid.sql
-- get stats info for all objects used in a SQL_ID
-- Jared Still -  2017
--  jkstill@gmail.com
--
-- the plan_hash_values are shown as an aggregate.
-- this may be misleading, as the object on that line may not actually appear in that plan.
-- I chose succinctness with a slight loss of accuracy
-- as this report becomes much busier and hard to read if PHV is matched exactly
--
-- initial testing with 12.2 SYS SQL_ID cyw0c6qyrvsdd
-- 
-- call with SQL_ID and status of Diagnostic Pack licensing
-- do not use AWR
--    @stats-sqlid.sql cyw0c6qyrvsdd N
-- use AWR
--    @stats-sqlid.sql cyw0c6qyrvsdd Y


@clears

ttitle off
btitle off

col s_diag_pack new_value s_diag_pack noprint
col s_sql_id new_value s_sql_id noprint
var v_sql_id varchar2(13)

prompt
prompt SQL_ID? : 
prompt

set feed off term off 
select '&1' s_sql_id from dual;

set term on

whenever sqlerror exit 128

begin 
	:v_sql_id := '&s_sql_id';
	if 
		length(:v_sql_id) < 1
		or 
		:v_sql_id is null
	then
		raise value_error;
	end if;
end;
/

whenever sqlerror continue
set feed on

prompt
prompt Diag Pack (Y/N)? : 
prompt

set feed off term off 
select decode(upper('&2'),'Y','','--') s_diag_pack from dual;
set feed on term on


set pagesize 100
set linesize 300 trimspool on

col partition_start format a6 head 'PSTART'
col sql_id format a13
col partition_stop format a6 head 'PSTOP'
col owner format a20
col table_name format a30
col index_name format a40
col phv format a43 wrap
col last_analyzed format a19
col stale_stats format a3 head 'STL'
col num_rows format 99,999,999,999
col blocks format 9,99,999,999
col partition_position format 999999 head 'PP'

break on sql_id skip 1

spool stats-sqlid.txt

with objects as (
	-- extra inline view is to eliminate duplicates in listagg()
	select 
		sql_id
		, listagg(phv,',') within group(order by phv)  phv
		, object_owner
		, object_name
		, object_type
		, partition_start
		, partition_stop
	from (
		select distinct
			sql_id
			, phv
			, object_owner
			, object_name
			, object_type
			, partition_start
			, partition_stop
		from (
			select 
				sql_id
				, plan_hash_value phv
				, object_owner
				, object_name
				, object_type
				, case partition_start
					when 'ROW LOCATION' then 'ROWID'
					else partition_start
				end partition_start
				, case partition_stop
					when 'ROW LOCATION' then 'ROWID'
					else partition_stop
				end partition_stop
			from v$sql_plan
			where sql_id = :v_sql_id
			and object_owner is not null
			and object_type in ('TABLE','INDEX','INDEX (UNIQUE)','INDEX (CLUSTER)','CLUSTER','TABLE (FIXED)')
			&s_diag_pack union all
			&s_diag_pack select 
				&s_diag_pack sql_id
				&s_diag_pack , plan_hash_value phv
				&s_diag_pack , object_owner
				&s_diag_pack , object_name
				&s_diag_pack , object_type
				&s_diag_pack , case partition_start
					&s_diag_pack when 'ROW LOCATION' then 'ROWID'
					&s_diag_pack else partition_start
				&s_diag_pack end partition_start
				&s_diag_pack , case partition_stop
					&s_diag_pack when 'ROW LOCATION' then 'ROWID'
					&s_diag_pack else partition_stop
				&s_diag_pack end partition_stop
			&s_diag_pack from dba_hist_sql_plan
			&s_diag_pack where sql_id = :v_sql_id
			&s_diag_pack and object_owner is not null
			&s_diag_pack and object_type in ('TABLE','INDEX','INDEX (UNIQUE)','INDEX (CLUSTER)','CLUSTER','TABLE (FIXED)')
		)
	)
	group by
		sql_id
		, object_owner
		, object_name
		, object_type
		, partition_start
		, partition_stop
),
indexes as (
	select * from objects where object_type in ('INDEX','INDEX (UNIQUE)','INDEX (CLUSTER)')
),
tables as (
	select * from objects where object_type in ('TABLE','CLUSTER','TABLE (FIXED)')
)
select 
	sql_id
	, phv
	, owner
	, table_name
		|| decode(s.partition_name, null,'','.' || s.partition_name)
		as table_name
	, null index_name
	, partition_position
	, t.partition_start
	, t.partition_stop
	, num_rows
	, blocks
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
	, stale_stats
from dba_tab_statistics s
 join tables t on t.object_owner = s.owner
	and t.object_name = s.table_name
union all
select 
	sql_id
	, phv
	, owner
	, table_name 
	, index_name
		|| decode(s.partition_name, null,'','.' || s.partition_name)
		as index_name
	, partition_position
	, i.partition_start
	, i.partition_stop
	, num_rows
	, leaf_blocks blocks
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
	, stale_stats
from dba_ind_statistics s
 join indexes i on i.object_owner = s.owner
	and i.object_name = s.index_name
order by sql_id
	, owner
	, table_name
	, index_name nulls first
	, partition_position nulls first
/

spool off

ed stats-sqlid.txt

undef 1 2


