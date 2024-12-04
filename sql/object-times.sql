
-- object-times.sql
-- Description: This script will display the creation, modification and structure change times for all objects in the schema.

col v_username new_value v_username noprint

set feedback on verify off echo off term on feedback on

prompt
prompt Username? :
prompt
set termout off feed off
select upper('&1') v_username from dual;
set termout on feed on


col name format a30
col ctime format a22
col mtime format a22
col stime format a22

set linesize 200 trimspool on
set pagesize 100


clear breaks
break on object_type skip 1

select
	case 
		when type# = 1 then 'INDEX'
		when type# = 2 then 'TABLE'
		when type# = 3 then 'CLUSTER'
		when type# = 4 then 'VIEW'
		when type# = 5 then 'SYNONYM'
		when type# = 6 then 'SEQUENCE'
		when type# = 7 then 'PROCEDURE'
		when type# = 8 then 'FUNCTION'
		when type# = 9 then 'PACKAGE'
		when type# = 11 then 'PACKAGE BODY'
		when type# = 12 then 'TRIGGER'
		when type# = 13 then 'TYPE'
		when type# = 14 then 'TYPE BODY'
		when type# = 19 then 'TABLE PARTITION'
		when type# = 20 then 'INDEX PARTITION'
		when type# = 21 then 'LOB'
		when type# = 22 then 'LIBRARY'
		when type# = 23 then 'DIRECTORY'
		when type# = 24 then 'QUEUE'
		when type# = 28 then 'JAVA SOURCE'
		when type# = 29 then 'JAVA CLASS'
		when type# = 30 then 'JAVA RESOURCE'
		when type# = 32 then 'INDEXTYPE'
		when type# = 33 then 'OPERATOR'
		when type# = 34 then 'TABLE SUBPARTITION'
		when type# = 40 then 'LOB PARTITION'
		when type# = 44 then 'CONTEXT'
		when type# = 46 then 'RULE SET'
		when type# = 47 then 'RESOURCE PLAN'
		when type# = 48 then 'CONSUMER GROUP'
		when type# = 55 then 'XML SCHEMA'
		when type# = 56 then 'JAVA DATA'
		when type# = 57 then 'EDITION'
		when type# = 59 then 'RULE'
		when type# = 62 then 'EVALUATION CONTEXT'
		when type# = 66 then 'JOB'
		when type# = 67 then 'PROGRAM'
		when type# = 68 then 'JOB CLASS'
		when type# = 69 then 'WINDOW'
		when type# = 72 then 'SCHEDULER GROUP'
		when type# = 74 then 'SCHEDULE'
		when type# = 77 then 'UNDEFINED'
		when type# = 78 then 'UNDEFINED'
		when type# = 101 then 'DESTINATION'
		when type# = 115 then 'UNIFIED AUDIT POLICY'
		else 'UNKNOWN'
	end object_type
	, o.name
	, o.ctime
	, o.mtime
	, o.stime
from sys.obj$ o
where  owner# = ( select user# from sys.user$ where name = '&v_username')
order by object_type, o.name
/


