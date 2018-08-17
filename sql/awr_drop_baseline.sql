
-- awr_drop_baseline.sql
-- drop a single baseline


prompt 
prompt '=== Current Baselines ==='
prompt
@@awr_display_baselines

prompt
prompt

col u_baseline new_value u_baseline

prompt
prompt AWR Baseline to drop: 
prompt

set feed off term off 
select '&1' u_baseline from dual;
set feed on term on

prompt
prompt !!!! This script will drop AWR Baseline &u_baseline
prompt
prompt Enter YES to proceed - any other response will exit
prompt

-- do not allow command line or cached var
undef 1

col my_response new_value my_response noprint

set term off feed off verify echo off

select '&2' my_response from dual;

set term on feed on

whenever sqlerror exit 1

set serveroutput on size 1000000

declare
	do_not_run exception;
	pragma exception_init(do_not_run,-20000);
begin
	if '&my_response' != 'YES' then
		dbms_output.put_line('User response !== ''YES'' - exiting');
		raise do_not_run;
	end if;
end;
/

whenever sqlerror continue

begin
	for brec in (
		select baseline_name
		from dba_hist_baseline
		where baseline_name = '&u_baseline'
	)
	loop
		dbms_workload_repository.drop_baseline(baseline_name => brec.baseline_name, cascade => FALSE );
	end loop;
end;
/

@@awr_display_baselines

