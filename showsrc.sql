
set heading on
set pagesize 60
set newpage 0
set termout on
set pause off
set linesize 132

break on name skip page
column name new_value pname noprint
column type new_value ptype noprint
column line format 999999
column text format a120

prompt Source Code Owner:
set term off feed off
col cowner noprint new_value uowner
select '&1' cowner from dual;
set term on feed on

ttitle center 'SOURCE FOR ' ptype ' - '  &&uowner'.'pname  

select name, type, line, text
from dba_source
where owner = upper('&&uowner')
order by name,type,line
/

undef 1 
set newpage 1

