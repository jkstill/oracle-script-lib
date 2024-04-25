
-- ua-actions.sql
-- requires SYS access

col type format 9999
col component format a30
col action format a30
col name format a30

select 
	--type
	component
	--, action
	, name
from sys.all_unified_audit_actions
order by 1,2
/

