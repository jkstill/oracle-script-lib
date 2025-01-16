
-- privileged-accounts.sql
-- Jared Still 2023
-- show roles and users with "ANY" privileges
-- skip Oracle Maintained accounts if possible:

/*
@privileged-accounts

GRANT
TYPE  GRANTEE                        PRIVILEGE
----- ------------------------------ ------------------------------
USER  EVS                            ANALYZE ANY
                                     ANALYZE ANY DICTIONARY
                                     MANAGE ANY QUEUE
3 rows selected.
*/

set linesize 200 trimspool on
col grantee_type format a5 head 'GRANTEE|TYPE'
col grantee format a30
col privilege format a30

col use_12c_feature new_value use_12c_feature noprint
col use_11g_feature new_value use_11g_feature noprint

set term off feed off verify off

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

break on grantee_type on grantee


with grantee_data as (
   select  'ROLE' grantee_type, role grantee
   from dba_roles r
   &use_12c_feature where r.oracle_maintained != 'Y'
   union all
   select 'USER' grantee_type,  username grantee
   from dba_users u
   &use_12c_feature where u.oracle_maintained != 'Y'
)
select grantee_type, sp.grantee, sp.privilege
from dba_sys_privs sp
join grantee_data g on g.grantee = sp.grantee
   and sp.privilege like '%ANY%'
order by grantee_type, sp.grantee, sp.privilege
/

