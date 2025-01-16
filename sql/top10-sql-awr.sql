-- top10-sql-awr.sql
-- top 100 sql statements from AWR for past 30 days
-- does not show instance numbers, but could do so with listagg()
-- Jared Still -  jkstill@gmail.com
-- 2017-11-21

@clear_for_spool

spool top10-sql-awr.csv

prompt sql_id,sql_id_count

with topsql as (
	select distinct sql_id, count(sql_id) over (partition by sql_id ) sql_id_count
	from dba_hist_active_sess_history h
	join dba_hist_snapshot s on s.snap_id = h.snap_id
		and s.dbid = h.dbid
		and s.instance_number = h.instance_number
	where s.begin_interval_time >= systimestamp - interval '30' day
	order by 2 desc
)
select sql_id ||','|| sql_id_count
from topsql
where rownum <= 100
/

spool off

@clears

