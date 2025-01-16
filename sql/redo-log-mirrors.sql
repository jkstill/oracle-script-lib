
-- redo-log-mirrors.sql
-- Jared Still - jkstill@gmail.com
-- 2021
-- requires SYSDBA access

col fnfno head 'REDO GROUP'
col fnnam head 'LOGFILE' format a60
set linesize 200 trimspool on
set pagesize 100

clear break
break on thread# skip 1 on group# skip 1

with mirrors as (
select
	--inst_id
	fnfno
 	--, FNFWD
	--, lpad(radix.to_bin(FNFWD),8,'0') FNFWD_bin
 	--, FNBWD
	--, lpad(radix.to_bin(FNBWD),8,'0') FNBWD_bin
	, decode(FNBWD,0,'Side 1','Side 2') mirror_side
	--, decode(bitand(fn flg,8),0,' ONLINE','STANDBY')
	, fnnam
	--, decode(bitand(fnflg, 32),0,'NO','YES')
from x$kccfn
where fnnam is not null
	and fntyp=3
), 
logfiles as(
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
)
select
	l.thread#
	, l.group#
	, m.mirror_side
	, l.sequence#
	, l.bytes
	, l.member
	, l.group_status
	, l.member_status
	, l.archived
from mirrors m
join logfiles l on l.group# = m.fnfno
	and l.member = m.fnnam
order by l.thread#, l.group#, m.mirror_side
/

