-- dump.sql - jared still
-- jkstill@gmail.com
--
-- dump a table to a comma delimited ascii file
-- only drawback is line length is likely to be padded with 
-- quite a few spaces if the 'set trimspool on' option is
-- not in your version of SQLPLUS
--
-- also builds a control file and a parameter file for SQL*LOADER
--
-- 08/28/2000 - use defined variables for quotes and commas
-- 
-- This is the script found in Oracle Note 1050919.6
-- I wrote it in 1994, and it has been enhanced a few times since then
-- 


set trimspool on
set serverout on
clear buffer
undef dumpfile
undef dumptable
undef dumpowner

var maxcol number
var linelen number
var dumpfile char(40)

col column_id noprint

set pages0 feed off termout on echo off verify off

--accept dumpowner char prompt 'Owner of table to dump: '
--accept dumptable char prompt 'Table to dump: '

set term on
prompt Owner of table to dump:
set term off feed off
col cdumpowner noprint new_value dumpowner
select '&1' cdumpowner from dual;

set term on 
prompt Table to dump:
set term off feed off
col cdumptable noprint new_value dumptable
select '&2' cdumptable from dual;
set term on feed off


begin

	select max(column_id) into :maxcol
	from all_tab_columns
	where table_name = rtrim(upper('&dumptable'))
	and owner = rtrim(upper('&dumpowner'));

	select sum(data_length) + ( :maxcol * 3 ) into :linelen
	from all_tab_columns
	where table_name = rtrim(upper('&dumptable'))
	and owner = rtrim(upper('&dumpowner'));

end;
/

print linelen
print maxcol
spool ./_dump.sql

select 'set trimspool on' from dual;
select 'set termout off pages 0 heading off echo off' from dual;
select 'set line ' || :linelen from dual;
select 'spool ' || lower('&dumptable') || '.txt' from dual;

select 'select' || chr(10) from dual;

define squote=chr(39)
define dquote=chr(34)
define comma=chr(44)

select '   ' || &&squote || &&dquote  || &&squote || ' || ' ||  
	'replace(' || column_name || &&comma || &&squote ||  &&dquote || &&squote || ') '
	|| ' ||' || &&squote || '",' || &&squote || ' || ', 
	column_id
from all_tab_columns
where table_name = upper('&dumptable')
and owner = upper('&dumpowner')
and column_id < :maxcol
union
select '   ' || &&squote || &&dquote  || &&squote || ' || ' ||  
	'replace(' || column_name  || &&comma || &&squote ||  &&dquote || &&squote || ') '
	|| ' ||' || &&squote || &&dquote || &&squote ,
	column_id
from all_tab_columns
where table_name = upper('&dumptable')
and owner = upper('&dumpowner')
and column_id = :maxcol
order by 2
/

select 'from &dumpowner..&dumptable' from dual;

select '/' from dual;
select 'spool off' from dual;

spool off

@./_dump

set line 79
-- build a basic control file
spool _dtmp.sql
select 'spool ' || lower('&dumptable') || '.par' from dual;
spool off
@./_dtmp


select 'userid = ' || user || chr(10) ||
	'control = ' || lower('&dumptable') || '.ctl' || chr(10) ||
	'log = ' || lower('&dumptable') || '.log' || chr(10) ||
	'bad = ' || lower('&dumptable')|| '.bad' || chr(10)
from dual;

spool _dtmp.sql
select 'spool ' || lower('&dumptable') || '.ctl' from dual;
spool off
@./_dtmp
select 'load data' || chr(10) ||
	'infile ' || &&squote || lower('&dumptable') || '.txt' || &&squote || chr(10) ||
	'into table &dumptable' || chr(10) ||
	'fields terminated by ' || &&squote || &&comma || &&squote || 
	' optionally enclosed by ' || &&squote || &&dquote || &&squote  || chr(10)
from dual;

select '(' from dual;

select '   ' || column_name || &&comma , 
	column_id
from all_tab_columns
where table_name = upper('&dumptable')
and owner = upper('&dumpowner')
and column_id < :maxcol
union
select '   ' || column_name, column_id
from all_tab_columns
where table_name = upper('&dumptable')
and owner = upper('&dumpowner')
and column_id = :maxcol
order by 2
/

select ')' from dual;

spool off

undef 1 2

exit

