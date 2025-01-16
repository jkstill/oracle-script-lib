
-- resmgr-columns.sql

col allocation format 0.99
col avg_running_sessions format 99999 head 'AVG|RUNNING|SESSIONS'
col avg_waiting_sessions format 99999 head 'AVG|WAITING|SESSIONS'
col consumer_group format a30
col comments format a40
col cpu_method format a30
col grant_option format a3
col granted_group format a30
col grantee format a30
col group_or_subplan format a30
col initial_group format a3
col initial_rsrc_consumer_group format a30
col mgmt_p1 format 999
col mgmt_p2 format 999
col mgmt_p3 format 999
col mgmt_p4 format 999
col pdb_name format a30 head 'PDB_NAME'
col plan_id format 999999
col plan format a30
col ratio format a10
col status format a20
col sub_plan format a3
col type format a20
col username format a30

COL PLUGGABLE_DATABASE HEADING 'PLUGGABLE|DATABASE' FORMAT A25
COL SHARES FORMAT 999
COL UTILIZATION_LIMIT HEADING 'UTILIZATION|LIMIT' FORMAT 999
COL PARALLEL_SERVER_LIMIT HEADING 'PARALLEL|SERVER|LIMIT' FORMAT 999


