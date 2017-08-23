
-- histo_dist.sql
-- show distribution of values for frequency based histograms
-- based on query at http://jonathanlewis.wordpress.com/2010/09/20/frequency-histograms-2/

@clears

col howner new_value howner noprint
col htable new_value htable noprint
col hcolumn new_value hcolumn noprint

prompt
prompt Show distribution of values in frequency based histogram
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

col column_value format 99999999999999999999999999999999999999
col frequency format 999,999,999,999

with histograms as (
	select
	endpoint_number,
	lag(endpoint_number,1) over(
		order by endpoint_number
	) prev_endpoint,
	endpoint_value
	from
	dba_tab_histograms
	where owner = '&&howner'
	and table_name  = '&&htable'
	and column_name = '&&hcolumn'
)
select 
	h.endpoint_value column_value,
	h.endpoint_number - nvl(h.prev_endpoint,0)  frequency
from histograms h
order by endpoint_number
/

undef 1 2 3

