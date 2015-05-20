
set echo off verify off pause off feed on

col stat new_value statname noprint

prompt Enter Statname ( Partial OK ):
set feed off term off
select '&&1' stat from dual;
set feed on term on

@@ttitle 'V$SYSSTAT for &&statname'
ttitle on

clear col
clear break

break on class

col name format a40
col value format 9999,999,999,999
col class format 9999

select class,name, value
from v$sysstat
where name like '%&&statname%'
order by class,name
/


prompt 		
prompt 		
prompt 		
ttitle off
undef 1

