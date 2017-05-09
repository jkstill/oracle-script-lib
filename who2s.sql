
-- who2s.sql
-- less detail than who2.sql
-- useful for calling from other scripts
-- to get SID and SERIAL#


col username heading 'USERNAME' format a10
col sessions heading 'SESSIONS'
col sid heading 'SID' format 99999
col status heading 'STATUS' format a10
col machine format a10 head 'MACHINE'
col serial# format 99999 head 'SERIAL#'
col osuser format a7

set recsep off term on pause off verify off echo off
set line 200
set trimspool on

clear break
break on username skip 1

select 
	s.username, 
	s.sid, 
	s.serial#,
	s.status, 
	s.machine, 
	s.osuser
from v$session s, v$process p
where s.username is not null
	and p.addr = s.paddr
order by username, sid
;

set recsep wrapped

