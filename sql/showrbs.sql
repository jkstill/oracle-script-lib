
set pagesize 60 line 155
--spool rbs.lis

column TABLESPACE format a15;
column SEG_NAME format a12 head 'NAME';
column INIT format 999999999;
column NEXT format 999999999;
column MIN format 999;
column MAX format 999;
column STATUS format a8;
col waits format 999,999
col gets format 99,999,999
col shrinks format 99999 head 'SHRINKS'
col wraps format 9999 head 'WRAPS'
col optsize format 999999999 head 'OPTIMAL'
col extents format 999 head 'EXT'
col extends format 99999 head 'EXTNDS'
col xacts format 9999 head 'CURR#|TRANS'
col hit_ratio head 'HIT%' format 999.99
col hwmsize format 99,999,999,999 head 'HIGH|WATER|MARK'

select	
	substr(d.tablespace_name,1,15) TABLESPACE,
	d.segment_name SEG_NAME,
	d.initial_extent INIT,
	d.next_extent NEXT,
	d.min_extents MIN,
	d.max_extents MAX,
	v.extents,
	v.optsize,
	v.hwmsize,
	v.xacts,
	v.waits,
	v.gets,
	((gets-waits)*100)/gets hit_ratio,
	v.wraps,
	v.extends,
	v.shrinks,
	d.status STATUS
from dba_rollback_segs d, v$rollstat v
where v.usn(+) = d.segment_id
order by tablespace_name, seg_name
/

--spool off

