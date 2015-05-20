
col owner format a15
col trigger_name format a30 head 'TRIGGER'
col triggering_event format a34 head 'TRIGGERING EVENT'
col trigger_body format 60 head 'TRIGGER BODY'

set pagesize 60
set linesize 200 trimspool on

select
	owner
	, status
	, trigger_name
	, trigger_type
	, triggering_event
	, trigger_body
from dba_triggers
where TRIGGERING_EVENT = 'LOGON '
	or  TRIGGERING_EVENT = 'LOGON'
order by owner, trigger_name
/


