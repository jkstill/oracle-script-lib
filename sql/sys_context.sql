
-- sys_context.sql 
-- show some examples of sys_context function usage

-- see sys_context docs for more

select sys_context('userenv','authenticated_identity') authenticated_identity from dual;

select sys_context('userenv','enterprise_identity') enterprise_identity from dual;

select sys_context('userenv','authentication_method') authentication_method from dual;

select sys_context('userenv','current_schema') current_schema from dual;
select sys_context('userenv','current_schemaid') current_schema_id from dual;

select sys_context('userenv','current_user') current_user from dual;

select sys_context('userenv','session_user') session_user from dual;

-- CURRENT_SQL returns the first 4K bytes of the current SQL that triggered the fine-grained auditing event.
select sys_context('userenv','current_sql') current_sql from dual;

-- CURRENT_SQLn attributes return subsequent 4K-byte increments, where n can be an integer from 1 to 7, inclusive
select sys_context('userenv','current_sql1') current_sql1 from dual;

-- The length of the current SQL statement that triggers fine-grained audit or row-level security (RLS) policy functions or event handlers
select sys_context('userenv','current_sql_length') current_sql_length from dual;

-- role is one of the following: PRIMARY, PHYSICAL STANDBY, LOGICAL STANDBY, SNAPSHOT STANDBY.
select sys_context('userenv','database_role') database_role from dual;

select sys_context('userenv','db_name') db_name from dual;

select sys_context('userenv','db_unique_name') db_unique_name from dual;

-- Returns the source of a database link session.
select sys_context('userenv','dblink_info') dlink_info from dual;

-- IDENTIFIED BY password: LOCAL
-- IDENTIFIED EXTERNALLY: EXTERNAL
-- IDENTIFIED GLOBALLY: GLOBAL SHARED
-- IDENTIFIED GLOBALLY AS DN: GLOBAL PRIVATE
select sys_context('userenv','identification_type') identification_type from dual


-- Domain of the database as specified in the DB_DOMAIN initialization parameter
select sys_context('userenv','db_domain') db_domain from dual;

select sys_context('userenv','sid') sid from dual;

select sys_context('userenv','terminal') terminal from dual;


select sys_context('userenv','instance') instance from dual;

select sys_context('userenv','instance_name') instance_name from dual;

select sys_context('userenv','ip_address') ip_address from dual;

select sys_context('userenv','isdba') isdba from dual;

select sys_context('userenv','language') language from dual;

select sys_context('userenv','cdb_name') cdb from dual;
select sys_context('userenv','con_id') con_id from dual;
select sys_context('userenv','con_name') con_name from dual;
