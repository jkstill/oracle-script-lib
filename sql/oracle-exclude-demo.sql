
-- oracle-exclude-demo.sql
-- demo of using oracle-exclude-inline.sql in 11g+
--  2017
-- Jared Still  jkstill@gmail.com

with
@oracle-exclude-inline
select username
from dba_users u
left join excluded_schemas e on e.schema_to_exclude = u.username
where e.schema_to_exclude is null
order by 1
/

