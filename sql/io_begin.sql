
clear col


-- must truncate GTT before dropping
truncate table io_begin;
drop table io_begin purge;

create global temporary table io_begin( 
	inst_id number,
	disk varchar2(16),
	name varchar2(60),
	file# number,
	blockreads number(12,0),
	blockwrites number(12,0),
	writetime number(12,0),
	readtime number(12,0),
	ratio number(12,2),
	io_date date,
	global_name varchar2(40)
)
on commit preserve rows
--storage( initial 10k next 10k pctincrease 0)
/

insert into io_begin( inst_id, disk, name, file#, blockreads, blockwrites, writetime, readtime, ratio, io_date, global_name)
SELECT 
	--if there is a '/' in the name, then it's unix
	df.inst_id
	, substr(
		name,1,
		decode( instr(name,'/'),
			0,1,  -- Win32: get the disk letter
			16    -- Unix: 16 is the length of the column
		)
	) disk
	, substr(NAME,1,60) name
	, df.file#
	, PHYBLKRD blockreads
	, PHYBLKWRT blockwrites
	, writetim writetime
	, readtim readtime
	, round((phyblkrd / decode(phyblkwrt,0,1,phyblkwrt)),2) ratio
	, sysdate
	, global_name
FROM   GV$DBFILE DF, GV$FILESTAT FS, global_name g
WHERE  FS.INST_ID = DF.INST_ID
	AND DF.FILE#=FS.FILE#
/

commit;


