
-- awr-export.sql
-- as per Simon Pane
-- https://www..com/blog/author/pane/
-- simple yet effective
-- output is expdp dump file - requires an appropriate Oracle DIRECTORY object


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

