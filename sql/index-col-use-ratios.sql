-- index-col-use-ratios.sql
-- Jared Still  jkstill@gmail.com
-- 2016-12-07

set linesize 200 trimspool on
set pagesize 60

col table_name format a30
col index_name format a30
col column_name format a20

col tab_column_count format 9999 head 'TAB|COL|COUNT'
col ind_column_count_unq format 9999 head 'IND|COL|COUNT|UNIQ'
col ind_column_count_all format 9999 head 'IND|COL|COUNT|ALL'

col dup_ind_cols_pct format 999.9 head 'DUP|COLS|PCT'
col all_ind_cols_pct format 999.9 head 'ALL|COLS|PCT'

break on table_name on index_name

-- spool to CSV
clear break

@clear_for_spool


spool index-col-use-ratios.csv

prompt OWNER,TABLE_NAME,TAB COL COUNT,IND COL COUNT UNIQ,IND COL COUNT ALL,DUP COLS PCT,ALL COLS PCT

with ignore_schemas as (
	select username
	from dba_users
	where default_tablespace in ('SYSTEM','SYSAUX')
)
, tab_colcount as ( -- number of columns in table
	select /*+ no_merge */ owner, table_name, count(*) tab_column_count
	from dba_tab_columns
	where owner not in (select username from ignore_schemas)
	group by owner, table_name
),
ind_colcount as ( -- number of columns appearing in indexes
	select /*+ no_merge */ table_owner, table_name
		, count(distinct column_name) ind_column_count_unq
		, count(*) ind_column_count_all -- includes duplicate usage
	from dba_ind_columns
	where table_owner not in (select username from ignore_schemas)
	group by table_owner, table_name
),
data as (
select
	t.owner
	, t.table_name
	, tc.tab_column_count
	, ic.ind_column_count_unq
	, ic.ind_column_count_all
	-- percent	of columns that appear in more than one index
	, round(100 - (ic.ind_column_count_unq / ic.ind_column_count_all * 100),1)	 dup_ind_cols_pct
	-- percent	of columns that appear in indexes
	, round(ic.ind_column_count_unq / tc.tab_column_count * 100,1) all_ind_cols_pct
from dba_tables t
join tab_colcount tc on tc.owner = t.owner
	and tc.table_name = t.table_name
join ind_colcount ic on ic.table_owner = t.owner
	and ic.table_name = t.table_name
where t.owner not in (select username from ignore_schemas)
order by owner, table_name
)
select
	owner
	|| ','|| table_name
	|| ','|| tab_column_count
	|| ','|| ind_column_count_unq
	|| ','|| ind_column_count_all
	|| ','|| dup_ind_cols_pct
	|| ','|| all_ind_cols_pct
from data
where dup_ind_cols_pct > 25
	or all_ind_cols_pct > 40
/

spool off

@clears
