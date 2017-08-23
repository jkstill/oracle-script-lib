
@clears
@columns

set pagesize 60
set pause off
--spool tbs.lis
set line 95

column TABLESPACE format a15
column INIT format 9999,999,999
column "NEXT " format 9999,999,999
column MIN format 999
column MAX format 99999
column PCT format 999
column STATUS format a10
column contents format a4 head 'TYPE'
column extent_management format a6 head 'EXTENT|MGT'
column segment_space_management format a7 head 'SEGMENT|SPACE|MGT'

select	substr(tablespace_name,1,20) TABLESPACE,
			status,
			substr(contents,1,4) contents,
			substr(extent_management,1,6) extent_management,
			segment_space_management,
			initial_extent INIT,
			next_extent "NEXT ",
			min_extents MIN,
			max_extents MAX,
			pct_increase PCT
	from dba_tablespaces
	order by tablespace_name 
;


--spool off

