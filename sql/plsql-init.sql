
-- setup plscope
-- STATEMENTS:ALL requires oracle 12.2+
alter session set plscope_settings='IDENTIFIERS:ALL,STATEMENTS:ALL';

alter session set plsql_optimize_level=2;

--alter session set plsql_warnings = 'ENABLE:SEVERE';
alter session set plsql_warnings = 'ENABLE:ALL';

-- Flags may be boolean or integers
-- may not currently be using debug
alter session set plsql_ccflags = 'debug:true, develop:true, max_volume:11';

-- INTERPRETED (default) or NATIVE
alter session set PLSQL_CODE_TYPE =  INTERPRETED ;

begin

	$if $$develop $then
		dbms_output.put_line('this line appears only when the develop flag is true');
	$end

	$if $$debug $then
		dbms_output.put_line('this line appears only when the debug flag is true');
	$end

	dbms_output.put_line('max_volume: ' || to_char($$max_volume));

end;
/



