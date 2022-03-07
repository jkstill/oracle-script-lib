
-- pdb-awr-enable.sql

-- to enable AWR snapshots on a PDB,
-- awr auto flush must be enabled, 
-- and the snapshot interval set to a non-zero value

-- run as DBA in the PDB

def snapIntervalMinutes = 15

whenever sqlerror exit

set serveroutput on size unlimited

begin
	if SYS_CONTEXT('USERENV','CON_NAME') = 'CDB$ROOT' then
		dbms_output.put_line('Do not run this in CDB$ROOT');
		raise_application_error(-20000,'setting PDB autoflush in CDB$ROOT');
	end if;
end;
/


whenever sqlerror continue

alter system set awr_pdb_autoflush_enabled = true scope=both sid='*';

execute dbms_workload_repository.modify_snapshot_settings(interval => &snapIntervalMinutes)

select SNAP_INTERVAL from cdb_hist_wr_control;

