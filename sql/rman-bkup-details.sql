
-- rman-bkup-details.sql
-- Andre Araujo -  2011
-- https://www..com/blog/viewing-rma-jobs-status-and-output/
--
-- first run rman-bkup-status.sql 
-- use the session_recid and session_stamp values to run this report.
-- can be called with rman-bkup-details.sql <value for session_recid> <value for session_stamp>

col session_recid new_value session_recid noprint
col session_stamp new_value session_stamp noprint

prompt SESSION_RECID: 
set verify off feed off term off
select '&1' session_recid from dual;

set term on feed on

prompt
prompt SESSION_STAMP: 
prompt
set feed off term off
select '&2' session_stamp from dual;

set term on feed on


set lines 220 trimspool off
set pages 1000
col backup_type for a4 heading "TYPE"
col controlfile_included heading "CF?"
col incremental_level heading "INCR LVL"
col pieces for 999 heading "PCS"
col elapsed_seconds heading "ELAPSED|SECONDS"
col device_type for a10 trunc heading "DEVICE|TYPE"
col compressed for a4 heading "ZIP?"
col output_mbytes for 9,999,999 heading "OUTPUT|MBYTES"
col input_file_scan_only for a4 heading "SCAN|ONLY"

select
  d.bs_key, d.backup_type, d.controlfile_included, d.incremental_level, d.pieces,
  to_char(d.start_time, 'yyyy-mm-dd hh24:mi:ss') start_time,
  to_char(d.completion_time, 'yyyy-mm-dd hh24:mi:ss') completion_time,
  d.elapsed_seconds, d.device_type, d.compressed, (d.output_bytes/1024/1024) output_mbytes, s.input_file_scan_only
from V$BACKUP_SET_DETAILS d
  join V$BACKUP_SET s on s.set_stamp = d.set_stamp and s.set_count = d.set_count
where session_recid = &SESSION_RECID
  and session_stamp = &SESSION_STAMP
order by d.start_time;


