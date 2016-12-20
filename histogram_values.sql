
col column_name format a30
col column_value format 99999999999999999999999999999999999999
col column_actual_value format a60

set pagesize 60
set linesize 200

-- thanks to Jonathan Lewis for the base query
-- http://jonathanlewis.wordpress.com/2010/09/20/frequency-histograms-2/

col u_owner new_value u_owner noprint
col u_table new_value u_table noprint

prompt
prompt Table Owner:
prompt

set feed off term off
select upper('&&1') u_owner from dual;
set term on

prompt Table Name:
set term off
select upper('&&2') u_table from dual;
set term on feed on


break on column_name skip 1

--spool h.txt

select
	 column_name,
	 endpoint_value				  column_value,
	 endpoint_number - nvl(prev_endpoint,0)  frequency,
	 endpoint_actual_value column_actual_value
from
(
	select
		column_name,
		endpoint_number,
		lag(endpoint_number,1) over( partition by column_name order by endpoint_number) prev_endpoint,
		endpoint_value,
		substr(endpoint_actual_value,1,60) endpoint_actual_value
	from dba_tab_histograms
	where ( owner, table_name, column_name ) in (
		select distinct owner,table_name,column_name from dba_histograms
		where owner = '&u_owner'
		and table_name = '&u_table'
	)
	order  by column_name
)
order by column_name, endpoint_number
/

--spool off

undef 1 2

