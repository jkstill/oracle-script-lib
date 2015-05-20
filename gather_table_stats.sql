
whenever oserror exit
whenever sqlerror exit

@@stats_config

define tmpsql='./_run_rpt.sql'

set timing on

@@logsetup gather_schema_stats
set echo off

prompt ##############################################
prompt ## Log   File: &&v_logfile
prompt ##############################################


prompt ##############################################
prompt ## gather stats for 
prompt ## owner: &&v_owner
prompt ##############################################
set echo on

declare
	type v_tabtyp_i is table of varchar2(100) index by pls_integer;
	v_tables v_tabtyp_i;
begin

@@table_list

	for t in v_tables.first .. v_tables.last
	loop

                DBMS_APPLICATION_INFO.SET_MODULE( module_name => 'Gathering Stats :&&v_owner',   action_name => v_tables(t) ); 
		dbms_output.put_line('##############################################################################');

		dbms_output.put_line('### Table: ' || v_tables(t));
		dbms_stats.gather_table_stats(
			ownname				=> '&&v_owner',
			tabname				=> v_tables(t)
		);

	end loop;
end;
/

set echo off

whenever oserror continue
whenever sqlerror continue

prompt #######################################
prompt ## report:
prompt ##   reports have been removed as they
prompt ##   took longer to run than dbms_stats
prompt ## 
prompt ## see rev 1.5 of this script to see 
prompt ## calls to the reports
prompt ## 
prompt #######################################

spool off

--exit


