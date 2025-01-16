
-- metrics-available.sql
-- Jared Still 2023
-- show what metrics are available in AWR

set pagesize 100
set linesize 200 trimspool on
set verify off

col metric_name format a50
col group_name format a50
col metric_unit format a40

col data_source new_value u_data_source noprint

prompt AWR or ASH:
prompt (Not really ASH...)

set term off feed off
select upper('&1') data_source from dual;

col use_awr new_value use_awr noprint
col use_ash new_value use_ash noprint

def use_awr='--'
def use_ash='--'


select 
	case when '&u_data_source' = 'AWR' then 
		''
	else '--'
	end use_awr
from dual;

select 
	case when '&u_data_source' = 'ASH' then 
		''
	else '--'
	end use_ash
from dual;

set term on feed on

--prompt use_awr: &use_awr
--prompt use_ash: &use_ash

with data as (
	select metric_name, g.name group_name, h.metric_unit, sum(value) value_sum
	&use_awr from dba_hist_sysmetric_history h
	&use_ash from v$sysmetric_history h
	join v$metricgroup g on g.group_id = h.group_id
	group by metric_name, g.name, h.metric_unit
)
select 
	metric_name
	, group_name
	, metric_unit
from data
where value_sum is not null
order by 1,2
/


