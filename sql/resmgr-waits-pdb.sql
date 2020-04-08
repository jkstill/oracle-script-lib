
-- resmgr-waits-pdb.sql
-- monitor resmgr waits - PDB
-- Scripts and Tips for Monitoring CPU Resource Manager (Doc ID 1338988.1)

/*

The query below shows, for each PDB, the average number of sessions running (avg_running) and waiting for CPU (avg_waiting) per minute for the past hour. The resource allocation specified in the resource plan (allocation) is expressed as the average number of sessions that the PDB can be guaranteed to run.  Issue this query from the root container.

In this example, the server has 16 CPUs which means that a maximum of 16 sessions can run at any time. Since PDB1 has 3 shares and PDB2 has 1 share, PDB1's allocation is 3/(3+1) of 16 = 12, which means that 12 of its sessions are guaranteed to run at any time.

If avg_running < allocation, then this PDB did not use its full resource allocation. If avg_running > allocation, then this PDB was able to use more than its resource allocation. This occurs when other PDBs do not use all of their allocation.  In this example, an average of 13.1 sessions from PDB1 were running, which exceeded its allocation of 12. 

In this example, PDB1 has an average of 5.4 sessions waiting for CPU.  This indicates that (a) the database instance was CPU bound for at least part of this time period and (b) the PDB had a load that exceeded its allocation.

Sample results:

TIME  NAME               AVG_RUNNING AVG_WAITING
----- ------------------ ----------- -----------
13:34 PDB1               13.1        5.4        
13:34 PDB2               2.9         0.1       

*/

@clears
@resmgr-columns
@resmgr-setup

break on time

select to_char(begin_time, 'HH24:MI')
   , name pdb_name
   , sum(avg_running_sessions) avg_running_sessions
   , sum(avg_waiting_sessions) avg_waiting_sessions 
from v$rsrcmgrmetric_history m, 
   v$pdbs p 
where m.con_id = p.con_id 
group by begin_time
   , m.con_id
   , name
order by begin_time
/

clear break

