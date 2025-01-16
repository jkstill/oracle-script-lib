
-- dup-system-stats.sql
-- Jared Still 2017-01-26
-- 
-- jkstill@gmail.com
-- 
-- this SQL will generate PL/SQL to copy System Statistics from one database to another
-- useful for making a Dev environment appear more like Prod
--

@clears

set linesize 200 trimspool on
set pagesizt 60

select 'exec dbms_stats.set_system_stats( pname => ''' || pname || ''', pvalue => ' || pval1 || ')' PLSQL
from sys.aux_stats$
where sname = 'SYSSTATS_MAIN'
and pval1 is not null
/


