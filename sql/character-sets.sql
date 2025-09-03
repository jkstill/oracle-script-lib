
-- character-sets.sql
-- display valid character sets
-- Jared Still 2024

set linesize 200 trimspool on
set pagesize 100

col value format a30

select  value,isdeprecated
from v$nls_valid_values
where parameter = 'CHARACTERSET'
and isdeprecated != 'TRUE'
order by value
/

