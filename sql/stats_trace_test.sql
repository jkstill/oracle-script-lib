

-- stats_trace_test.sql
-- trace settings are not persistent if '2' is set
-- see stats_trace.sql

set serveroutput on size unlimited

declare
	vOrigStatsFlags varchar2(30);
	vCurrStatsFlags varchar2(30);
begin
	vOrigStatsFlags := dbms_stats.get_prefs('trace');
	dbms_output.put_line('original prefs: ' || vOrigStatsFlags);

	dbms_output.put_line('setting trace to ' || to_char(2 + 4 + 16 + 32768));
	dbms_stats.set_global_prefs('trace', to_char(2 + 4 + 16 + 32768));

	vCurrStatsFlags := dbms_stats.get_prefs('trace');
	dbms_output.put_line('new prefs: ' || vOrigStatsFlags);

	dbms_stats.set_global_prefs('trace', vOrigStatsFlags);

	vCurrStatsFlags := dbms_stats.get_prefs('trace');
	dbms_output.put_line('reset prefs: ' || vOrigStatsFlags);

end;
/

