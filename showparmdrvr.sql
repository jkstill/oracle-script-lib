
set echo off feed on verify off pause off

clear col

set line 100
col stat new_value statname noprint
column value format   a50
column name format   a25
column isses_modifiable head 'SESS|MOD?' format a4
column issys_modifiable head 'SYS|MOD?' format a4
column isdefault head 'DEF|VAL?' format a4

set feed off term off
select '&&1' stat from dual;
set feed on term on

@@ttitle 'V$PARAMETER for &&statname'
ttitle on

select
	name
	, value
	, decode(isdefault, 'TRUE','Y','FALSE','N','?') isdefault
	, decode(
		isses_modifiable
		,'TRUE','Y'
		,'FALSE','N'
		,'?') isses_modifiable
	, decode(
		issys_modifiable
		,'FALSE','N'
		,'DEFERRED','D'
		,'IMMEDIATE','I'
		,'?') issys_modifiable
from v$parameter2
where name like '%&&statname%'
order by name
/


set head on
prompt			
prompt			
prompt			
ttitle off

undef 1

