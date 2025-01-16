
-- sess-optimizer-env.sql
-- show all optimizer settings for a session
-- Jared Still 2022

clear break

col username format a30
select inst_id, username, sid from gv$session
where username is not null
order by 1,2;

prompt
prompt INST_ID? :
prompt 

prompt
prompt SID? :
prompt 

col inst_id format 9999 head 'INST'
col sid format 999999 head 'SID'
col ID format 99999 
col name format a35
col sql_feature format a30
col isdefault format a4 head 'DEF|VAL?'
col value format a40 
col con_id format 9999 head 'CON|ID'

set linesize 200 trimspool on
set pagesize 100

break on sid skip 1

select 
	inst_id
	, sid
	, id
	, name
	, sql_feature
	, isdefault
	, value
	-- , con_id
from GV$SES_OPTIMIZER_ENV 
where name like '%statistics%'
	and inst_id = &&1
	and sid = &&2
order by inst_id, sid, name
/

--undef 1 2

