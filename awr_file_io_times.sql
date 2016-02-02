
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
	, io.readtimtot
	, io.readtimtot / decode(io.phyrdstot,0,0.000001,io.phyrdstot) avg_read_tim
	, io.phywrtstot
	, io.writetimtot
	, io.writetimtot / decode(io.phywrtstot,0,0.000001,io.phywrtstot) avg_write_tim
from iotimes io
join dba_hist_snapshot s on s.snap_id = io.snap_id
order by io.file#, io.snap_id
/

