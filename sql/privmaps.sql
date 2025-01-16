
-- privmaps.sql
-- Jared Still - 
-- 2016-06-24
-- this will show system privileges that are granted through roles

col which_user new_value which_user noprint
var which_user varchar2(30)

prompt Username:
set feed off term off echo off
select upper('&1') which_user from dual;
set feed on term on

col privileged_role format a40 head 'PRIVILEGED ROLE'
col granted_to format a30 head 'GRANTED TO'
col privilege format a30
set line 150

var v_grantee number

begin
	:which_user := '&&which_user';

	select user_id into :v_grantee
	from dba_users
	where username = :which_user;
end;
/

print :v_grantee

break on privileged_role skip 1 on granted_to skip 1

with privmap as (
select grantee#,privilege#,level padsize, rownum rownumber
from sys.sysauth$
-- privilege# = grantee# when the privilege is a role
-- system privileges have a value < 0
-- while roles appear at > 0
connect by grantee#=prior privilege#
	and privilege#>0
start with (grantee#=:v_grantee or grantee#=1) and privilege#>0
)
select
	--p.grantee#
	 lpad('  ',2*(padsize-1)) || grantees.name privileged_role
	--, p.privilege#
	, grantors.name granted_to
	, sp.privilege privilege
from privmap p
	, sys.user$ grantors
	, sys.user$ grantees
	, dba_sys_privs sp
where grantors.user# = p.grantee#
and grantees.user# = p.privilege#
and sp.grantee = grantees.name
order by p.rownumber
/

undef 1

