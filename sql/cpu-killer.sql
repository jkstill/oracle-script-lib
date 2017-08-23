
/*
as of 11.1, this query no longer kills the cpu/pga

SELECT COUNT(*) FROM DUAL CONNECT BY 1=1

This is a query from a notable Oracle performance guru.
However, I cannot remember which one.

Anyway, this variation of it will consume CPU in newer versions of Oracle

*/

select count(dummy)
from (
select dummy
from dual
connect by nocycle 1=1 
order by 1
)
/


