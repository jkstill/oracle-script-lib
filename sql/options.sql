
-- options.sql


set linesize 200 trimspool on
set pagesize 100

col parameter format a40
col value format a10

select parameter, value
from v$option
order by 1
/


