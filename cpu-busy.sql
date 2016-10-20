-- cpu-busy.sql -  what is keeping CPU busy?

@clears

col opname format a20

set linesize 200 trimspool on
set pagesize 60

@get_date_range


@clear_for_spool
set term off
spool cpu-busy.csv

prompt begin_interval_time,sql_id, username, opcode, opcode_count

with snaps as (
	select snap_id
	from dba_hist_snapshot
	where begin_interval_time 
		between to_date(:v_begin_date, '&d_date_format')
		and to_date(:v_end_date, '&d_date_format')
)
, opcodes as (
-- 10g- only
-- @@opcodes
--
-- 11g+
select command_type id
	,command_name opname
from v$sqlcommand
)
, cpu_states as (
	select sn.begin_interval_time
		, u.username
		, sh.sql_id
		--, sh.sql_opcode
		, o.opname
		, count(*) opcode_count
	from
	dba_hist_active_sess_history sh
	join snaps ss on ss.snap_id = sh.snap_id
	join dba_users u on u.user_id = sh.user_id
	join dba_hist_snapshot sn on sn.snap_id = sh.snap_id 
		and sn.instance_number = sh.instance_number
		and sh.session_state = 'ON CPU'
		and sh.user_id > 0 -- no SYS
		--and sn.snap_id = 270298
	join opcodes o on o.id = sh.sql_opcode
	group by sn.begin_interval_time
		, u.username
		, sh.sql_id
		, o.opname
	order by 1,2,3,4
) 
select 
/*
	to_char(begin_interval_time,'yyyy-mm-dd hh24:mi:ss') begin_interval_time
	, username
	, sql_id
	, opname
	, opcode_count
*/
	to_char(begin_interval_time,'yyyy-mm-dd hh24:mi:ss')
	|| ',' || username
	|| ',' || sql_id
	|| ',' || opname
	|| ',' || opcode_count
from cpu_states
/

spool off
@clears
undef 1 2
ed cpu-busy.csv

