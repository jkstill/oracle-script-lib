
-- aas.sql
-- Jared Still  jkstill@gmail.com
-- 2019 
-- average active sessions as reported by sysmetric_history
-- see also aas-ash-calc.sql


set pagesize 100
set linesize 200 trimspool on
set echo off pause off term on feed on

col begin_time format a26
col end_time format a26
col inst_id format 9999 head 'INST'
col elapsed_seconds format 990.999990 head 'ELAPSED|SECONDS'
col aas format 990.9 head 'AAS'

with data as (
	select
		to_char(h.begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
		, to_char(h.end_time,'yyyy-mm-dd hh24:mi:ss') end_time
		, (h.end_time - h.begin_time) * 86400  elapsed_seconds
		, h.inst_id
		, round(h.value,2) aas
	from gv$sysmetric_history h
	where h.metric_name = 'Average Active Sessions'
	order by h.begin_time
)
select
	begin_time
	, end_time
	, inst_id
	, elapsed_seconds
	, aas
from data
/
