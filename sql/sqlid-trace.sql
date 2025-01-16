
-- trace a particular sqlid regardless of session

-- see http://www.juliandyke.com/Diagnostics/Trace/EnablingTrace.php for more

def v_sqlid='abc123'
def v_sqlid2='xyz789'

-- SQL Trace (10046)
--alter system set events 'sql_trace [sql:&&v_sqlid] bind=true, wait=true';
-- "off" for a specific SQL_ID seems to work better than the generic 'sql_trace off' command
--alter system set events 'sql_trace [sql:&&v_sqlid] off';

-- multiple sqlid
--alter system set events 'sql_trace [sql:&&v_sqlid|&&v_sqlid2] bind=true, wait=true';

-- off
--alter session set events 'sql_trace off';

-- 10053
--alter session set events 'trace[rdbms.SQL_Optimizer.*][sql:&v_sqlid]';

-- off
--alter session set events 'trace[SQL_Optimizer.*] off';

