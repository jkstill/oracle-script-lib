
@@clears
set line 200 trimspool on
col username Format a25
col tablespace format a15
col tmp_space format a10 head 'TEMP|SPACE'
col created format a20
col lock_date format a20 head 'LOCK|DATE'
col expiry_date format a19 head 'EXPIRY|DATE'
col profile format a10
col password_versions format a16 head 'PASSWORD|VERSIONS'
col proxy_only_connect head 'PRXY|ONLY' format a4
col authentication_type head 'AUTH|TYPE' format a10
col oracle_maintained head 'ORCL|MAINT' format a5

col cuser noprint new_value WhichUser
PROMPT "Info for which user? - ";
set term off feed off
select '&1' cuser from dual;
set term on feed on

define v_nls_date_format='yyyy-mm-dd hh24:mi:ss'

/*

No direct connection possible
  alter user test no authentication;


Can connect, but only through proxy
  alter user test proxy only connect;
*/


col use_12c_feature new_value use_12c_feature noprint
col use_11g_feature new_value use_11g_feature noprint

set term off feed off

@oversion_major

select
	case when to_number('&v_oversion_major') >= 12
	then ''
	else '--'
	end use_12c_feature
from dual;

select
	case when to_number('&v_oversion_major') >= 11
	then ''
	else '--'
	end use_11g_feature
from dual;

set term on feed on
 
select	
	username 
	, default_tablespace TABLESPACE
	, temporary_tablespace TMP_SPACE
	, to_char(created,'&v_nls_date_format') created
	, profile
	&use_12c_feature , proxy_only_connect
	&use_11g_feature , password_versions
	&use_11g_feature , authentication_type
	-- &use_12c_feature , oracle_maintained
	, to_char(lock_date,'&v_nls_date_format') lock_date
	, to_char(expiry_date,'&v_nls_date_format') expiry_date
from dba_users
where username like upper('&WhichUser%') escape '\'
	&use_12c_feature and oracle_maintained != 'Y'
order by username
/

undef 1

