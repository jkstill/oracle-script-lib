
@clears
@columns

set line 100

col contents format a20
col blocks format 999,999,999
col bytes format 999,999,999,999

col blocksize new_value blocksize noprint

select value blocksize
from v$parameter
where name = 'db_block_size'
/

select
	username
	--, "USER"
	--, session_addr
	--, session_num
	--, sqladdr
	--, sqlhash
	, tablespace tablespace_name
	, contents
	, segtype
	--, segfile#
	--, segblk#
	--, extents
	, blocks
	, blocks * &&blocksize bytes
	--, segrfno#
from v$tempseg_usage
order by username
/
