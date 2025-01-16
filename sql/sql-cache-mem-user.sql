
-- sql-workarea-memory-user.sql
-- Jared Still 2022
-- show current SQL cache consumed by user and sql_id

set pagesize 100
set linesize 200 trimspool off
set tab off

col sql_id format a13 head 'SQL ID'
col min_memory_used format 99,999,999,999 head 'MIN|MEMORY|USED'
col max_memory_used format 99,999,999,999 head 'MAX|MEMORY|USED'
col avg_memory_used format 99,999,999 head 'AVG|MEMORY|USED'
col username format a30

break on username skip 1 on report
compute sum of min_memory_used on username
compute sum of min_memory_used on report
compute sum of max_memory_used on username
compute sum of max_memory_used on report
compute sum of avg_memory_used on username
compute sum of avg_memory_used on report


with sql_ids as (
	select distinct user_id, sql_id
	from v$active_session_history
),
workarea as (
	select
		a.sql_id
		, u.username
		, a.last_memory_used
	from v$sql_workarea a
	join sql_ids s on s.sql_id = a.sql_id
	join dba_users u on u.user_id = s.user_id
	where a.last_memory_used != 0
)
select
	w.username
	, w.sql_id
	, min(w.last_memory_used) min_memory_used
	, max(w.last_memory_used) max_memory_used
	, floor( (min(w.last_memory_used) + max(w.last_memory_used)) / 2) avg_memory_used
from workarea w
group by w.username, w.sql_id
order by  username,sql_id
/

