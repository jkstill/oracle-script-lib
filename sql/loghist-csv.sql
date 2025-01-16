
-- loghist-csv.sql
-- Jared Still still@pythian.com jkstill@gmail.com
-- dump archive log history, with timing, to CSV

-- floor() is used in the SQL due to an odd rounding error that occasionally occurs

set pause off
set echo off
set timing off
set trimspool on
set feed on term on echo off verify off

clear col
clear break
clear computes

btitle ''
ttitle ''

btitle off
ttitle off

set newpage 1

set pages 0 lines 200 term on feed off 

col rpt_name new_value rpt_name noprint

-- output to file controlled from loghist-csv.sh
--select 'loghist-' || name || to_char(sysdate,'yyyymmdd-hh24miss') || '.csv' rpt_name from v$database;
--spool &rpt_name

prompt instance,thread#,sequence#,first_time,next_time,time_to_switch,completion_time,arch_write_time,bytes

with lograw as (
   select
      lc.sequence#
		,lc.inst_id
      ,lc.thread#
      ,lc.first_change#
      ,lc.first_time
		,lc.first_time - lag(lc.first_time,1) over(partition by inst_id,thread# order by sequence#) time_since_switch
   from gv$log_history lc
),
loghist as (
select
	inst_id
   , sequence#
   , first_change#
   , thread#
   , first_time
   -- get days portion of time since last log switch
   , to_char(trunc(time_since_switch))
      || ':'
      -- get hours portion of time since last log switch
      || to_char(trunc(sysdate)+time_since_switch,'hh24:mi:ss') time_to_switch
   from lograw
	order by first_time, inst_id
)
select
   h.inst_id
   ||','|| a.thread#
   ||','|| a.sequence#
   ||','|| to_char(h.first_time,'yyyy-mm-dd hh24:mi:ss')
   ||','|| to_char(a.next_time,'yyyy-mm-dd hh24:mi:ss')
   ||','|| h.time_to_switch
   ||','|| to_char(a.completion_time,'yyyy-mm-dd hh24:mi:ss')
   ||','|| floor((a.completion_time - a.next_time) * 86400)
   ||','|| a.blocks * block_size
from loghist h
   , gv$archived_log a
where a.inst_id = h.inst_id
	and a.thread# = h.thread#
   and a.sequence# = h.sequence#
   and a.FIRST_CHANGE# = h.FIRST_CHANGE#
   and a.dest_id = 1
   -- less than 1 minute
   --and substr(h.time_to_switch,1,8)  = '0:00:00:'
order by 1
/

--spool off


