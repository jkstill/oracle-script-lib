
-- awr-export.sql
-- as per Simon Pane
-- https://www.pythian.com/blog/author/pane/
-- simple yet effective
-- best to run from the db server
-- could be run remotely - requires same version and patch level of oracle server


COLUMN OUTPUT NEW_VALUE dbname
COLUMN MIN_SNAP_ID NEW_VALUE begin_snap_id
COLUMN MAX_SNAP_ID NEW_VALUE end_snap_id
 
SELECT instance_name||'_awrdat_'||TO_CHAR(sysdate,'YYYYMMDD') OUTPUT FROM v$instance;
SELECT MIN(snap_id) MIN_SNAP_ID, MAX(snap_id) MAX_SNAP_ID FROM dba_hist_snapshot;
 
define dbid = '';
define num_days = 0;
define begin_snap = &&begin_snap_id
define end_snap   = &&end_snap_id
define file_name = '&&dbname'
 
@?/rdbms/admin/awrextr.sql

