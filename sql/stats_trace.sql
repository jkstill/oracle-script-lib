
set echo on
/*

Enable tracing in DBMS_STATS

http://www.freelists.org/post/oracle-l/dbms-statset-paramtrace3166
http://www.orafaq.com/maillist/oracle-l/2006/08/22/0985.htm
http://www.hellodba.com/reader.php?ID=30&lang=en

Values to use for dbms_stats.set_param('trace','value')

in 11g the set_param procedure is deprecated
the dbms_stats.set_global_prefs procedure will also work for this.

Values are additive

for instance to trace table stats:

  session + table + backtrace + query
  2182 = 2 + 4 + 128 + 2048 
  exec dbms_stats.set_param('trace','2182')


    1 = use dbms_output.put_line instead of writing into trace file
    2 = enable dbms_stat trace only at session level
    4 = trace table stats
    8 = trace index stats
   16 = trace column stats
   32 = trace auto stats - save session state log into sys.stats_target$_log
   64 = trace scaling
  128 = dump backtrace on error
  256 = dubious stats detection
  512 = auto stats job
 1024 = parallel execution tracing
 2048 = print query before execution
 4096 = partition prune tracing
 8192 = trace stat differences
16384 = trace extended column stats gathering
32768 = trace approximate NDV (number distinct values) gathering

SQL to create the table sys.stats_target$_log

   create table sys.stats_target$_log
   as
   select t.*, rpad('X',30,'X') session_id, 1 state 
   from sys.stats_target$ t
   where 1=0

Trace extended stats
16406 = 2 + 4 + 16 + 16384

Trace approximate NDV
32790 = 2 + 4 + 16 + 32768

Definition from dbms_stats_internal package:

DSC_DBMS_OUTPUT_TRC CONSTANT NUMBER := 1;
DSC_SESSION_TRC     CONSTANT NUMBER := 2;
DSC_TAB_TRC         CONSTANT NUMBER := 4;
DSC_IND_TRC         CONSTANT NUMBER := 8;
DSC_COL_TRC         CONSTANT NUMBER := 16;
DSC_AUTOST_TRC      CONSTANT NUMBER := 32; save session state log into sys.stats_target$_log
DSC_SCALING_TRC     CONSTANT NUMBER := 64;
DSC_ERROR_TRC       CONSTANT NUMBER := 128;
DSC_DUBIOUS_TRC     CONSTANT NUMBER := 256;
DSC_AUTOJOB_TRC     CONSTANT NUMBER := 512;
DSC_PX_TRC          CONSTANT NUMBER := 1024;
DSC_Q_TRC           CONSTANT NUMBER := 2048;
DSC_CCT_TRC         CONSTANT NUMBER := 4096;
DSC_DIFFST_TRC      CONSTANT NUMBER := 8192;
DSC_USTATS_TRC      CONSTANT NUMBER := 16384;
DSC_SYN_TRC         CONSTANT NUMBER := 32768;


This query does not show the current session values if the DSC_SESSION_TRC value is used:


Note:
The '1' value for SPARE1 will be set to null if trace prefs are set.
SPARE1 is used as a flag to see if trace has ever been set.

set linesize 200

COLUMN   sval1 ON FORMAT   999999
COLUMN   sval2 ON FORMAT   a26
COLUMN   spare1 ON FORMAT   999999999999999999
COLUMN   spare2 ON FORMAT   a6
COLUMN   spare3 ON FORMAT   a6
COLUMN   spare4 ON FORMAT   a40
COLUMN   spare5 ON FORMAT   a6
COLUMN   spare6 ON FORMAT   a6

select sname, sval1, sval2
	,spare1, spare2, spare3, spare4, spare5, spare6
from SYS.OPTSTAT_HIST_CONTROL$
order by sname


*/

set echo off


