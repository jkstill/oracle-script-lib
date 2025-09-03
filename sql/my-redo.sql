

-- my-redo.sql
-- Jared Still 2023
-- just get redo size

col statname format a20
col redo_bytes format 99,999,999,999

select 
	s.name statname
	, m.value redo_bytes
from v$mystat m
join v$statname s on s.statistic# = m.statistic# 
where s.name = 'redo size'
/
