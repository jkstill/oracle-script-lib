
col policy_name format a25
col audit_option format a40
col audit_condition format a100
set linesize 200 trimspool on
set pagesize 100

select policy_name, audit_option, audit_condition
from   audit_unified_policies
--where  policy_name =  'ORA_ACCOUNT_MGMT'
order by 1,2
/


