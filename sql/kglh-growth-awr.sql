
-- kglh-growth-awr.sql
-- continued growth of kglh[d0] (gigabytes) is evidence of a memory leak

-- 11.2.0.3.4 Memory Leak Under KGLHD In Shared Pool (Doc ID 1534706.1)
-- Bug 13250244 : ORA-4031 ERRORS SEEN WHEN PARAMETER _KGHDSIDX_COUNT IS SET TO >1 DUE TO MEM LEAK
-- Bug 13250244 - Shared pool leak of "KGLHD" memory when using multiple subpools (Doc ID 13250244.8)
-- High Memory Allocations of KGLHD in Shared Pool (Doc ID 1435186.1)

set line 200 trimspool on
set pagesize 100

col begin_interval_time format a30 head 'Begin Interval|Time'
col startup_time format a30
col bytes format 999,999,999,999
col start_bytes format 999,999,999,999
col end_bytes format 999,999,999,999
col component format a7

break on startup_time skip 1


select  distinct
	s.startup_time
	, g.name component
	, g.pool
	, min(g.bytes) over (partition by s.startup_time, g.name, g.pool) start_bytes
	, max(g.bytes) over (partition by s.startup_time, g.name, g.pool) end_bytes
	--, s.snap_id
	--, s.begin_interval_time
from dba_hist_sgastat g	 , dba_hist_snapshot s
--where name in ('KGLHD','KGLH0')
where name like 'KGLH%'
--and pool='shared pool'
--and trunc(begin_interval_time) >= '01-OCT-2017'
and s.snap_id = g.snap_id
--and g.instance_number = 1
and s.instance_number = g.instance_number
order by startup_time, component
/
