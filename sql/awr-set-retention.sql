
-- awr-set-retention.sql
-- 
--

prompt
prompt Example of PL/SQL to set AWR retention
prompt

set document on

document

-- 30 days retention
-- 30 minute intervals

begin
	dbms_workload_repository.modify_snapshot_settings(
		retention => 43200,  -- minutes - no change if null
		interval  => 30      -- minutes - no change if null
	);
end;
/

#


