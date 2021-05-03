--unrecoverable.sql
@ttitle 'Unrecoverable Report'

set line 200 trimspool on
set pagesize 100
col name format a80

alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

select name, unrecoverable_time, unrecoverable_change#
from v$datafile
where unrecoverable_time is not null
        and unrecoverable_change# > 0
order by name
/

