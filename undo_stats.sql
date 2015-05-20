
-- undo_stats.sql
-- as seen in ORA-01555 When Max Query Length Is Less Than Undo Retention [ID 1131474.1]
--
-- look for ORA-1555 when MAXQUERYLEN < TUNED_UNDORETENTION
--

set pagesize 25
set linesize 200 trimspool on

column tablespace_name format a15
column unxpstealcnt heading "# Unexpired|Stolen"
column expstealcnt heading "# Expired|Reused"
column ssolderrcnt heading "ORA-1555|Error"
column nospaceerrcnt heading "Out-Of-space|Error"
column maxquerylen heading "Max Query|Length"

select 
	u.inst_id
	, t.name tablespace_name
	, u.begin_time
	, u.end_time
	, u.unxpstealcnt
	, u.expstealcnt
	, u.ssolderrcnt
	, u.nospaceerrcnt
	, u.maxquerylen
	, u.tuned_undoretention
from gv$undostat u
join v$tablespace t on t.ts# = u.undotsn
order by end_time
/



