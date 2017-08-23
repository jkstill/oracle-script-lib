
-- host-cpu.sql
-- host cpu is not being stored in dba_hist_sysmetric_history

col metric_unit format a30
col metric_name format a30
col value format 999999.9

alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

set pagesize 60
set linesize 200 trimspool on

set verify on
def metric_tab='v$sysmetric_history'
--def metric_tab='dba_hist_sysmetric_history'

select version from v$instance;

select begin_time, metric_name, metric_unit, value
from &&metric_tab
where metric_name like 'Host CPU%'
order by 1
/
