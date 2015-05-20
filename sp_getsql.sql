

-- sp_getsql.sql
-- retrieve the SQL from 
-- input is the hash value of the sql statement in stats$sqltext
-- this will be seen in reports created by spreport.sql in 9i+
-- where the snapshot level is 5+

@clears

col which_hash new_value which_hash noprint
prompt Hash Value of SQL from STAT$SQLTEXT:
set echo off term off head off
select '&1' which_hash from dual;

var hashvar number
begin
	:hashvar := &&which_hash;
end;
/

set term on head on
set line 120

prompt SQL Text

select sql_text
from stats$sqltext
where hash_value = :hashvar
order by piece
/

undef 1


