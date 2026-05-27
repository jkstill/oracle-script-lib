
-- redo-sysmetric-cdb-hist.sql
-- Description: This script retrieves redo generation metrics from the cdb_hist_sysmetric_history, specifically focusing on "Redo Generated Per Sec" and "Redo Generated Per Txn". 
-- It pivots the data to display these metrics side by side for easier analysis. The script also calculates an estimated transaction count based on the redo generation rates.
-- Note: This script is designed for Oracle Database 12.2 and later versions that support the cdb_hist_sysmetric_history view.
--       The script will work in both CDB and non-CDB environments, but the con_id column will be relevant only in CDB environments.
-- Jared Still 2026-05-15


set linesize 250 trimspool on
set pagesize 1000
col inst_id format 999
col begin_time format a20
col metric_name format a30
col metric_value format 999999.99
col metric_unit format a30
col group_id format 999
col metric_id format 9999
col con_id format 999
col metric_id_redo_bytes_per_sec format 9999 head 'Redo Gen/Sec|Metric ID'
col metric_id_redo_bytes_per_txn format 9999 head 'Redo Gen/Txn|Metric ID'
col redo_bytes_per_sec format 99999999 head 'Redo Gen/Sec'
col redo_bytes_per_txn format 99999999 head 'Redo Gen/Txn'
col estimated_txn format 99999999 head 'Estimated|Txn Count'

with data as (
select
	h.con_id,
	h.instance_number inst_id,
	to_char(h.begin_time, 'YYYY-MM-DD HH24:MI:SS') as begin_time,
	group_id,
	max(case when h.metric_name = 'Redo Generated Per Sec' then h.metric_id end) as metric_id_redo_bytes_per_sec,
	max(case when h.metric_name = 'Redo Generated Per Txn' then h.metric_id end) as metric_id_redo_bytes_per_txn,
	-- Pivot
	max(case when h.metric_name = 'Redo Generated Per Sec' then h.value end) as redo_bytes_per_sec,
	--
	max(case when h.metric_name = 'Redo Generated Per Txn' then h.value end) as redo_bytes_per_txn
from
	cdb_hist_sysmetric_history h
	join v$database d 
		on d.dbid = h.dbid
where
    h.group_id = 2 -- long duration metrics
    AND metric_name IN (
		'Redo Generated Per Sec',
		'Redo Generated Per Txn'
    )
GROUP BY
	 h.con_id,
    h.instance_number,
    h.begin_time,
    h.group_id
)
select
	con_id,
	 inst_id,
	 begin_time,
	 group_id,
	 metric_id_redo_bytes_per_sec,
	 metric_id_redo_bytes_per_txn,
	 redo_bytes_per_sec,
	 redo_bytes_per_txn,
	 case
		when redo_bytes_per_sec > 0 AND redo_bytes_per_txn > 0 then
			round(redo_bytes_per_sec / redo_bytes_per_txn, 2)
		else
			NULL
	end estimated_txn
from data
order by
	 con_id,
    inst_id,
    begin_time asc,
    group_id
/


