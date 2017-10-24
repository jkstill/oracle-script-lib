
-- CONNECT / AS SYSDBA

SET PAGESIZE 9999
SET LINESIZE 256
SET TRIMOUT ON
SET TRIMSPOOL ON
COL 'Total Shared Pool Usage' FORMAT 99999999999999999999999
COL bytes FORMAT 999999999999999
COL current_size FORMAT 999999999999999
COL name FORMAT A40
COL value FORMAT A20
ALTER SESSION SET nls_date_format='YYYY-MM-DD HH24:MI:SS';

SPOOL SGAPARAMS.TXT

/* Database identification */
SELECT name, platform_id, database_role FROM v$database;
SELECT * FROM v$version WHERE banner LIKE 'Oracle Database%';

/* Current instance parameter values */
SELECT n.ksppinm name, v.KSPPSTVL value
FROM x$ksppi n, x$ksppsv v
WHERE n.indx = v.indx
AND (n.ksppinm LIKE '%shared_pool%' OR n.ksppinm IN ('_kghdsidx_count', '_ksmg_granule_size', '_memory_imm_mode_without_autosga'))
ORDER BY 1;

/* Current memory settings */
SELECT component, current_size FROM v$sga_dynamic_components;

/* Memory resizing operations */
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status 
FROM v$sga_resize_ops
ORDER BY 1, 2;

/* Historical memory resizing operations */
SELECT start_time, end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status 
FROM dba_hist_memory_resize_ops
ORDER BY 1, 2;

/*  Shared pool 4031 information */
SELECT request_failures, last_failure_size FROM v$shared_pool_reserved;

/* Shared pool reserved 4031 information */
SELECT requests, request_misses, free_space, avg_free_size, free_count, max_free_size FROM v$shared_pool_reserved;

/* Shared pool memory allocations by size */
SELECT name, bytes FROM v$sgastat WHERE pool = 'shared pool' AND (bytes > 999999 OR name = 'free memory') ORDER BY bytes DESC;

/* Total shared pool usage */
SELECT SUM(bytes) "Total Shared Pool Usage" FROM v$sgastat WHERE pool = 'shared pool' AND name != 'free memory';

/* Cursor sharability problems */
/* This version is for >= 10g; for <= 9i substitute ss.kglhdpar for ss.address!!!! */
SELECT sa.sql_text,sa.version_count,ss.*
FROM v$sqlarea sa,v$sql_shared_cursor ss
WHERE sa.address=ss.address AND sa.version_count > 50
ORDER BY sa.version_count ;

SPOOL OFF

