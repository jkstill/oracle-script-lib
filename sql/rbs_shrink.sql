
-- rbs_shrink.sql
-- shrink RBS to optimal

-- see rbs_optimal.sql for setting optimal size

-- DO not do this on a database unless there is a need
-- e.g. RBS all extended, and one constantly runs out
-- of space


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
	and v.optsize is not null;

	v_sql_template constant varchar2(200) := 'alter rollback segment <SEGMENT_NAME> shrink';
	v_sql varchar2(200);

	h integer;

begin
	h := dbms_sql.open_cursor;

	for r in c_rbs
	loop

		v_sql := v_sql_template;
		v_sql := replace(v_sql,'<SEGMENT_NAME>',r.segment_name);

		--execute immediate v_sql;
		dbms_sql.parse(h, v_sql, dbms_sql.native);
		dbms_output.put_line(v_sql);

	end loop;

end;
/

@showrbs


