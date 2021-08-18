
@clears
set line 140
set pagesize 60

col member format a50 head 'MEMBER'
col group# format 999 head 'GRP'
col thread# format 999 head 'THR'
col sequence# format 999999 head 'SEQ'
col group_status format a8 head 'GROUP|STATUS'
col member_status head 'MEMBER|STATUS'
col systime format a18 head 'SYSTEM TIME'
col bytes format 99,999,999,999 head 'SIZE IN BYTES'
col first_time format a20 head 'TIME OF FIRST SCN'
col archived head 'ARCH?' format a5
col inst_id format 9999  head 'INST|ID'

clear break
break on thread# skip 1

select
	--l.inst_id,
	l.thread#,
	l.group#,
	sequence#,
	bytes,
	member,
	l.status group_status,
	f.status member_status,
	l.archived,
	to_char(first_time,'yyyy-mm-dd hh24:mi:ss') first_time
from v$log l, v$logfile f
where l.group# = f.group#
--and l.inst_id = f.inst_id
order by thread#,group#
/


