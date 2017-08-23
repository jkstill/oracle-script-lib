
-- trans_per_hour.sql
-- approximate the trans based on commits and rollbacks
-- 

set serveroutput on size 1000000

var start_date char(20)

declare 
	v_avg_bytes_per_trans number(10,4);
	v_logical_ios integer;
	v_db_block_gets integer;
	v_consistent_gets integer;
	v_physical_writes integer;
	v_block_size integer;
	v_trans_count integer;
	v_trans_per_hour number (10,2);
	v_current_date date;
	v_minutes_since_startup integer;
	v_hours_since_startup number(10,2);
	v_version integer;
	v_sqlcmd varchar2(500);
	v_avg_trans_physio number(10,4);
	v_avg_trans_logio number(10,4);
	v_megabyte integer := power(2,20);
	v_kilobyte integer := power(2,10);

	h_sql_cursor integer;

	dummy integer;

begin

	select to_number(substr(version,1,1))  into  v_version
	from product_component_version
	where product like 'Oracle%';


	select value into v_block_size
	from v$parameter
	where name = 'db_block_size';

	select value into v_physical_writes
	from v$sysstat
	where name = 'physical writes';

	select value into v_consistent_gets
	from v$sysstat
	where name = 'consistent gets';

	select value into v_db_block_gets
	from v$sysstat
	where name = 'db block gets';


	if v_version = 7 then
		v_sqlcmd := 'select to_char(to_date(d.value,' || '''' || 'j' || '''' || ')+(s.value/86400),' || '''' || 
			'mm/dd/yyyy hh24:mi:ss' || '''' || ')' || ' into :start_date' || chr(10) || 
			' from v$instance d, v$instance s  ' || chr(10) || 
			' where d.key = ' || '''' || 'STARTUP TIME - JULIAN' || '''' ||  chr(10) || 
			' and s.key = ' || '''' || 'STARTUP TIME - SECONDS' || ''''
			;
	elsif v_version = 8 then
		v_sqlcmd := 'select to_char(startup_time,' || '''' || 'mm/dd/yyyy hh24:mi:ss' || '''' || ') into :start_date from v$instance';
	elsif v_version = 9 then
		v_sqlcmd := 'select to_char(startup_time,' || '''' || 'mm/dd/yyyy hh24:mi:ss' || '''' || ') into :start_date from v$instance';
	else
		v_sqlcmd := 'select to_char(startup_time,' || '''' || 'mm/dd/yyyy hh24:mi:ss' || '''' || ') into :start_date from v$instance';
	end if;

	h_sql_cursor := dbms_sql.open_cursor;
	dbms_sql.parse(h_sql_cursor, v_sqlcmd, dbms_sql.native);
	dbms_sql.define_column(h_sql_cursor,1,:start_date,20);
	dummy := dbms_sql.execute_and_fetch(h_sql_cursor);

	dbms_sql.column_value(h_sql_cursor, 1, :start_date);
	dbms_sql.close_cursor(h_sql_cursor);

	select
		sum(value) into v_trans_count
	from v$sysstat
	where name in ( 'user commits', 'user rollbacks');

	--select to_char(to_date(d.value,'j')+(s.value/86400),'mm/dd/yyyy hh24:mi:ss') into v_start_date
	--from v$instance d, v$instance s 
	--where d.key = 'STARTUP TIME - JULIAN'
	--and s.key = 'STARTUP TIME - SECONDS';

	v_current_date := sysdate;

	v_logical_ios := v_db_block_gets + v_consistent_gets;
	v_minutes_since_startup := (v_current_date - to_date(:start_date,'mm/dd/yyyy hh24:mi:ss')) * ( 24*60);
	v_hours_since_startup := v_minutes_since_startup / 60;
	v_trans_per_hour := v_trans_count / v_hours_since_startup;
	v_avg_bytes_per_trans := ((( v_logical_ios + v_physical_writes) * v_block_size) / v_trans_count) / v_kilobyte;
	v_avg_trans_physio := (v_physical_writes / v_trans_count);
	v_avg_trans_logio := (v_logical_ios / v_trans_count);

	--dbms_output.put_line('Minutes since DB startup    : ' || to_char(v_minutes_since_startup));
	dbms_output.put_line('Hours   since DB startup    : ' || to_char(v_hours_since_startup));
	dbms_output.put_line('Transactions per Hour       : ' || to_char(v_trans_per_hour));
	dbms_output.put_line('Avg Bytes per  Xaction      : ' || to_char(v_avg_bytes_per_trans) || ' K');
	dbms_output.put_line('Avg Phys IOs per Xaction    : ' || to_char(v_avg_trans_physio));
	dbms_output.put_line('Avg Logical IOs per Xaction : ' || to_char(v_avg_trans_logio));

end;
/


------------------------------------

