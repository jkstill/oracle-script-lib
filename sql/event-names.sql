
-- event-names.sql
-- show current events (;
-- and parameters

/*

SYSDBA#  select distinct(wait_class) from v$event_name order by 1;

WAIT_CLASS
--------------
Administrative
Application
Cluster
Commit
Concurrency
Configuration
Idle
Network
Other
Queueing
Scheduler
System I/O
User I/O

*/

@clears

set pagesize 100
set linesize 210 trimspool on
col name format a60
col wait_class format a14
col parameter1 format a50
col parameter2 format a30
col parameter3 format a25


select 
	wait_class
	, name
	, parameter1
	, parameter2
	, parameter3
from v$event_name
where wait_class in (
	'dummy' 
	, 'Administrative'
	, 'Application'
	, 'Cluster'
	, 'Commit'
	, 'Concurrency'
	, 'Configuration'
	, 'Idle'
	, 'Network'
	, 'Other'
	, 'Queueing'
	, 'Scheduler'
	, 'System I/O'
	, 'User I/O'
)
-- this is here in case the list of wait classes expands
-- comment out for filtering
or wait_class like '%'
--where name like 'enq: TM%'
order by wait_class, name
/


