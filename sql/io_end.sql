
clear col

drop table io_end;
--truncate table io_end;

create table io_end( 
	drive varchar2(12),
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
storage( initial 10k next 10k pctincrease 0)
/

insert into io_end( drive, name, file#, blockreads, blockwrites, writetime, readtime, ratio, io_date, global_name)
SELECT 
	--if there is a '/' in the name, then it's unix
	substr(
		name,1,
		decode( instr(name,'/'),
			0,1,  -- Win32: get the drive letter
			12    -- Unix: 12 is the length of the column
		)
	) drive
	, substr(NAME,1,60) name
	, df.file#
	, PHYBLKRD blockreads
	, PHYBLKWRT blockwrites
	, writetim writetime
	, readtim readtime
	, round((phyblkrd / decode(phyblkwrt,0,1,phyblkwrt)),2) ratio
	, sysdate
	, substr(global_name,1,instr(global_name,'.')-1) global_name
FROM   V$DBFILE DF, V$FILESTAT FS, global_name g
WHERE  DF.FILE#=FS.FILE#
/

commit;

@@io_stat
--ed io_stat.txt


