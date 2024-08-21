
-- gen-tbs-ddl.sql
-- Jared Still
-- generate tablespace ddl
-- uses the first file from the USERS tablespace for location
-- this is appropriate when specifying filenames manually
-- ie. non-OMF

-- comment out the newtbs and maxtotalsize as appropriate

def newtbs='DATA'

-- 1.5T for DATA
-- specify in bytes
-- ie.  select (1.5 * power(2,40)) from dual;
def maxtotalsize=1649267441664

def blocksize=8192
-- maximum file size is 32G - 1 block
-- for 8k blocks
-- maxfilesize =	 ( ( (32 * power(2,30)) / 8192) -1) * 8192
--
-- each datafile requirees 2 minutes and 35 seconds to create


ttitle off
btitle off
set echo off pause off feed off
set head off verify off timing off
set pagesize 0
set linesize 300 trimspool on

set term on
set num 15

col maxfilesize new_value maxfilesize noprint
select ( ( (32 * power(2,30)) / &blocksize) -1) * &blocksize maxfilesize from dual;

col totaldatafiles new_value totaldatafiles noprint
select floor(&maxtotalsize / ( 32 * power(2,30) )) totaldatafiles from dual;

col totalruntime new_value totalruntime  noprint
select trim(155 * &totaldatafiles) totalruntime from dual;

prompt
prompt tbs: &newtbs
prompt
prompt blocksize: &blocksize
prompt maxtotalsize: &maxtotalsize
prompt maxfilesize: &maxfilesize
prompt totaldatafiles: &totaldatafiles
prompt totalruntime: &totalruntime
prompt

spool &newtbs-tbs-ddl.sql

prompt set echo off

prompt
prompt estimated run time is &totalruntime seconds
prompt

prompt
prompt set timing on echo on head on feed on
prompt

prompt create tablespace &newtbs	 extent management local segment space management auto datafile

with template as (
select
	substr(file_name,1,instr(file_name,'USERS')-1) file_name
from dba_data_files
where tablespace_name = 'USERS'
	and file_id = (
		select min(file_id)
		from dba_data_files
		where tablespace_name = 'USERS'
	)
)
select
	-- level is a pseudo column created by 'connect by'
	q'[	']' || file_name || '&newtbs' || lpad(level,3,'0') || q'[.DBF' size ]' || to_char(&maxfilesize)
	-- to comma or not to comma
	|| case level when  &totaldatafiles then '' else ',' end
from template
-- a SQL trick to create multiple rows
connect by level <= &totaldatafiles
/

prompt /
prompt

spool off

set feed on head on timing on

set pagesize 100
set linesize 200

