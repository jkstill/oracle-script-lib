
-- set term and feed off then back on when calling

col uinstanceowner new_value uinstanceowner noprint

select s.osuser uinstanceowner
from v$session s , v$bgprocess b
where s.paddr = b.paddr
	and b.name = 'PMON';



