

-- maxext3.sql
-- find tables/indexes with only 1 or 2 extents to go before
-- hitting maxextents
-- OR
-- will be unable to allocate an extent due to space limitations
-- jkstill 08/13/2001

clear break
clear computes
clear col
btitle off

set trimspool on
set pause off verify off echo off feed on term on

col segment_owner format a10 head 'OWNER'
col segment_type format a5 head 'TYPE'
col segment_name format a30 head 'NAME'
col extent_count format 999 head 'NUM|EXT'
--col max_extents format 9,999,999,999 head 'MAX|EXT'
col max_extents format a14
col next_extent format 99,999,999,999 head 'NEXT|EXTENT|BYTES'
col tablespace_name format a15 head 'TABLESPACE|NAME'
col num_extents_available format a14 head 'NUM EXTENTS|AVAILABLE'
col max_bytes_free format 99,999,999,999 head 'MAX|BYTES|FREE'


--@@title132 'Frag/Filled Extent Report for Multiple Extents For '
@title 'Table With Impending Extent Allocation Problems' 132

set verify off pause off echo off
set pages 66 term on feed on line 132

break on segment_owner skip 1 on segment_type skip 1 on segment_name on report

--spool /tmp/maxextr.&&dbname..txt
--spool $HOME/tmp/&&dbname/maxextr.txt


select
	s.owner segment_owner
	, s.segment_name
	, s.segment_type
	, s.tablespace_name
	, s.extents extent_count
	, decode( sign( 100000 - s.max_extents),
		-1, lpad('UNLIMITED',14),
		0, lpad('UNLIMITED',14),
		1, to_char(s.max_extents,'9,999,999,999')
	) max_extents
	, decode( sign( 100000 - ( s.max_extents - s.extents ) ),
		-1, lpad('UNLIMITED',14),
		0, lpad('UNLIMITED',14),
		1, to_char(s.max_extents - s.extents, '9,999,999,999')
	) num_extents_available
	, s.next_extent
	, f.max_bytes_free
from dba_segments s, 
(
	select t.tablespace_name, max(nvl(f.bytes,0)) max_bytes_free
	from dba_free_space f, dba_tablespaces t
	where t.tablespace_name = f.tablespace_name(+)
	group by t.tablespace_name
) f
where s.tablespace_name = f.tablespace_name
	and 
	(
		(s.max_extents - s.extents) < 3
		or 
		s.next_extent > f.max_bytes_free
	)
	and segment_type in ('TABLE','INDEX')
order by 1,2,3
/



