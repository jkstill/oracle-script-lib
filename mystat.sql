
set echo off verify off pause off feed off

--set echo on

clear col
clear comp
clear break

col cstatname new_value ustatname noprint
set term on
prompt Statistic Name ( Partial OK ): 
set term off echo off feed off
select '&1' cstatname from dual;
set term on feed on

col sid format 999 head 'SID'
col name format a40
col valuesum format 9999,999,999,999 head 'SUM OF STAT VALUE'
col username format a10 head 'USERNAME'

var v_statname varchar2(64)

set feedback off

begin
	:v_statname := '&&ustatname';
end;
/
set feedback on


select 
	name.name name, 
	stat.value
from v$mystat stat, v$statname name
where
	stat.statistic# = name.statistic#
	and name.name like '%' || :v_statname || '%'
order by name.name
/

undef 1

