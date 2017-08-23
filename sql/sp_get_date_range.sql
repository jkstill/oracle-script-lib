
-- sp_get_date_range.sql
-- enter a begin and end date and this
-- script looks up the snap_id for each
-- and sets variables for them

-- do not use clears.sql as this script is called from other scripts

set line 200

var v_snap_id_low number
var v_snap_id_high number
var v_snap_date_low varchar2(20)
var v_snap_date_high varchar2(20)

col start_date noprint new_value start_date
col end_date noprint new_value end_date

prompt Enter begin date to summarize Statspack Data (mm/dd/yyyy)
set term off feed off
select '&1' start_date from dual;
set term on feed on

prompt Enter end date to summarize Statspack Data (mm/dd/yyyy)
set term off feed off
select '&2' end_date from dual;
set term on feed on

begin

	:v_snap_date_low := '&&start_date';
	:v_snap_date_high := '&&end_date';

	select 
		min(snap_id), max(snap_id)
		into :v_snap_id_low, :v_snap_id_high
	from perfstat.stats$snapshot
	where trunc(snap_time) between
		to_date(:v_snap_date_low,'mm/dd/yyyy')
		and
		to_date(:v_snap_date_high,'mm/dd/yyyy');

end;
/
	

undef 1 2

