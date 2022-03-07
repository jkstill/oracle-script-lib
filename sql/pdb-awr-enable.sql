
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

-- set the offset for AWR snapshot generation
-- the special value of 1000000 causes oracle to choose an offset based on pdb name
-- https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/AWR_SNAPSHOT_TIME_OFFSET.html#GUID-90CD8379-DCB2-4681-BB90-0A32C6029C4E

prompt
prompt
prompt Set this in the CDB to prevent PDBs from running AWR snapshots simultaneously
prompt
prompt "alter system set AWR_SNAPSHOT_TIME_OFFSET=1000000 scope=both sid='*';"
prompt
prompt

