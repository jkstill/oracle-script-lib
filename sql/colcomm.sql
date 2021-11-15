
-- colcomm.sql
-- find common columns between a set of tables
-- Jared Still  jkstill@gmail.com
-- no spaces allowed
-- @colcom owner1.tab1,owner2.tab2,...

col u_list new_value u_list noprint

prompt
prompt list: 
prompt

set feed off term off head off verify off
select '&1' u_list from dual;
set feed on term on head on

set linesize 200 trimspool on 
set pagesize 100

col idx format 999
col string format a40
col lft format a40
col rght format a40
col cloc format 999999
col val format a30
col table_owner format a30
col table_name format a30
col tab_list format a31 wrap

with csv (idx,string,cloc,val,rght) as (
	select 
		0 as idx
		, t.string
		, instr('&u_list',',') cloc
		, substr(t.string,1,instr('&u_list',',') -1)  val
		, substr(t.string,instr('&u_list',',')) rght
	from  (select upper(regexp_replace('&u_list','\s+','')) string from dual) t
	union all
	select 
		csv.idx + 1 as idx
		, csv.string
		, instr(csv.rght,',') cloc
		,
		case
		when instr(csv.rght,',') != instr(csv.rght,',', -1)  -- last two elements will 'val,val'
			then substr
			(
				csv.rght, -- string
				instr(csv.rght,',')+1,  -- start
				instr(csv.rght,',', instr(csv.rght,',')+1) - instr(csv.rght,',') -1 -- length
			)
		else substr(csv.rght,instr(csv.rght,',')+1)
		end val
		, 
		case when instr(csv.rght,',') > 0 
			then substr(csv.rght,instr(csv.rght,',')+1)
		else''
		end rght
	from csv
	where instr(csv.rght,',') > 0
),
tabs as (
	select 
		substr(val,1,instr(val,'.')-1) table_owner
		, substr(val,instr(val,'.')+1) table_name
	from csv
)
select
	--tabs.table_owner
	--, tabs.table_name
	tc.column_name
	, count(*) occurrences
	, listagg(dt.object_name,', ') within group (order by dt.object_name) tab_list
from tabs
	, dba_objects dt
	, dba_tab_columns tc
where dt.owner = tabs.table_owner
	and dt.object_name = tabs.table_name
	and tc.owner = dt.owner
	and tc.table_name = dt.object_name
	and dt.object_type in ('TABLE','VIEW')
group by column_name
	having count(*) > 1
order by column_name
/

