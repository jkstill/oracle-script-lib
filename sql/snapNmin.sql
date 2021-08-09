
-- take a two minute snapshot at level 7
--
-- then run a snap report on the data just captured

prompt ==========================================================
prompt == run a N minute snapshot
prompt ==========================================================

define _editor=vi

var begin_snap_id number
var end_snap_id number

declare

	sleep_time integer := 120;

begin
	--:begin_snap_id := 1;
	--:end_snap_id := 2;

	--/*
	:begin_snap_id := statspack.snap(
		i_snap_level => 7,
		i_ucomment => 'high load - begin time ' || to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')
	);

	dbms_lock.sleep(sleep_time);

	:end_snap_id := statspack.snap(
		i_snap_level => 7,
		i_ucomment => 'cove high load - end time ' || to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')
	);
	--*/

end;
/

col dbid new_value dbid noprint
col inst_num new_value inst_num noprint
col begin_snap new_value begin_snap noprint
col end_snap new_value end_snap noprint
col report_name new_value report_name noprint
col save_report_name new_value save_report_name noprint

select :begin_snap_id begin_snap from dual;
select :end_snap_id end_snap from dual;
select instance_number inst_num from v$instance;
select dbid from v$database;

select 'sp_high_load_'
		  || lower(host_name)
		  || '_' || instance_name
		  || '_' || to_char(sysdate,'yyyy-mm-dd_hh24-mi-ss')
		  || '.log' report_name
from v$instance
/

select '&report_name' save_report_name from dual;

@?/rdbms/admin/spreport

--ed &save_report_name
