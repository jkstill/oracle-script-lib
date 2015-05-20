
-- sp_snap_6.sql
-- take a snapshot at level 6 to get execution plans
-- set i_executions_th to 0 to get all SQL statements
-- (this only sets i_executions_th for duration of this snapshot)

begin
	statspack.snap(
		i_snap_level => 6, 
		i_executions_th => 0
	);
end;
/


