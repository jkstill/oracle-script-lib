
-- whotmp8i.sql

-- show who is using temp space

@clears
@columns

set term off feed off
col cblocksize noprint new_value ublocksize
select value cblocksize
from v$parameter
where name = 'db_block_size'
/
set term on feed on


col sid format 99999 head 'SESS|ID'
col serial_num format 999999 head 'SER #'
col process format a7 head 'PROCESS'
col megabytes format 99,999.99 head 'TEMP MEG'
col m_name format a10 head 'MACHINE|NAME'
col os_user format a10 head 'OS USER'
col segtype format a6 head 'SEG|TYPE'
col program format a15
col extents format 99,999 head 'EXTENTS'
col blocks format  99,999,999 head 'BLOCKS'

set line 200


select
	b.username USERNAME,
	b.sid,
	b.serial# serial_num,
	b.process,
	substr(b.osuser,1,10)OS_USER,
	substr(b.machine,1,10)M_NAME,
	substr(b.program,1,15)PROGRAM,
	decode(su.contents,'TEMPORARY','TEMP',su.contents) contents,
	su.segtype,
	su.extents,
	su.blocks,
	round ( ( su.blocks * &&ublocksize ) / 1048576  , 1 ) megabytes
from v$session b, v$sort_usage su
where b.status = 'ACTIVE'
and b.saddr = su.session_addr
order by username, sid
/


