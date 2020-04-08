
-- awr_RAC_defined.sql
-- run a non-interactive AWR report


define  num_days     = 3;
define  db_name      = 'Database';
define  dbid         = 4;
define  begin_snap   = 10;
define  end_snap     = 11;
define  report_type  = 'html';
define  instance_numbers_or_ALL = 'ALL'
define  report_name  =  awrrpt_RAC_&&begin_snap._&&end_snap..&&report_type

@?/rdbms/admin/awrgrpti


