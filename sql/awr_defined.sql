
-- awr_defined.sql
-- run a non-interactive AWR report

define  inst_num     = 1
define  inst_name    = 'emtprd01'

define  num_days     = 3
define  db_name      = 'emtprd0x'
define  dbid         = 3173972526
define  begin_snap   = 24170
define  end_snap     = 24217
define  report_type  = 'html'

define  report_name  =  awrrpt_&&inst_num._&&begin_snap._&&end_snap..&&report_type

@?/rdbms/admin/awrrpti


