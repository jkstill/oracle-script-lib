
-- package-error.sql
-- show line of error in context from package body
-- package-error package_name line#

@clears

col u_pkg new_value u_pkg noprint
col u_line new_value u_line noprint

define lines_context=10

set feed off term off echo off verify off

select upper('&1') u_pkg from dual;
select '&2' u_line from dual;

set feed on term on

col linenum format a12 head 'Line#'
col text format a150 head 'Line'

set pagesize 500
set linesize 200 trimspool on

select 
	case line when &u_line then '===> ' else '     ' end ||
	to_char(line) linenum
	, text 
from user_source
where name = '&u_pkg'
and type = 'PACKAGE BODY'
and line between &u_line-&lines_context and &u_line+&lines_context
order by line
/


undef 1 2

