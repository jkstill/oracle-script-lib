

drop table sysevent_snap;
drop table sysevent_begin;

create table sysevent_snap (
	begin_time date
	, end_time date
);

create table sysevent_begin
as
select
	inst_id,
	event_id,
	event,
	total_waits_fg total_waits,
	total_timeouts_fg total_timeouts,
	--time_waited/100 time_waited,
	time_waited_micro_fg/1000000 time_waited,
	average_wait_fg/100 average_wait,
	con_id
from gv$system_event
-- order by doesn't work < 8i
--order by time_waited
/

insert into sysevent_snap(begin_time) values(sysdate);
commit;

