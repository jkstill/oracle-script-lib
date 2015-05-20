
-- example of the q quoting mechanism for string literals
-- q_quote " select * from dual where dummy = 'X'"
-- without the q'[]' syntax it is nearly impossible to get this to work
-- the [] could also be {} or (), or even !

col v_sql new_value v_sql noprint

set term off feed off
select q'[&1]' v_sql from dual;
set term on feed on

prompt V_SQL: &&v_sql

