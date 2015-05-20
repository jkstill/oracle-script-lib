
-- dual_data_gen.sql
-- use the dual table with connect by to generate a 
-- stream of rows
-- warning: using it to generate very large rowcounts 
-- will greatly increase the size of the PGA
-- 

select myrownum
from (select rownum myrownum from dual connect by level <= 100)
/

