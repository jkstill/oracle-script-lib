
-- uifk.sql 
-- format data from user_uifk

@columns

col constraint_name format a30 head 'CONSTRAINT'
col columns format a60
set line 130

break on table_name skip 1

select table_name, constraint_name, columns
from user_uifk
order by 1,2,3
/

