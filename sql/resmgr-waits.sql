
-- resmgr-waits.sql
-- monitor resmgr waits
-- Scripts and Tips for Monitoring CPU Resource Manager (Doc ID 1338988.1)

/*

The query below shows, for each consumer group, the average number of sessions running (avg_running) and waiting for CPU (avg_waiting) per minute for the past hour. The resource allocation specified in the resource plan (allocation) is expressed as the average number of sessions that the consumer group can be guaranteed to run. In this example, the server has 16 CPUs which means that a maximum of 16 sessions can run at any time. Since Interactive has a resource allocation of 35% (mgmt_p1 = 35), its allocation is 35% of 16 = 5.6, which means that 5.6 of its sessions are guaranteed to run at any time.

Note that the "allocation" data is only valid for single-level plans.  For multi-level plans, calculating the allocation is more complicated so it is not included here.  We strongly recommend using single-level plans.


If avg_running < allocation, then this consumer group did not use its full resource allocation. If avg_running > allocation, then this consumer group was able to use more than its resource allocation. This occurs when other consumer groups do not use all of their allocation.  In this example, an average of 10.4 sessions from the Interactive consumer group were running, which exceeded its allocation of 5.6. 

In this example, Interactive and Adhoc have a significant number of sessions waiting for CPU. For example, an average of 6.8 Interactive sessions waited for CPU. This indicates that (a) the database instance was CPU bound for at least part of this time period and (b) the consumer group had a load that exceeded its allocation.

Sample results:

TIME  NAME               AVG_RUNNING AVG_WAITING ALLOCATION 
----- ------------------ ----------- ----------- ---------- 
13:34 ADHOC_GROUP        1.76        8.4         .8 
13:34 BATCH_GROUP        2.88        .4          2.4 
13:34 ETL_GROUP          0           0           2.4 
13:34 INTERACTIVE_GROUP  10.4        6.8         5.6 
13:34 OTHER_GROUPS       .32         .08         .8 
13:34 SYS_GROUP          0           0           4 

*/

@clears
@resmgr-columns
@resmgr-setup

clear break
break on time

select
   to_char(m.begin_time, 'HH:MI') time
   , m.consumer_group_name
   , m.cpu_consumed_time / 60000 avg_running_sessions
   , m.cpu_wait_time / 60000 avg_waiting_sessions
   , d.mgmt_p1 *
     ( (select value from v$parameter where name = 'cpu_count')/100 )
    allocation
from v$rsrcmgrmetric_history m
   , dba_rsrc_plan_directives d
   , v$rsrc_plan p
where m.consumer_group_name = d.group_or_subplan
   and p.name = d.plan
order by m.begin_time, m.consumer_group_name
/

clear break
