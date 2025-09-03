
-- code-inventory.sql
-- create csv output of procedures, functions, views, triggers
-- and functions and procedures from package headers
-- package-error package_name line#

-- note: the error text for VIEWs is not available
--			view text is in all_views, where the entire view SQL is stored as a LONG
--			the line# in all_errors is always 0

/*
owner,package_name,code_name,code_type
...
REMOTE_SCHEDULER_AGENT,,REGISTER_AGENT3,PROCEDURE
REMOTE_SCHEDULER_AGENT,,REG_START,PROCEDURE
REMOTE_SCHEDULER_AGENT,,RESTRICT_ACCESS,FUNCTION
REMOTE_SCHEDULER_AGENT,,SUBMIT_FILEWATCH_RESULTS,PROCEDURE
REMOTE_SCHEDULER_AGENT,,SUBMIT_JOB_RESULTS,PROCEDURE
REMOTE_SCHEDULER_AGENT,,SUBMIT_JOB_RESULTS2,PROCEDURE
REMOTE_SCHEDULER_AGENT,,UNREGISTER_AGENT,PROCEDURE
SOE,ORDERENTRY,BROWSEANDUPDATEORDERS,FUNCTION
SOE,ORDERENTRY,BROWSEPRODUCTS,FUNCTION
SOE,ORDERENTRY,NEWCUSTOMER,FUNCTION
SOE,ORDERENTRY,NEWORDER,FUNCTION
SOE,ORDERENTRY,PROCESSORDERS,FUNCTION
SOE,ORDERENTRY,SALESREPSQUERY,FUNCTION
SOE,ORDERENTRY,SETPLSQLCOMMIT,PROCEDURE
SOE,ORDERENTRY,UPDATECUSTOMERDETAILS,FUNCTION
SOE,ORDERENTRY,WAREHOUSEACTIVITYQUERY,FUNCTION
SOE,ORDERENTRY,WAREHOUSEORDERSQUERY,FUNCTION
SOE,,PRODUCTS,VIEW
SOE,,PRODUCT_PRICES,VIEW
SYS,AMGT$DATAPUMP,INSTANCE_CALLOUT_IMP,PROCEDURE
SYS,AS_REPLAY,END_AS_REPLAY,PROCEDURE
SYS,AS_REPLAY,INITIALIZE_AS_REPLAY,PROCEDURE
...
*/

@clears

col owner format a30
col name format a30
col type format a15
col object_name format a30
col object_type format a15
col code_name format a30
col package_name format a30
col code_type format a10

--set pagesize 500
--set linesize 300 trimspool on
--break on owner skip 1 on package_name skip 1	on type skip 1

col rptname new_value rptname noprint

set feed off term off verify off

select host_name || '-' || instance_name || '-code-inventory.csv' rptname from v$instance;

set term on

clear break
@clear_for_spool

spool &rptname

prompt owner,package_name,code_name,code_type

with owner_objects as (
	@@user-objects
),
procedures as (
	select owner, NULL package_name, object_name code_name, 'PROCEDURE' code_type
	from owner_objects
	where object_type = 'PROCEDURE'
),
functions as (
	select owner, NULL package_name, object_name code_name, 'FUNCTION' code_type
	from owner_objects
	where object_type = 'FUNCTION'
),
views as (
	select owner, NULL package_name, object_name code_name, 'VIEW' code_type
	from owner_objects
	where object_type = 'VIEW'
),
triggers as (
	select owner, NULL package_name, object_name code_name, 'TRIGGER' code_type
	from owner_objects
	where object_type = 'TRIGGER'
),
package_headers as (
	select distinct -- procedures may be overloaded
		p.owner, p.object_name package_name, p.procedure_name code_name
		, case a.position when 0 then 'FUNCTION' else 'PROCEDURE' end code_type
		--, a.data_type return_type
	from owner_objects o
	join all_procedures	p
		on p.owner = o.owner
		and p.object_name = o.object_name
		and p.object_type = o.object_type
	left outer join all_arguments a
		on a.owner = p.owner
		and a.object_name = p.procedure_name
		and a.position = 0
	where p.subprogram_id > 0 -- 0 ia package name
		and o.object_type = 'PACKAGE'
--
),
all_data as (
	select owner,package_name,code_name,code_type from package_headers
	union all
	select owner,package_name,code_name,code_type from procedures
	union all
	select owner,package_name,code_name,code_type from functions
	union all
	select owner,package_name,code_name,code_type from views
	union all
	select owner,package_name,code_name,code_type from triggers
	order by 1,2,3
)
select
	owner
	||','|| package_name
	||','|| code_name
	||','|| code_type
from all_data
/

spool off

@clears
