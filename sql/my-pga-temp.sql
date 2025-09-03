
-- my-pga-temp.sql
-- Jared Still 2023

/*

NAME                                                VALUE
---------------------------------------- ----------------
session pga memory                              8,002,536
temp space allocated (bytes)                            0

2 rows selected.
*/

col value format 999,999,999,999
col name format a40

select
	name
	, sum(m.value) value
from v$mystat m
join v$statname s on s.statistic# = m.statistic#
	and s.statistic# in (39,604) -- pga and temp bytes
group by name
/

