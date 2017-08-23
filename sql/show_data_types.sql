
-- show_data_type.sql

select owner, data_type, data_type_mod, count(*)
from dba_tab_columns
-- not a comprehensive list
-- this list should be in a standalone SQL and called as needed.
where  owner not in ('SYS','SYSTEM','APEX_030200','SYSMAN','MDSYS','DBSNMP','ORDSYS','ORDDATA','WMSYS','OWBSYS','FLOWS_FILES','OLAPSYS','CTXSYS','APPQOSSYS','EXFSYS')
group by owner, data_type, data_type_mod
order by owner, data_type
/
