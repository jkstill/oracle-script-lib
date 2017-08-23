
-- gen_uifk.sql
-- Jared Still 
-- uifk views adapted from a script by Tom Kyte that 
-- is used to find unindexed Foreign Keys
-- http://osi.oracle.com/~tkyte/unindex/unindex.sql


col default_tablespace new_value default_tablespace noprint 
col username new_value username noprint

prompt Find unindexed foreign keys for a user, and 
prompt generate indexes for them
prompt parms are username and tablespace
prompt e.g. @uifk_gen SCOTT USERS
prompt

prompt Username:
set feed off term off
select upper('&1') username from dual;
set feed on term on

prompt Tablespace Name:
set feed off term off
select '&2' default_tablespace from dual;
set feed on term on

@clear_for_spool

set line 400

spool ./_fk_indexes.sql

prompt set echo on
prompt spool ./_fk_indexes.log

--select a.table_name, a.constraint_name, a.columns
select 'create index '
	|| a.owner || '.'
	|| substr(a.constraint_name,1,30) 
	|| ' on "' || a.table_name ||'"'
	|| '(' || a.columns || ') '
	|| 'PCTFREE 5 '
	|| 'tablespace ' 
	|| '&&default_tablespace;'
from dba_uifk a
where owner = '&&username'
/

prompt spool off
prompt set echo off

spool off

@clears

