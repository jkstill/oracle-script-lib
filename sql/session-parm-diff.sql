
-- session-parm-diff.sql
-- Jared Still 2023
-- show which parameter differ from system defaults
-- note: will not capture 'hidden' parameters, as SYSDBA permissions are required for that

/*

Name                           Session Parameter              System Parameter
------------------------------ ------------------------------ ------------------------------
timed_os_statistics            60                             0
statistics_level               ALL                            TYPICAL

2 rows selected.
*/

col name format a30 head 'Name'
col session_parameter format a30 head 'Session Parameter'
col system_parameter format a30 head 'System Parameter'

set pagesize 100
set line 200 trimspool on

select 
	p.name
	, p.value session_parameter
	, s.value system_parameter	
from v$parameter p 
join v$system_parameter s
	on s.name = p.name
where s.value != p.value
/

