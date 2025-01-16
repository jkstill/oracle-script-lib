
col username format a30
col user_cached_cursor_count format 99,999,999 head 'USER|CACHED|CURSOR|COUNT'

col min_memory_used format 99,999,999,999 head 'MIN|MEMORY|USED'
col max_memory_used format 99,999,999,999 head 'MAX|MEMORY|USED'
col avg_memory_used format 99,999,999 head 'AVG|MEMORY|USED'
col cursor_count_20 format 99,999,999 head 'CACHED|CURSOR|COUNT|20%'
col cursor_count_50 format 99,999,999 head 'CACHED|CURSOR|COUNT|50%'
col projected_cache_mem_20 format 99,999,999 head 'PROJECTED|MEMORY|INCREASE|20%'
col projected_cache_mem_50 format 99,999,999 head 'PROJECTED|MEMORY|INCREASE|50%'

break on report
compute sum of min_memory_used on report
compute sum of max_memory_used on report
compute sum of avg_memory_used on report
compute sum of projected_cache_mem_20 on report
compute sum of projected_cache_mem_50 on report


with cached_cursor_count as
(
   select
		distinct u.username 
		, sum(c.sess_cached_cursor_count) over(partition by u.username) user_cached_cursor_count
   from
   (
      select
			sid
         , count(s.value) sess_cached_cursor_count
      from
         v$statname n,
         v$sesstat s
      where
         n.name = 'session cursor cache count' and
         s.statistic# = n.statistic#
		group by sid
   ) c
	join v$session s on s.sid = c.sid
	join dba_users u on u.user_id = s.user#
),
sql_ids as (
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
),
cursor_mem as (
	select
		w.username
		, min(w.last_memory_used) min_memory_used
		, max(w.last_memory_used) max_memory_used
		, floor( (min(w.last_memory_used) + max(w.last_memory_used)) / 2) avg_memory_used
	from workarea w
		group by w.username
	order by  username
)
select
	m.username
	, c.user_cached_cursor_count
	, m.min_memory_used
	, m.max_memory_used
	, m.avg_memory_used
	-- based on max memory
	, floor(c.user_cached_cursor_count * 1.20) cursor_count_20
	, m.max_memory_used * 1.20 projected_cache_mem_20
	, floor(c.user_cached_cursor_count * 1.50) cursor_count_50
	, m.max_memory_used * 1.50 projected_cache_mem_50
from cursor_mem m
join cached_cursor_count c on c.username = m.username
/
