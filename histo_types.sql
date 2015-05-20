
@clears

col howner new_value howner noprint

prompt 
prompt Show histogram types for which Schema?:  
prompt 
set feed off term off
select upper('&1') howner from dual;
set feed on term on

col table_name format a30 head 'TABLE'
col column_name format a30 head 'COLUMN'
col histogram format a15 
col num_nulls format 99999999999 head 'NUM NULLS'
col num_buckets format 9999 head 'NUM|BKTS'
col num_distinct format 99999999999 head 'NUM DISTINCT'
col last_analyzed format a20 head 'LAST ANALYZED'

set pagesize 60 linesize 200 trimspool on

select 
	table_name
	, column_name
	, histogram
	, num_nulls
	, num_buckets
	, num_distinct
	--, abs(num_distinct - num_buckets) diff
	, sample_size
	, to_char(last_analyzed,'yyyy-mm-dd hh24:mi:ss') last_analyzed
from dba_tab_col_statistics 
where owner='&&howner'
and histogram in ('FREQUENCY', 'HEIGHT BALANCED') 
order by table_name,histogram,column_name
/

undef 1

