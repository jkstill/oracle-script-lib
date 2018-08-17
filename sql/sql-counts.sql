
-- sql-counts.sql
-- simple count of SQL_ID statements from ASH
-- 

-- which ever is an empty string indicates the mode used
define ash_mode=''
define awr_mode='--'


set pagesize 100

select sql_id, count(*) 
from 
	&ash_mode v$active_Session_history
	&awr_mode dba_hist_sqlstat
group by sql_id
order by 2
/
