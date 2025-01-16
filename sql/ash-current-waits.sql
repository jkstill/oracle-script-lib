
-- ash-current-waits.sql
-- find the current top wait events per SQL by class and event
-- Jared Still -  jkstill@gmail.com

set pause off echo off 
set feed on term on 

set pagesize 200
set linesize 200 trimspool on

col wait_class format a20 head 'WAIT CLASS'
col event format a50 head 'EVENT'

-- in seconds - count == seconds in ASH, roughly
col class_time_waited_total format 999,999,990 head 'CLASS TIME|WAIT(s)|TOTAL'
col event_time_waited_total format 999,999,990 head 'EVENT TIME|WAIT(s)|TOTAL'

select distinct
	wait_class
	, event
	, count(time_waited) over (partition by wait_class )   class_time_waited_total
	, count(time_waited) over (partition by wait_class,event )   event_time_waited_total
from v$active_session_history h
where time_waited != 0
order by 3,4
/

