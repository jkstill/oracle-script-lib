-- top10-sql-ash.sql
-- top 100 sql statements from ASH
-- does not show instance numbers, but could do so with listagg()
-- Jared Still -  jkstill@gmail.com
-- 2017-11-21

@clear_for_spool

spool top10-sql-ash.csv

prompt sql_id,sql_id_count

with topsql as (
	select distinct sql_id, count(sql_id) over (partition by sql_id ) sql_id_count
	from gv$active_session_history h
	order by 2 desc
)
select sql_id ||','|| sql_id_count
from topsql
where rownum <= 100
/

spool off

@clears
