
-- redo-sysmetric.sql
-- Description: This script retrieves redo generation metrics from the gv$sysmetric_history view, specifically focusing on "Redo Generated Per Sec" and "Redo Generated Per Txn". 
-- It pivots the data to display these metrics side by side for easier analysis. The script also calculates an estimated transaction count based on the redo generation rates.
-- Jared Still 2026-05-15


set linesize 250 trimspool on
set pagesize 1000
col inst_id format 999
col begin_time format a20
col interval_duration format a15
col metric_name format a30
col metric_value format 999999.99
col metric_unit format a30
col group_id format 999
col metric_id format 9999
col con_id format 999
col metric_id_redo_bytes_per_sec format 9999 head 'Redo Gen/Sec|Metric ID'
col metric_id_redo_bytes_per_txn format 9999 head 'Redo Gen/Txn|Metric ID'
col redo_bytes_per_sec format 999999.99 head 'Redo Gen/Sec'
col redo_bytes_per_txn format 999999.99 head 'Redo Gen/Txn'
col estimated_txn format 999999.99 head 'Estimated|Txn Count'

with data as (
select
	con_id,
	inst_id,
	to_char(begin_time, 'YYYY-MM-DD HH24:MI:SS') as begin_time,
	max(intsize_csec/100)                        as interval_sec,
	group_id,
	max(case when metric_name = 'Redo Generated Per Sec' then metric_id end) as metric_id_redo_bytes_per_sec,
	max(case when metric_name = 'Redo Generated Per Txn' then metric_id end) as metric_id_redo_bytes_per_txn,
	-- Pivot
	max(case when metric_name = 'Redo Generated Per Sec' then value end) as redo_bytes_per_sec,
	--
	max(case when metric_name = 'Redo Generated Per Txn' then value end) as redo_bytes_per_txn
from
    gv$sysmetric_history
where
    group_id IN (2, 18)
    AND metric_name IN (
		'Redo Generated Per Sec',
		'Redo Generated Per Txn'
    )
GROUP BY
	 con_id,
    inst_id,
    begin_time,
    group_id
)
select
	con_id,
	 inst_id,
	 begin_time,
	 interval_sec,
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


