
-- parameter-compare.sql
-- 2021 Jared Still
-- jkstill@gmail.com

/*

Compare parameters between two databases.

The comparison is performed by means of a database link.

You will need to create a database link at least temporarily if there is not one available

The dblink name is currently hardcoded as REMOTE_DB_LINK

Useful for migration when the data is imported to the new db

Several parameters are excluded, as they are not interesting from a migration perspective

Of the remaining parameters, they are reported only if they are set differently between the two dataases.

If the value is not set, it will appear as 'NA'

This could be enhanced by considering _underscore parameters.

I did not do that, as this was first used on AWS RDS, direct access to the necessary tables is not available

Data is written to a CSV file, parameter-compare.csv

*/

@clear_for_spool

set linesize 32727 trimspool on
set pagesize 0
col name format a50
col aws_value format a100
col on_prem_value format a100
col csvline format a32767

spool parameter-compare.csv

prompt "name","on_prem_value","aws_value"

with excluded_parms as (
	select rownum id, column_value parm_name
	from (
		table(
			sys.odcivarchar2list(
				'control_files'
				,'cluster_database'
				,'db_block_size'
				,'db_create_file_dest'
				,'db_domain'
				,'db_name'
				,'db_recovery_file_dest'
				,'db_recovery_file_dest_size'
				,'db_unique_name'
				,'dg_broker_config_file1'
				,'dg_broker_config_file2'
				,'dg_broker_start'
				,'diagnostic_dest'
				,'dispatchers'
				,'fal_client'
				,'fal_server'
				,'instance_number'
				,'log_archive_dest_1'
				,'log_archive_config'
				,'log_archive_dest_2'
				,'log_archive_dest_3'
				,'log_archive_dest_state_1'
				,'log_archive_dest_state_10'
				,'log_archive_dest_state_2'
				,'log_archive_dest_state_3'
				,'remote_listener'
				,'spfile'
				,'standby_archive_dest'
				,'standby_file_management'
				,'thread'
				,'undo_tablespace'
			)
		)
	)
),
parm_names as (
	select name
	from v$parameter
	where name not in (
		select parm_name from excluded_parms
	)
	--
	union
	--
	select name
	from v$parameter@REMOTE_DB_LINK
	where name not in (
		select parm_name from excluded_parms
	)
),
on_prem as (
	select name, value
	from v$parameter
	where name in (select name from parm_names)
),
aws as (
	select name, value
	from v$parameter@REMOTE_DB_LINK
	where name in (select name from parm_names)
),
rptdata as (
	select
		case
		when o.name is null then a.name
		else o.name
		end name
		, nvl(o.value,'NA') on_prem_value
		, nvl(a.value,'NA') aws_value
	from on_prem o
	full outer join aws a on a.name = o.name
)
select '"' || name
	|| '","' || on_prem_value
	|| '","' || aws_value
	|| '"' csvline
from rptdata
where on_prem_value != aws_value
order by name
/

spool off
@clears

ed parameter-compare.csv

