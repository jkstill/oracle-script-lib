
-- io_order.sql
-- run after io_end.sql
-- show disk with IO rate 
-- ordered by IO
-- useful to determine files to shuffle

@clears
set pagesize 60

col name format a60
col iopsecond format 9999.99 head 'IOS|PER|SEC'

select
	io.inst_id
	, io.name
	, io.iopsecond
from (
	SELECT
		b.inst_id,
		b.disk disk,
		substr(b.NAME,instr(b.name,'/',-1)+1) name,
		e.blockreads - b.blockreads rdtot,
		e.blockwrites - b.blockwrites wrtot,
		--decode(e.blockreads-b.blockreads,0,&&seconds, e.blockreads-b.blockreads) / &&seconds rpsecond,
		(e.blockreads-b.blockreads) / decode(e.blockreads-b.blockreads, 0, 1, &&seconds) rpsecond,
		(e.blockwrites-b.blockwrites) / decode(e.blockwrites-b.blockwrites, 0, 1, &&seconds) wpsecond,
		((e.blockreads-b.blockreads) + (e.blockwrites-b.blockwrites)) /
			decode(
				(e.blockreads-b.blockreads) + (e.blockwrites-b.blockwrites),
				0,
				1,
				&&seconds
			)iopsecond,
		round(
			(e.blockreads - b.blockreads) / decode((e.blockwrites - b.blockwrites),0,1,(e.blockwrites - b.blockwrites))
			,2) rw_ratio
	FROM   io_end e, io_begin b
	WHERE  b.inst_id = e.inst_id
		and b.file# = e.file# and b.global_name = e.global_name
	-- only show active files
	and ( ( e.blockreads-b.blockreads != 0 ) or ( e.blockwrites-b.blockwrites != 0 ) )
) io
ORDER BY iopsecond
/
