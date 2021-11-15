
-- dbms_stats_report.sql
-- Jared Still  jkstill@gmail.com
-- report on dbms_stats operations 
-- requires 12c+


col myRptFile new_value myRptFile noprint

select 'dbms_stats_rpt_' || to_char(sysdate,'yyyymmdd_hh24miss') || '.html' myRptFile from dual;


var myRpt clob

begin
	:myRpt := dbms_stats.report_stats_operations (
		since => systimestamp -1,
		until => systimestamp,
		detail_level => 'TYPICAL',
		format => 'HTML'
	);
end;
/

@clear_for_spool
set long 2000000

spool &myRptFile

print myRpt

spool off

@clears


