
-- show_check_cons.sql
-- show non system generated check constraints
-- ie. those created due to NOT NULL in table DDL


select owner, table_name, constraint_name, search_condition
from dba_constraints
where constraint_type = 'C'
and constraint_name not like 'SYS_C%'
-- not a comprehensive list
and owner not in ('SYS','SYSTEM','APEX_030200','SYSMAN','MDSYS','DBSNMP','ORDSYS','ORDDATA','WMSYS','OWBSYS','FLOWS_FILES','OLAPSYS','CTXSYS','RCAT')
order by owner
/
