
-- create awr baseline that brackets a time
-- for an event that happened at 14:00, create self expiring AWR baselines for 12:00 - 14:00 for all instance
-- at the same time create a script to generate AWR reports
-- for RAC this will be a report for that instance only
--
-- awr_bracket_baseline.sql <timestamp> <bracket_hours> <retention_days>
-- timestamp is yyyy-mm-dd hh24:mi:ss 
-- awr_bracket_baseline '2018-02-27 14:15:00' 2 30
--
-- the AWR reports are based on script awr_defined.sql
-- to report clusterwide, see awr_RAC_defined.sql


set serveroutput on size unlimited

@clears

col u_expire_days new_value u_expire_days
col u_timestamp new_value u_timestamp
col u_bracket_hours new_value u_bracket_hours

prompt Timestamp (YYYY-MM-DD HH24:MI:SS) : 
prompt
set term off feed off verify off

select '&1' u_timestamp from dual;
set term on feed on


prompt Bracket Hours: 
set term off feed off
select '&2' u_bracket_hours from dual;
set term on feed on

prompt Days until Expiration:  
set term off feed off
select '&3' u_expire_days from dual;
set term on feed on

var n_expire_days number
var n_bracket_hours number
exec :n_expire_days := &u_expire_days
exec :n_bracket_hours := &u_bracket_hours

set pause off echo off term on pagesize 0 linesize 200 trimspool on 
set feed off timing off

declare

	v_instance_name varchar2(30);
	v_db_name varchar2(30);

	v_baseline_pfx varchar2(30) := 'Bracket'; -- used for reporting
	v_baseline_name varchar2(128);

	i_expire_days integer := :n_expire_days;

	e_baseline_exists exception;
	pragma exception_init(e_baseline_exists, -13528);

	procedure p ( p_in varchar2)
	is 
	begin
		dbms_output.put(p_in);
	end;

	procedure pl ( p_in varchar2)
	is 
	begin
		p(p_in);
		dbms_output.put_line(null);
	end;

begin

dbms_output.put_line(lpad('=',30,'='));

for aasrec in (
   with snaps as (
      select distinct
         h.instance_number
         , h.dbid
         , min(h.begin_interval_time) over (partition by h.instance_number) begin_time
         , max(h.end_interval_time) over(partition by h.instance_number)  end_time
         , min(h.snap_id) over(partition by h.instance_number) begin_snap_id
         , max(h.snap_id) over(partition by h.instance_number) end_snap_id
      from dba_hist_snapshot h
      where h.end_interval_time between to_timestamp('&&u_timestamp','YYYY-MM-DD HH24:MI:SS') - interval '&&u_bracket_hours' hour
         and to_timestamp('&u_timestamp','YYYY-MM-DD HH24:MI:SS') + interval '&u_bracket_hours' hour
   ),
   -- get absolute min/max snap id
   -- only necessary if RAC as the snap times may differ between instances
   --
   abs_snaps as (
      select
         dbid, min(s.begin_snap_id) snap_id
      from snaps s
		group by dbid
		union all
		select 
         dbid, max(s.end_snap_id)  snap_id
      from snaps s
		group by dbid
   )
	select 
		min(a.dbid) dbid
		, min (h.snap_id) begin_snap_id
		, max (h.snap_id) end_snap_id
		, min(h.begin_interval_time) begin_time
		, max(h.end_interval_time ) end_time
	from abs_snaps a
	join dba_hist_snapshot h on h.snap_id = a.snap_id
)
loop
	pl('--    begin_time: ' || aasrec.begin_time);
	pl('-- begin snap_id: ' || aasrec.begin_snap_id);
	pl('--      end_time: ' || aasrec.end_time);
	pl('--   end snap_id: ' || aasrec.end_snap_id);
	pl('--          dbid: ' || aasrec.dbid);

	-- create the baselines
	-- catch errors if already exists

	select instance_name into v_instance_name from v$instance ;
	select name into v_db_name from v$database ;

	--pl('define  inst_num    = ' || to_char(aasrec.instance_number));
	--pl('define  inst_name    = ' || v_instance_name);


	begin
		v_baseline_name := v_baseline_pfx || '_'
			|| to_char(aasrec.begin_snap_id) || '_'
			|| to_char(aasrec.begin_time,'yyyymmdd-hh24mi'); --  bug requires max name of 30 bytes

		pl('-- Baseline Name: ' || v_baseline_name);
		--/*
		dbms_workload_repository.create_baseline(
			start_snap_id => aasrec.begin_snap_id,
			end_snap_id => aasrec.end_snap_id,
			baseline_name => v_baseline_name,
			dbid => aasrec.dbid, 
			expiration => i_expire_days
		);

	exception
	when e_baseline_exists then
		pl('-- !!Baseline ' || v_baseline_name || ' already exists');
	when others then 
		raise;
	--*/

	end;
	pl('-- ' || lpad('=',30,'='));

end loop;

end;
/


set pagesize 60

set feed on
set timing on

prompt


