
-- user-modifiable-parms.sql
-- Jared Still 2023

-- show all parameters that are boolean or integer and can be modified per session
-- these can be modified in another session via:
--   dbms_system.set_bool_param_in_session
--   dbms_system.set_int_param_in_session

col name format a40
col value format a20

set linesize 200 trimspool on
set pagesize 100


select
	name
	, value
	, decode(isdefault, 'TRUE','Y','FALSE','N','?') isdefault
	, decode(
		isses_modifiable
		,'TRUE','Y'
		,'FALSE','N'
		,'?') isses_modifiable
	, decode(
		issys_modifiable
		,'FALSE','N'
		,'DEFERRED','D'
		,'IMMEDIATE','I'
		,'?') issys_modifiable
from v$parameter2
where 1=1
and (
	value in ('TRUE','FALSE')
	or
	regexp_like(value,'^[[:digit:]]+$') 
)
and isses_modifiable = 'TRUE'
order by name
/


