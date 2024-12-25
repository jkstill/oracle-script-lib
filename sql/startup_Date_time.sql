-- last_startup_time.sql
-- Laurent L - zoltix
-- 2020-01-31
-- get Last Starstup Date time

select 
    to_char(startup_time, 'HH24:MI DD-MON-YY') "Startup time"
from 
    v$instance;

