-- purge_cursors.sql
-- purge the cursors from the shared spool


-- need to clean this up to avoid coding SQL_ID twice


set serveroutput on size unlimited

declare
	v_cursor_locator varchar2(60);
	c_count integer;
begin

	for sqlrec in (
		select address, hash_value, sql_id
		from v$sqlarea 
		where sql_id in (
			'dgpxu1tw6za1s',
			'4ym5qfq01znp6',
			'60m0byvkx1y09',
			'c6jpmu9mrhda8'
		)
	)
	loop
		v_cursor_locator := sqlrec.address || ',' || sqlrec.hash_value;
		-- use address and hash_value to purge
		-- eg. dbms_shared_pool.purge ('0000000382E80750,1052545619','C');
		sys.dbms_shared_pool.purge(v_cursor_locator,'C');
	end loop;

	for sqlrec in (
		select column_value sql_id
		from (
			table(
				sys.odcivarchar2list(
					'dgpxu1tw6za1s',
					'4ym5qfq01znp6',
					'60m0byvkx1y09',
					'c6jpmu9mrhda8'
				)
			)
		)
	)
	loop
		
		select count(*) into c_count 
		from v$sqlarea 
		where sql_id = sqlrec.sql_id;

		dbms_output.put_line(sqlrec.sql_id || ': ' || to_char(c_count));
	end loop;

end;
/

set serveroutput off
