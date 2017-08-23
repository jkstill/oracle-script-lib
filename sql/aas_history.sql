
col value format 999999
col end_interval_time forma a25
set pagesize 60

-- change value below to '--' for regular report, '' for CSV
def CSVOUT=''

col u_which_format noprint new_value u_which_format
col u_which_clears noprint new_value u_which_clears

select decode('&CSVOUT','--','rpt_format','csv_format') u_which_format from dual;
select decode('&CSVOUT','--','clears.sql','clear_for_spool.sql') u_which_clears from dual;

@&u_which_clears

spool aas_history.csv

prompt end_interval_time, inst_id, max_aas, avg_aas

with data as (
	select distinct to_char(s.end_interval_time,'yyyy-mm-dd hh24:mi:ss.ff') end_interval_time
		, h.instance_number
		-- AAS is recorded every minute - LOTS of rows
		-- Limiting to max value per snapshot
		, round(max(h.value) over (partition by s.end_interval_time,s.instance_number),2) max_aas
		, round(avg(h.value) over (partition by s.end_interval_time,s.instance_number),2) avg_aas
	from dba_hist_sysmetric_history h
	join dba_hist_snapshot s on s.snap_id = h.snap_id
		and s.dbid = h.dbid
		and s.instance_number = h.instance_number
	where metric_name = 'Average Active Sessions'
	order by 2,1
),
rpt_format as (
	select *
	from data
),
csv_format as (
	select end_interval_time
		||','|| instance_number
		||','|| max_aas
		||','|| avg_aas
	from data
)
select * from &u_which_format
/

spool off

@clears

