
set linesize 250 trimspool on
set pagesize 100

col os_username format a20
col username format a20
col action_name format a24
col audit_action format a15
col ses_actions format a6 head 'ACTION'
col object format a40
col sql_text format a40 wrap
col comment_text format a40 wrap


with aud_actions as (
	select rownum id, column_value audit_action
	from (
		table(
			sys.odcivarchar2list( 'ALTER', 'AUDIT', 'COMMENT', 'DELETE', 'GRANT', 'INDEX', 'INSERT', 'LOCK', 'RENAME', 'SELECT', 'UPDATE', 'REFERENCES', 'EXECUTE')
		)
	)
)
select aud.username, aud.timestamp, aud.action_name
	--, aud.ses_actions
	--, regexp_instr(aud.ses_actions,'[FSB]') pos
	, replace(aud.ses_actions,'-','') ses_actions
	, ac.audit_action
	, trim(aud.owner) ||'.'|| trim(aud.obj_name) object
	, sql_text, comment_text
from dba_audit_trail aud
join aud_actions ac on ac.id = regexp_instr(aud.ses_actions,'[FSB]')
--where trunc(current_timestamp) = trunc(timestamp)
where to_date('2022-07-14','yyyy-mm-dd') = trunc(timestamp)
order by timestamp
/
