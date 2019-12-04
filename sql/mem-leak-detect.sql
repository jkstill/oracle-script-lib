

-- mem-leak-detect.sql
-- look for memory leak candidates


set linesize 200 trimspool on
set pagesize 100

col growth_times format 99999
col min_pga format 99,999,999,999
col max_pga format 99,999,999,999
col module format a30


with data as (
select distinct h.session_id
	, h.session_serial#
	, h.program
	, h.module
	, min(h.pga_allocated) over ( partition by h.session_id, h.session_serial#) min_pga
	, max(h.pga_allocated) over ( partition by h.session_id, h.session_serial#) max_pga
from  dba_hist_active_sess_history h
)
select d.* , to_char(d.max_pga / d.min_pga,'99999') || 'x'  growth_times
from data d
where max_pga > 5*min_pga
order by session_id, session_serial#
/
