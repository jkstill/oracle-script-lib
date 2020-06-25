

@clears

col v_num_connections new_value v_num_connections noprint

prompt
prompt How many DRCP Connections per Broker allowed? :
prompt

set term off feed off
select '&1' v_num_connections from dual;
set term on feed on


-- minimum allowed is 3
exec DBMS_CONNECTION_POOL.ALTER_PARAM ('','maxconn_cbrok','&v_num_connections')

undef 1

