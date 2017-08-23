
-- chk4incremental.sql
-- check to see if incremental stats were gathered for a table
-- displays the affected columns
-- Maria Colgan blog
-- https://blogs.oracle.com/optimizer/entry/incremental_statistics_maintenance_what_statistics

set echo off

col v_owner new_value v_owner noprint
col v_table new_value v_table noprint

prompt
prompt Owner:

set feed off term off
select upper('&1') v_owner from dual;
set feed on term on

prompt
prompt Table: 

set feed off term off
select upper('&2') v_table from dual;
set feed on term on

select o.name
	, c.name
	, decode(bitand(h.spare2, 8), 8, 'yes', 'no') incremental
from   sys.hist_head$ h
	, sys.obj$ o
	, sys.col$ c
	, sys.user$ u
where h.obj# = o.obj#
and o.obj# = c.obj#
and h.intcol# = c.intcol#
and o.owner# = u.user#
and u.name = '&&v_owner'
and o.name = '&&v_table'
and o.subname is null
/

undef 1 2


