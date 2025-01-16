
-- oracle-exclude-schema.sql
-- show oracle owned schemas in 11g+
-- these are often excluded for some queries, exports, etc
--  2017
-- Jared Still  jkstill@gmail.com
-- see oracle-exclude-inline.sql for sql that can be included via @@
-- 

select name schema_to_exclude
from system.LOGSTDBY$SKIP_SUPPORT
where action = 0
order by schema_to_exclude
/

