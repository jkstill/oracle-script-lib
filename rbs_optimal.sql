
-- rbs_optimal.sql

-- set the OPTIMAL to the 2x the initial extent
-- size on RBS that do not have optimal already set
--
-- do not set SYSTEM RBS
-- only set ONLINE RBS


@showrbs

declare

	cursor c_rbs
	is
	select d.segment_name
		, d.initial_extent
	from dba_rollback_segs d, v$rollstat v
	where v.usn = d.segment_id
	and d.segment_name != 'SYSTEM'
	and d.status = 'ONLINE'
	and v.xacts < 1
	and v.optsize is null;

	v_sql_template constant varchar2(200) := 'alter rollback segment <SEGMENT_NAME> storage ( optimal <OPTIMAL_SIZE>)';
	v_sql varchar2(200);

	h integer;


begin
	h := dbms_sql.open_cursor;

	for r in c_rbs
	loop

		v_sql := v_sql_template;
		v_sql := replace(v_sql,'<SEGMENT_NAME>',r.segment_name);
		v_sql := replace(v_sql,'<OPTIMAL_SIZE>', 2 * r.initial_extent);

		--execute immediate v_sql;
		dbms_sql.parse(h, v_sql, dbms_sql.native);
		dbms_output.put_line(v_sql);

	end loop;

end;
/

@showrbs


