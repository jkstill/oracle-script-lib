
-- disable the resource manager
-- this script first closes any open maintenance windows
-- if a resource window is left open the scehduler can become rather
-- confused and leave a maintenance window open indefinitely

col repeat_interval format a60
set line 200
set pagesize 60

spool drm.log

select
        window_name
        , resource_plan
		  , enabled
        , last_START_DATE
        , next_START_DATE
        , REPEAT_INTERVAL
from DBA_SCHEDULER_WINDOWS
/


alter system set resource_manager_plan='' scope=both sid='*';

begin
	for orec in (
		select window_name
		from dba_scheduler_windows
		where active = 'TRUE'
	)
	loop
		dbms_scheduler.close_window(orec.window_name);
	end loop;

	for wrec in (
		select window_name
		from dba_scheduler_windows
		where resource_plan is not null
	)
	loop
		dbms_scheduler.set_attribute(wrec.window_name,'RESOURCE_PLAN','');
	end loop;
end;
/


col name format a30
col value format a30

select i.instance_name, p.name, p.value
from gv$parameter p, gv$instance i
where p.name = 'resource_manager_plan'
and p.inst_id = i.instance_number
order by 1
/



select
        window_name
        , resource_plan
		  , enabled
        , last_START_DATE
        , next_START_DATE
        , REPEAT_INTERVAL
from DBA_SCHEDULER_WINDOWS
/

spool off

