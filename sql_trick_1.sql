
-- sql_trick_1.sql
-- inspired by Tanel Poders use of define vars
-- to control SQL flow
-- the defined vars are set by the level, which
-- will be 1 2 or 3
-- the defined vars just put a comment in the SQL

set line 120
col table_name format a30
col owner format a20
col column_name format a30

define dlevel=1

col skip_table new_value skip_table noprint
col skip_column new_value skip_column noprint

select decode('&&dlevel',3,'','--') skip_column from dual;
select decode('&&dlevel',1,'--','') skip_table from dual;


select 
	owner
	&&skip_table , table_name
	&&skip_column , column_name
from dba_tab_columns
group by 
	owner
	&&skip_table , table_name
	&&skip_column , column_name
order by
	owner
	&&skip_table , table_name
	&&skip_column , column_name
/


