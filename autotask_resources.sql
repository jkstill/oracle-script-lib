
@@autotask_sql_setup

declare
	v_stats_group_pct number(3);
	v_seg_group_pct number(3);
	v_tune_group_pct number(3);
	v_health_group_pct number(3);
begin

	dbms_auto_task_admin.get_p1_resources(
		v_stats_group_pct,
		v_seg_group_pct,
		v_tune_group_pct,
		v_health_group_pct
	);

	dbms_output.put_line('STATS GATHER RESOURCE % :' || v_stats_group_pct );
	dbms_output.put_line('SPACE MGT    RESOURCE % :' || v_seg_group_pct );
	dbms_output.put_line('SQL TUNING   RESOURCE % :' || v_tune_group_pct );
	dbms_output.put_line('HEALTH CHK   RESOURCE % :' || v_health_group_pct );
end;
/

