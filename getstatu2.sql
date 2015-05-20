

set echo off verify off pause off feed off

--set echo on

var statname varchar2(64);

clear col
clear comp
clear break

col cstatname new_value ustatname noprint
prompt Statistic Name ( Partial OK ): 
set term off echo off feed off
select '&1' cstatname from dual;
set term on feed on

col sid format 999 head 'SID'
col name format a40
col valuesum format 9999,999,999,999 head 'SUM OF STAT VALUE'
col username format a10 head 'USERNAME'

--break on username
break on username skip 1 on sid skip 1


select 
	sess.username,
	stat.sid,
	name.name name, 
	sum(stat.value) valuesum
from v$sesstat stat, v$statname name, v$session sess
where
	stat.sid = sess.sid
	and stat.statistic# = name.statistic#
	and name.name like '%' || '&ustatname' || '%'
group by sess.username, stat.sid, name.name
order by sess.username, stat.sid, name.name
/

undef 1

