
-- redo-sysmetric-cdb-hist-csv.sql
-- Description: This script retrieves "Redo Generated Per Sec" redo generation metrics from the cdb_hist_sysmetric_history view.
-- Values are summed for each metric
-- Note: This script is designed for Oracle Database 12.2 and later versions that support the cdb_hist_sysmetric_history view.
--       The script will work in both CDB and non-CDB environments.
-- Jared Still 2026-05-22

set term off

clear columns
clear break

set linesize 1000 trimspool on
set pagesize 0
set feedback off
set verify off
set pause off

col host_name new_value host_name noprint
select host_name from v$instance where rownum = 1;
col db_name new_value db_name noprint
select name as db_name from v$database where rownum = 1;

col spool_file new_value spool_file noprint
select 'redo_' || lower('&db_name') || '_' || lower('&host_name') || '_' || to_char(sysdate, 'YYYYMMDD-HH24MISS') || '.csv' as spool_file from dual;

spool &spool_file

set term on

prompt begin_time,end_time,interval,redo_bytes_per_sec,estimated_redo_bytes_per_interval

with data as (
   select
      h.begin_time,
      h.end_time,
      sum(h.value) as redo_bytes_per_sec
   from cdb_hist_sysmetric_history h
   join v$database d
      on d.dbid = h.dbid
   where h.group_id = 2
   and h.metric_name = 'Redo Generated Per Sec'
   group by
      begin_time,
      end_time
)
select
   to_char(begin_time, 'YYYY-MM-DD HH24:MI:SS')
   ||','|| to_char(end_time, 'YYYY-MM-DD HH24:MI:SS')
   ||','|| round(((cast(end_time as date) - cast(begin_time as date)) * 86400),0)
   ||','|| round(redo_bytes_per_sec,0)
   ||','|| round(
      redo_bytes_per_sec * ((cast(end_time as date) - cast(begin_time as date)) * 86400)
   ,0) 
from data
order by 1
/

spool off

prompt
prompt CSV file generated: &spool_file
prompt

