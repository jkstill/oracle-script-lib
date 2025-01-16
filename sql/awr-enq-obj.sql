
-- awr-enq-obj.sql
-- show enqueue objects and sql to find the hot block
-- Jared Still 2023
-- currently filtered on enqueue waits

set linesize 250 trimspool on
set pagesize 100
set tab off

col username format a20
col my_sql format a100
col sample_time format a25
col object format a50
col event format a35
col row_count format 9,999,999 head 'EVENT|COUNT'
--col time_waited format a10 head 'SUM|TIME|WAITED'
col time_waited format a10 head 'MAX|TIME|WAITED'
col sql_id format a13

with awrdata as (
	select /*+ no_merge */	distinct
		user_id
		, event
		, sql_id
		, current_obj#
		, current_file#
		, current_block#
		, current_row#
		, count(*) over (partition by user_id, event, sql_id, current_obj#, current_file# , current_block#) row_count
		, case when session_state = 'WAITING' then
			-- not completely accurate
			-- sessions that waited more than 1 second will have 1 entry per second, inflating this value
			-- the last row for any series of waits per a sql and session will have the full wait time
			-- also if there rae multiple rows being hit from the block, the time waited will appear the same for each row
			-- the time_waited as used here should be considered as an indicator of a hot block
			-- try max() rather than sum()
			max(time_waited) over (partition by user_id, event, sql_id, current_obj#, current_file# , current_block#)
			else 0
			end time_waited
	from dba_hist_active_sess_history
	--where event = 'enq: IV -	 contention'
	where sql_id is not null
	and event like 'enq: %'
	and sample_time >= cast(trunc(sysdate) - 14 as timestamp)
)
select
	--to_char(sample_time,'yyyy-mm-dd hh24:mi:ss.ff') sample_time
	--, session_id
	u.username
	, h.event
	, sql_id
	, h.row_count * 10 row_count -- 10 second ASH sample
	, to_char(h.time_waited/1000000,'99990.990') time_waited
	-- , h.current_file#
	-- , h.current_block#
	, case when o.object_type is null then 'NA'
		else o.object_type || ': ' || o.owner || '.' || o.object_name
		end object
	, case when h.current_obj# >1 then
		case when o.object_type = 'TABLE' then
			'select * from ' || o.owner || '.' || o.object_name || ' where rowid = ''' ||	 dbms_rowid.rowid_create(1,h.current_obj#,h.current_file#,h.current_block#,h.current_row#) || ''''
		when o.object_type = 'INDEX' then
			'alter system dump datafile ' || h.current_file# || ' block ' || h.current_block#
		else 'Not yet available for ' || o.object_type
		end
	else 'NA'
	end my_sql
from awrdata h
left outer join dba_objects o on o.object_id = h.current_obj#
join dba_users u on u.user_id = h.user_id
--order by row_count desc
order by time_waited desc
fetch first 20 rows only
/

