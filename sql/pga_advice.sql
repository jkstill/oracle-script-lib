
-- pga_advice.sql
-- display v$pga_target_advice
-- of dubious worth


@pgacols

clear break

set linesize 200 trimspool on
set pagesize 100

select * 
from v$pga_target_advice
order by pga_target_for_estimate
/




