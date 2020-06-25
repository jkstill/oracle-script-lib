
@clears

col v_num_cbrok new_value v_num_cbrok noprint

prompt
prompt How many DRCP Brokers? :
prompt

set term off feed off
select '&1' v_num_cbrok from dual;
set term on feed on

exec DBMS_CONNECTION_POOL.ALTER_PARAM ('','num_cbrok','&v_num_cbrok')

undef 1

