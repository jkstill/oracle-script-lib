
-- data-growth-tbs-predict-regr.sql
-- Jared Still
-- based on a helpful asktom article
-- https://asktom.oracle.com/pls/apex/asktom.search?tag=predict-tablespace-growth-for-next-30-days

set linesize 200 trimspool on
set pagesize 100

col used_mb format 99,999,999,999
col start_time format a20
col size_src format a15
col csv_data format a200

-- these will need to be manually set for csv
set pagesize 0
set feed off head off time off timing off
set echo off verify off
set term on
btitle off
ttitle off

-- output style set by '' in the style desired
define csv_format=''
define std_format='--'

col u_spoolfile new_value u_spoolfile noprint
select 'data-growth-tbs-predict-regr-' || name || '.csv' u_spoolfile from v$database;

spool &u_spoolfile

prompt tablespace,date,size_mb, size_src

with tsdata as (
	select
		t.tablespace_name
		, s.snap_id
		, s.instance_number
		, sum(h.tablespace_usedsize * t.block_size/1024/1024) used_mb
		-- date is text and stored in this format: 'MM/DD/YYYY HH24:MI:SS'
		--, trunc(to_date(h.rtime, 'MM/DD/YYYY HH24:MI:SS'),'MM') resize_time
	from dba_hist_tbspc_space_usage		h
		, dba_hist_snapshot					s
		, dba_tablespaces						t
		, v$tablespace ts
		, v$instance i
	where h.snap_id = s.snap_id
		and ts.ts# = h.tablespace_id
		and t.tablespace_name = ts.name
		and i.instance_number = s.instance_number
	group by t.tablespace_name, s.instance_number, s.snap_id
	order by t.tablespace_name, s.snap_id
),
monthly_data as (
	select	distinct
		t.tablespace_name
		, trunc(max(s.begin_interval_time) over (partition by t.tablespace_name, trunc(s.begin_interval_time,'MM')),'MM')	 start_time
		, round(max(t.used_mb) over (partition by trunc(s.begin_interval_time,'MM')),0) used_mb
	from tsdata t
	join dba_hist_snapshot s on s.snap_id = t.snap_id
		and s.instance_number = t.instance_number
	order by t.tablespace_name, start_time
)
, growth_data as (
	select
		d.tablespace_name
		, d.start_time
		, max(d.used_mb) used_mb
	from monthly_data d
	group by d.tablespace_name, d.start_time
	order by d.tablespace_name, d.start_time
)
,regr_data as (
	select
		tablespace_name
		, regr_slope(used_mb, to_number(to_char(start_time,'j'))) rs
		, regr_intercept(used_mb, to_number(to_char(start_time,'j')))	ri
		, max(start_time) max_start_time
	from growth_data
	group by tablespace_name
)
select
	&std_format tablespace_name
	&std_format , start_time
	&std_format , used_mb
	&std_format , 'actual MB' size_src
	--
	&csv_format tablespace_name
	&csv_format ||','|| to_char(start_time,'YYYY-MM-DD')
	&csv_format ||','|| used_mb
	&csv_format ||','|| 'actual MB'	csv_data
from monthly_data
union all
select
	&std_format rg.tablespace_name
	&std_format , add_months(rg.max_start_time,r.r) start_time
	&std_format , trunc(rg.ri+(rg.rs*to_number(to_char(rg.max_start_time+r,'j')))) used_mb
	&std_format , 'predicted MB' size_src
	--
	&csv_format rg.tablespace_name
	&csv_format ||','|| to_char(add_months(rg.max_start_time,r.r),'YYYY-MM-DD')
	&csv_format ||','|| trunc(rg.ri+(rg.rs*to_number(to_char(rg.max_start_time+r,'j'))))
	&csv_format ||','|| 'predicted MB' csv_data
from regr_data rg
, (
	select  level r
	from dual
	connect by level <= 60
) r
&std_format order by tablespace_name, start_time
&csv_format order by 1
/


spool off
