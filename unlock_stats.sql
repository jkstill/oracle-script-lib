
@@stats_config

@@logsetup unlock_stats

prompt
prompt ==============================
prompt == UNLOCK TABLE STATS
prompt ==============================
prompt


set echo on

declare
	type v_tabtyp_i is table of varchar2(100) index by pls_integer;
   v_tables v_tabtyp_i;
begin

@@table_list

	for t in v_tables.first .. v_tables.last
	loop
		dbms_output.put_line('##############################################################################');
		dbms_output.put_line('### Table: ' || v_tables(t));
		dbms_stats.unlock_table_stats('&&v_owner',v_tables(t));
	end loop;

end;
/

spool off

set echo off


