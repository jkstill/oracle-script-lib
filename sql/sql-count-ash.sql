select sql_id, count(*) from gv$active_session_history group by sql_id order by 2
/
