
-- set-tracefile-id-external.sql
-- This script sets the tracefile_identifier in other sessions for a schema name.

/*

you may see this error

SQL> oradebug SETTRACEFILEID SQLTRACE
ORA-32522: restricted heap violation while executing ORADEBUG command: [kghalo bad heap ds] [0x0133BED74] [0x060172100]

This note says "Do not use oradebug settracefileid for remote processes"
Bug 25293381 - ORADEBUG command failed with ORA-32522: [KGHALO BAD HEAP DS] for remote processes (Doc ID 25293381.8)

However, the same error appears whether logged on remotely, or directly on the db server.

I believe it is a bug, as the tracefile identifier does get set correctly, despite the error.

*/


define tracefile_id = 'SQLTRACE'

whenever sqlerror exit 127

begin
	if user != 'SYS' then
		raise_application_error(-20000, 'This script must be run as SYS');
	end if;
end;
/

whenever sqlerror continue


clear col
clear break
clear computes

btitle ''
ttitle ''

btitle off
ttitle off

set newpage 1
set tab off

set pause off
set echo off
set timing off
set verify off

set feed on
set term on
set head on

set linesize 200 trimspool on
set pagesize 100

define tracefile_id = 'SQLTRACE'

col wuser new_value wuser noprint

prompt Set tracefile identifier for all sessions of which user?
set head off term off feed off
select '&1' wuser from dual;

spool _set-tracefile-id-external.sql

prompt set feed on term on echo on

select 'oradebug SETORAPID ' || p.pid || chr(10) || 'oradebug SETTRACEFILEID &tracefile_id'
	--, s.sid
	--, s.serial#
	--, p.pid pid
from v$session s, v$process p
where s.username = upper('&&wuser')
	and p.addr = s.paddr
order by sid
/

spool off

@  _set-tracefile-id-external.sql

set head on term on feed on off echo off



