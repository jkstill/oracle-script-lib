
set heading on
set pagesize 50000
set newpage 0
set termout on
set pause off
set linesize 250 trimspool on 

break on name skip page
column name new_value pname noprint
column type new_value ptype noprint
column line format 999999
column text format a200 

prompt Source Code Owner:
set term off feed off
col cowner noprint new_value uowner
select '&1' cowner from dual;
set term on feed on

ttitle center 'SOURCE FOR ' ptype ' - '  &&uowner'.'pname  

spool src-&uowner..txt

select name, type, line, text
from dba_source
where owner = upper('&&uowner')
order by name,type,line
/

spool off

undef 1 
set newpage 1
set pagesize 60

--ed src-&uowner..txt

