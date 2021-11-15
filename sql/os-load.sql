

-- os-load.sql
-- System load for the previous hour as reported by Oracle
--  - Jared Still
--  jkstill@gmail.com

col os_load format 999.99
col begin_time format a20
col metric_name format a30
col interval_seconds format 9999 head 'INTERVAL'
col inst_id format 9999 head 'INST'

set linesize 200 trimspool on
set pagesize 60

select inst_id
	, to_char(h.begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
	, g.name metric_name
	, interval_size / 100 interval_seconds
	,round(h.value,2) OS_LOad
from gv$sysmetric_history h
join v$metricgroup g on g.group_id = h.group_id
where h.metric_name =  'Current OS Load'
order by h.inst_id, h.group_id, h.begin_time
/


