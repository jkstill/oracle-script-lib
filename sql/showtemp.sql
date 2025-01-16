@clears
@columns

set line 200 trimspool on

col username format a20
col contents format a20
col blocks format 999,999,999
col bytes format 999,999,999,999
col sql_id format a13

col blocksize new_value blocksize noprint

select
	tu.username
	--, "USER"
	--, tu.session_addr
	--, tu.session_num
	--, tu.sqladdr
	, tu.sqlhash
	, (select distinct sql_id from v$sqlarea where hash_value = tu.sqlhash) sql_id
	, tu.tablespace tablespace_name
	, tu.contents
	, tu.segtype
	--, tu.segfile#
	--, tu.segblk#
	--, tu.extents
	, tu.blocks
	, tu.blocks * (select block_size from dba_tablespaces where tablespace_name = tu.tablespace) bytes
	--, tu.segrfno#
from v$tempseg_usage tu
order by tu.username
/

