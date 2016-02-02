
col tablespace_name format a15

with iotimes as (
		  select f.snap_id
					 , tbs.name tablespace_name
					 , f.file#
					 , f.phyrds - lag(f.phyrds) over(partition by f.file# order by f.snap_id,f.file#) phyrdstot
					 , f.phywrts - lag(f.phywrts) over(partition by f.file# order by f.snap_id,f.file#) phywrtstot
					 , f.readtim - lag(f.readtim) over(partition by f.file# order by f.snap_id,f.file#) readtimtot
					 , f.writetim - lag(f.writetim) over(partition by f.file# order by f.snap_id,f.file#) writetimtot
		  from DBA_HIST_FILESTATXS f,
		  v$tablespace tbs
		  where tbs.ts# = f.ts#
)
select
		  to_char(s.end_interval_time,'yyyy-mm-dd hh24:mi:ss') end_interval_time, io.tablespace_name, io.file#
		  , io.phyrdstot
		  , trunc(io.readtimtot * 10,1) readtimtot_ms
		  , trunc(io.readtimtot / decode(io.phyrdstot,0,0.000001,io.phyrdstot) *10,1) avg_read_tim_ms
		  , io.phywrtstot
		  , trunc(io.writetimtot * 10,1) writetimtot_ms
		  , trunc(io.writetimtot / decode(io.phywrtstot,0,0.000001,io.phywrtstot) * 10,1) avg_write_tim_ms
from iotimes io
join dba_hist_snapshot s on s.snap_id = io.snap_id
  --and DATE'2016-01-13' = trunc(s.end_interval_time)
order by io.snap_id, io.file#
/

