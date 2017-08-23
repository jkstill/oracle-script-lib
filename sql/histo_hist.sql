
-- histo_hist.sql

@clears

col howner new_value howner noprint
col htable new_value htable noprint
col hcolumn new_value hcolumn noprint

prompt
prompt Show histogram history
prompt
prompt Owner:
prompt

set feed off term off
select upper('&1') howner from dual;
set feed on term on

prompt
prompt Table:
prompt

set feed off term off
select upper('&2') htable from dual;
set feed on term on

prompt
prompt Column:
prompt

set feed off term off
select upper('&3') hcolumn from dual;
set feed on term on

prompt
prompt

col column_value format 999999999999
col frequency format 999,999,999,999

col savtime format a20
col name format a30
col epvalue format a38
col bucket format 999999999999
col endpoint format 999999999999

set linesize 200 pagesize 50000 trimspool on

break on savtime skip 1 on name skip 1

select to_char(h.savtime,'yyyy-mm-dd hh24:mi:ss') savtime
	, c.name
	, h.bucket
	, h.endpoint
	, h.epvalue
from sys.user$ u, sys.obj$ o, sys.WRI$_OPTSTAT_HISTGRM_HISTORY h, sys.col$ c
where u.name='&&howner'
	and o.name='&&htable' 
	and c.name = '&hcolumn'
	and h.obj# = o.obj#
	and o.type# = 2
	and o.owner# = u.user#
	and c.obj# = o.obj# and c.intcol# = h.intcol#
order by h.savtime, c.name, h.bucket
/

undef 1 2 3

