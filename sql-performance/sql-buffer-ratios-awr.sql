

-- sql-buffer-ratios-awr.sql
-- Jared Still 2024

/*

this query is used to examine sql statistics and see if there many queries
returning a large number of rows per execution

if for instance network latency has gone from 0.000020 seconds to ~ 0.012 seconds, the performance of such queries will be quite bad

if 1,000,000 rows are returned across the network with an array size of 100, the latency will increase by ~ 3 minutes

( 1000000 / 100 ) * ( 0.018 - 0.000020) 179.8

With the database on-premises, the total latency is about 0.2 seconds

With an array size of 100 
and table now resides on some remote database server, the combined latency is about 3 minutes for this query, 
depending on the distance between client and server

If the array size is 1, the latency goes upto to ~ 5 hours

*/


set linesize 200 trimspool on
set pagesize 100

col parsing_users format a80 wrapped head 'PARSING USERS'
col sql_id format a13
col disk_reads format 99,999,999,999
col buffer_gets format 999,999,999,999
col ratio format 999.99
col rows_per_execution format 99,999,999,999 head 'ROWS|PER|EXEC'
col output_rows format 999,999,999,999 head 'OUTPUT|ROWS'


set verify off

col logtime new_value u_logtime noprint
set term off feed off 

select to_char(sysdate,'yyyy-mm-dd_hh24-mi-ss') logtime from dual;
set term on feed on

host mkdir -p logs

spool logs/sql-buffer-ratios-awr_&u_logtime..log


with
function get_parsers (sql_id_in varchar2) return varchar2
as
   c_users clob;
   v_users varchar2(4000);
begin

   for urec in (
      select distinct substr(u.username,1,20) username
      from dba_hist_sqlstat s
		join dba_users u
			on u.user_id = s.parsing_user_id
      where s.sql_id = sql_id_in
		order by username
   )
   loop
      c_users := c_users || ' ' || urec.username;
   end loop;

   -- start at position 2 as pos 1 is a space
   --v_objects := substr(c_objects,2,4000);
   v_users := dbms_lob.substr(c_users,4000,2);

   return v_users;
end;
snapdata as (
	select 
		instance_number
		, snap_id snap_id
	from dba_hist_snapshot ss
	join v$database d on d.dbid = ss.dbid
	where cast (begin_interval_time as date) >= trunc(sysdate) - 3
),
data as (
	select
		sql_id
		, sum(physical_read_requests_delta) disk_reads
		, sum(buffer_gets_delta) buffer_gets
		, sum(rows_processed_delta) output_rows
		, sum(executions_delta) executions
	--from v$sql_plan_statistics
	from dba_hist_sqlstat s
	join snapdata h on h.snap_id = s.snap_id
		and h.instance_number = s.instance_number
		and s.parsing_schema_name in (
			select username
			from dba_users
			where oracle_maintained = 'N'
				--and username not in ('SYSADM','RDSADMIN')
				-- SYSADM is not an oracle account
				and username not in ('RDSADMIN')
		)
	group by s.sql_id
),
rptdata as (
	select
		sql_id
		, disk_reads disk_reads
		, buffer_gets buffer_gets
		, output_rows  output_rows
		, executions executions
		, output_rows / executions rows_per_execution
		, to_char(case
			when output_rows = 0 and buffer_gets = 0 then 0
			when output_rows = 0 and buffer_gets > 0 then 1
			when output_rows > 0 and buffer_gets = 0 then buffer_gets
			else buffer_gets / output_rows / executions
		end, '999,999,999.99') ratio
	from data
	where executions > 0
	order by ratio
)
select sql_id
	, executions
	, disk_reads
	, buffer_gets
	, output_rows
	, rows_per_execution
	, ratio
	, get_parsers(sql_id) parsing_users
from rptdata
--where to_number(ratio,'999,999,999.99') between
	--buffer_gets / 20
	--and
	--buffer_gets / 10
--order by output_rows desc 
order by rows_per_execution desc 
fetch first 100 rows only
/


spool off

prompt log: logs/sql-buffer-ratios-awr_&u_logtime..log



