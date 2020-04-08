
-- get-alert-log-location.sql

col alert_log format a120

select d.value || '/alert_' || i.instance_name || '.log' alert_log
from v$diag_info d
, v$instance i
where d.name = 'Diag Trace'
/

