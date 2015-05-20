
@clears

col v_stats_owner new_value v_stats_owner noprint
col v_stats_table new_value v_stats_table noprint

prompt 
prompt Table Owner:

set feed off term off
select upper('&1') v_stats_owner from dual;
set feed on term on 

prompt 
prompt Table Name:
prompt 

set feed off term off
select upper('&2') v_stats_table from dual;
set feed on term on 

set line 250
set pagesize 60

col owner format a12
col table_name format a20
col partition_name format a15 head 'PARTITION'
col subpartition_name format a15 head 'SUBPARTITION'
col index_name format a20
col t_global_stats format a3 head 'GS'
col tp_global_stats format a3 head 'TP|GS'
col tsp_global_stats format a3 head 'TSP|GS'
col t_last_analyzed format a20  head 'TABLE LAST ANALYZED'
col tp_last_analyzed format a20 head 'PART LAST ANALYZED'
col tsp_last_analyzed format a21 head 'SUBPART LAST ANALYZED'
col t_num_rows format 99,999,999,999 head 'NUM ROWS'
col tp_num_rows format 99,999,999,999 head 'NUM ROWS'
col tsp_num_rows format 99,999,999,999 head 'NUM ROWS'

clear break compute

break on owner skip 1 on table_name skip 1 on t_global_stats on t_last_analyzed skip on t_num_rows  on partition_name skip 1 on tp_num_rows on report
compute sum of tsp_num_rows on report


select 
	t.owner
	, t.table_name
	, t.global_stats t_global_stats
	, to_char(t.last_analyzed,'yyyy-mm-dd hh24:mi:ss') t_last_analyzed
	, t.num_rows t_num_rows
	-- partitions
	, tp.partition_name 
	, tp.global_stats tp_global_stats
	, to_char(tp.last_analyzed,'yyyy-mm-dd hh24:mi:ss') tp_last_analyzed
	, tp.num_rows tp_num_rows
	-- subpartitions
	, tsp.subpartition_name 
	, tsp.global_stats tsp_global_stats
	, to_char(tsp.last_analyzed,'yyyy-mm-dd hh24:mi:ss') tsp_last_analyzed
	, tsp.num_rows tsp_num_rows
from dba_tables t
left outer join dba_tab_partitions tp on tp.table_owner = t.owner
	and tp.table_name = t.table_name
left outer join dba_tab_subpartitions tsp on tsp.table_owner = tp.table_owner
	and tsp.table_name = tp.table_name
	and tsp.partition_name = tp.partition_name
where t.owner = '&&v_stats_owner' 
	and t.table_name = '&&v_stats_table'
order by t.owner, t.table_name, tp.partition_name  desc nulls last
/


col i_global_stats format a3 head 'GS'
col ip_global_stats format a3 head 'IP|GS'
col isp_global_stats format a3 head 'IPS|GS'
col i_last_analyzed format a20  head 'TABLE LAST ANALYZED'
col ip_last_analyzed format a20 head 'PART LAST ANALYZED'
col isp_last_analyzed format a21 head 'SUBPART LAST ANALYZED'
col i_num_rows format 99,999,999,999 head 'NUM ROWS'
col ip_num_rows format 99,999,999,999 head 'NUM ROWS'
col isp_num_rows format 99,999,999,999 head 'NUM ROWS'

clear break compute

break on owner skip 1 on index_name skip 1 on i_global_stats on i_last_analyzed skip on i_num_rows  on partition_name skip 1 on ip_num_rows on report
compute sum of isp_num_rows on report


select 
	i.owner
	, i.table_name
	, i.index_name
	, i.global_stats i_global_stats
	, to_char(i.last_analyzed,'yyyy-mm-dd hh24:mi:ss') i_last_analyzed
	, i.num_rows i_num_rows
	-- partitions
	, ip.partition_name 
	, ip.global_stats ip_global_stats
	, to_char(ip.last_analyzed,'yyyy-mm-dd hh24:mi:ss') ip_last_analyzed
	, ip.num_rows ip_num_rows
	-- subpartitions
	, isp.subpartition_name 
	, isp.global_stats isp_global_stats
	, to_char(isp.last_analyzed,'yyyy-mm-dd hh24:mi:ss') isp_last_analyzed
	, isp.num_rows isp_num_rows
from dba_indexes i
left outer join dba_ind_partitions ip on ip.index_owner = i.owner
	and ip.index_name = ip.index_name
left outer join dba_ind_subpartitions isp on isp.index_owner = ip.index_owner
	and isp.index_name = ip.index_name
	and isp.partition_name = ip.partition_name
where i.table_owner = '&&v_stats_owner'
	and i.table_name = '&&v_stats_table'
order by i.owner, i.table_name, ip.partition_name  desc nulls last
/




undef 1 2
