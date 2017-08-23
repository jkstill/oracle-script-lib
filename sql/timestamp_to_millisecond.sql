declare
	x number(32);
	y number(32);
	z number;
begin
	x := 
	to_number(
		extract(day from(systimestamp - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000
		+ to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3'))
	);
	dbms_lock.sleep(1);
	y := 
	to_number(
		extract(day from(systimestamp - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000
		+ to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3'))
	);
	dbms_output.put_line('x: ' || x );
	dbms_output.put_line('y: ' || y );
	dbms_output.put_line('diff: ' || to_char(y-x) );
end;
/
