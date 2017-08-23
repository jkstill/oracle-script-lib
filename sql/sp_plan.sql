
-- sp_plan.sql
--
-- display historic execution plans
-- from statspack data
-- inputs are number of most recent snapshots to search
-- and the SQL statement to look for
-- (search is case insensitive)
--
-- the function full_sql_text (full_sql_text.sql) must be created
-- prior to running this script
--
-- ex. @sp_plan  20 'select%from dual'

@clears

col csnapcount new_value snapcount noprint
col csqlsearch new_value sqlsearch noprint

var snapcount number
var sqlsearch varchar2(200)

prompt Number of recent snapshots to search? 
set term off head off
select '&1' csnapcount from dual;
set term on

prompt SQL fragment to search for?
prompt (case insensitive)
set term off
select '&2' csqlsearch from dual;
set term on head on

begin
	:sqlsearch := '&&sqlsearch';
	:snapcount := &&snapcount;
end;
/


-- easier to read log in vi when at end of line
set trimspool off

--mm/dd/yy hh24:mi
col snap_time format a14 
col snap_id format 9999999
col sql_text format a40
col operation format a40
col object_name format a30
col id format 999  
col cardinality format 99,999,999
col bytes format 99,999,999,999


break on sql_text on snap_id skip 1 on snap_time skip 1

set linesize 175
set pagesize 60

spool sp_plan.log

prompt Searching the last &&snapcount statspack snapshots for this SQL:
prompt &&sqlsearch
prompt

select
	perfstat.full_sql_text(spu.hash_value,s.snap_id) sql_text
	--, s.snap_id
	, to_char(s.snap_time,'mm/dd/yy hh24:mi') snap_time
	--,sp.depth
	--,sp.operation
	,sp.id
	,lpad(' ',sp.depth,' ') || sp.operation || ' ' || sp.options operation
	,sp.object_name
	,sp.cost
	,sp.cardinality
	,sp.bytes
from perfstat.stats$snapshot s
	, perfstat.stats$sqltext st
	, perfstat.stats$sql_plan_usage spu
	, perfstat.stats$sql_plan sp
where  s.snap_id in (
	(
		select snap_id
		from (
			select snap_id
			from perfstat.stats$snapshot
			order by snap_id desc
		)
		where rownum <= :snapcount
	)
)
and s.snap_id = st.last_snap_id
and lower(st.sql_text) like lower(:sqlsearch)
and spu.snap_id = st.last_snap_id
and spu.hash_value = st.hash_value
and sp.plan_hash_value = spu.plan_hash_value
and st.piece = 0
order by spu.hash_value,s.snap_id,sp.id
/

spool off

undef 1 2

ed sp_plan.log

