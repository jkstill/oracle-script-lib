
-- histo_hist_dist.sql
-- show distribution of values for historical frequency based histograms
-- based on query at http://jonathanlewis.wordpress.com/2010/09/20/frequency-histograms-2/
--
-- work in progress
-- the sys.WRI$_OPTSTAT_HISTGRM_HISTORY table does not seem to have endpoint values
-- so this script may be of little use unless that column is populated

@clears

col howner new_value howner noprint
col htable new_value htable noprint
col hcolumn new_value hcolumn noprint
col hdate new_value hdate noprint

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

prompt
prompt Date of saved stats in yyyy-mm-dd hh23:mi:ss format:
prompt

set feed off term off
select upper('&4') hdate from dual;
set feed on term on

prompt
prompt

col column_value format  99999999999999999999999999999999999999
col frequency format 999,999,999,999

with histograms as (
select h.endpoint endpoint_number,
   lag(h.endpoint,1) over(
      order by endpoint
   ) prev_endpoint,
   h.epvalue endpoint_value
from sys.user$ u, sys.obj$ o, sys.WRI$_OPTSTAT_HISTGRM_HISTORY h, sys.col$ c
where u.name='&&howner'
   and o.name='&&htable'
   and c.name = '&hcolumn'
   and h.savtime = to_date('&&hdate','yyyy-mm-dd hh24:mi:ss')
   and h.obj# = o.obj#
   and o.type# = 2
   and o.owner# = u.user#
   and c.obj# = o.obj# and c.intcol# = h.intcol#
)
select
   h.endpoint_value column_value,
   h.endpoint_number - nvl(h.prev_endpoint,0)  frequency
from histograms h
order by endpoint_number
/

undef 1 2 3 4

