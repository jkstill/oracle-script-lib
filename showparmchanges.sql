
-- showparmchanges.sql
-- based on Carlos Sierra query
-- http://carlos-sierra.net/2015/03/25/discovering-if-a-system-level-parameter-has-changed-its-value-and-when-it-happened/

set linesize 200 trimspool on

col begin_time format a16
col end_time format a16
col snap_id format 99999999
col dbid format 999999999999
col instance_number head 'INST' format 9999
col parameter_name format a40
col value format a40
col isdefault format a3 head 'DEF'
col ismodified format a3 head 'MOD'
col prior_value format a40

WITH
all_parameters AS (
SELECT snap_id,
       dbid,
       instance_number,
       parameter_name,
       value,
		 -- TRUE/FALSE
       decode(substr(isdefault,1),'T','YES','NO') isdefault,
		 -- FALSE/MODIFIED
       decode(substr(ismodified,1),'F','NO','YES') ismodified,
       lag(value) OVER (PARTITION BY dbid, instance_number, parameter_hash ORDER BY snap_id) prior_value
  FROM dba_hist_parameter
)
SELECT 
	p.parameter_name,
	TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD HH24:MI') begin_time,
	--TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI') end_time,
	p.snap_id,
	--p.dbid,
	p.instance_number,
	p.isdefault,
	p.ismodified,
	p.value,
	p.prior_value
FROM all_parameters p,
	dba_hist_snapshot s
WHERE p.value != p.prior_value
	AND s.snap_id = p.snap_id
	AND s.dbid = p.dbid
	AND s.instance_number = p.instance_number
ORDER BY
	p.parameter_name,
	s.begin_interval_time DESC,
	p.instance_number
/
