
-- sys_context.sql 
-- show some examples of sys_context function usage

-- see sys_context docs for more

select sys_context('userenv','authenticated_identity') authenticated_identity from dual;

select sys_context('userenv','enterprise_identity') enterprise_identity from dual;

select sys_context('userenv','authentication_method') authentication_method from dual;

select sys_context('userenv','current_schema') current_schema from dual;

select sys_context('userenv','current_user') current_user from dual;

select sys_context('userenv','session_user') session_user from dual;

select sys_context('userenv','sid') sid from dual;

select sys_context('userenv','terminal') terminal from dual;

select sys_context('userenv','db_name') db_name from dual;

select sys_context('userenv','db_domain') db_domain from dual;

select sys_context('userenv','instance') instance from dual;

select sys_context('userenv','instance_name') instance_name from dual;

select sys_context('userenv','ip_address') ip_address from dual;

select sys_context('userenv','isdba') isdba from dual;

select sys_context('userenv','language') language from dual;

