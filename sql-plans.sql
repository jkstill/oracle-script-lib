-- sa.sql - sql activity

@clears
set linesize 200 trimspool on
set pagesize 60

@get_date_range

col u_sql_id new_value u_sql_id noprint

prompt
prompt SQL_ID: 
prompt

-- def vars 1 and 2 already set by get_date_range
set head off term off feed off verify off
select '&3' u_sql_id from dual;

var v_sql_id varchar2(15)

exec :v_sql_id := '&u_sql_id' 

@clear_for_spool

set term off

spool sql-plans.csv

prompt begin_interval_time,sql_id, sql_plan_hash_value, sql_id_count

select to_char(begin_interval_time,'yyyy-mm-dd hh24:mi:ss')
	|| ',' || sql_id
	|| ',' || sql_plan_hash_value
	|| ',' || sql_id_count
from (
select sn.begin_interval_time
	, sh.sql_id
	, sh.sql_plan_hash_value
	, count(*) sql_id_count
from
dba_hist_active_sess_history sh
join dba_hist_snapshot sn on sn.snap_id = sh.snap_id 
	and sn.instance_number = sh.instance_number
	and sh.SQL_ID = :v_sql_id
where sn.begin_interval_time 
	between to_date(:v_begin_date,'&d_date_format')
	and to_date(:v_end_date,'&d_date_format')
group by sn.begin_interval_time
	, sh.sql_id
	, sh.sql_plan_hash_value
order by 1,2
)
/

spool off
set term on
ed sql-plans.csv
