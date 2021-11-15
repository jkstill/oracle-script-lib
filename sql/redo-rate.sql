
-- redo-rate.sql
-- show real time redo rates
-- Jared Still  jkstill@gmail.com
--  2020
-- 

col metric_unit format a30
col metric_name format a30

set linesize 200 trimspool on
set pagesize 100
     
select * from V$SYSMETRIC_HISTORY where metric_name = 'Redo Generated Per Sec' order by end_time

break on inst_id skip 1 on con_id skip 1 on begin_time skip 1 on end_time skip 1

select 
	end_time
	, inst_id
	, con_id
	, metric_name
	, metric_unit
	, value
from GV$SYSMETRIC_HISTORY
where metric_name like 'Redo%'
order by end_time, inst_id, con_id,  metric_name
/

