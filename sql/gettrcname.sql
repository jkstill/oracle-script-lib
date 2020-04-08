
-- set term and feed off then back on when calling

col utracefile new_value utracefile format a100

select value utracefile from v$diag_info where name = 'Default Trace File'
/


