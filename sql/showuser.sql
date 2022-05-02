
@@clears
set line 200 trimspool on
col USERNAME format a15;
col TABLESPACE format a15;
col TMP_SPACE format a10;
col created format a20
col lock_date format a20
col profile format a10

col cuser noprint new_value WhichUser
PROMPT "Info for which user? - ";
set term off feed off
select '&1' cuser from dual;
set term on feed on
 
select	
	username 
	, default_tablespace TABLESPACE
	, temporary_tablespace TMP_SPACE
	, to_char(created,'mm/dd/yyyy hh24:mi:ss') created
	, profile
	, to_char(lock_date,'mm/dd/yyyy hh24:mi:ss') lock_date
	, to_char(expiry_date,'mm/dd/yyyy hh24:mi:ss') expiry_date
from dba_users
where username like upper('&WhichUser%')
order by username
/

undef 1

