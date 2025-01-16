
-- ash-events.sql
-- get ash events for a sql_id within a time range
-- sql_id and range currently hardcoded
--
-- Jared Still 2017-11-08   jkstill@gmail.com

var v_sql_id varchar2(13)


prompt sql_id: 

col u_sql_id new_value u_sql_id noprint

set feed off term off
select '&1' u_sql_id from dual;
set feed on term on

exec :v_sql_id := '&u_sql_id'

set linesize 200 trimspool on
set pagesize 100

col sample_time format a26
col inst_id format 999999
col session_id format 999999
col session_serial# format 999999
col event format a60
col event_count format 99,999,990

select sample_time, inst_id, session_id, session_serial#, event, count(*) event_count
from gv$active_session_history h
where h.sql_id = :v_sql_id
and h.sample_time > sysdate - (2/24)
and h.event is not null
group by sample_time, inst_id, session_id, session_serial#, event
order by sample_time, inst_id, session_id, session_serial#, event
/

--/*

-- summary view

select  inst_id, event, count(*) event_count
from gv$active_session_history h
where h.sql_id = :v_sql_id
and h.sample_time > sysdate - (2/24)
and h.event is not null
group by inst_id, event
order by count(*);


--*/


undef 1


