
@@stats_config

@@logsetup set_table_prefs

prompt
prompt ==============================
prompt == SET PREFS for INCREMENTAL
prompt == AND GRANULARITY => ALL
prompt ==============================
prompt

set echo off

declare

	TYPE PrefsElem IS RECORD (
  	prefname    VARCHAR2(30),     -- preference name
  	prefvalue   VARCHAR2(30));      -- preference value

	type PrefTab is TABLE of PrefsElem;

	PrefList PrefTab := PrefTab();

	type v_tabtyp_i is table of varchar2(100) index by pls_integer;

   v_tables v_tabtyp_i;


begin

@@table_list

	PrefList.extend(7);

	PrefList(1).prefname := 'PUBLISH';
	PrefList(1).prefvalue := 'TRUE';

	PrefList(2).prefname := 'INCREMENTAL';
	PrefList(2).prefvalue := 'TRUE';

	PrefList(3).prefname := 'ESTIMATE_PERCENT';
	PrefList(3).prefvalue := 'DBMS_STATS.AUTO_SAMPLE_SIZE';

	PrefList(4).prefname := 'METHOD_OPT';
	PrefList(4).prefvalue := 'FOR ALL COLUMNS SIZE AUTO';

	PrefList(5).prefname := 'GRANULARITY';
	PrefList(5).prefvalue := 'ALL';

	PrefList(6).prefname := 'CASCADE';
	PrefList(6).prefvalue := 'TRUE';

	PrefList(7).prefname := 'DEGREE';
	PrefList(7).prefvalue := '8';

	for t in v_tables.first .. v_tables.last
	loop
		dbms_output.put_line('##############################################################################');
		dbms_output.put_line('### Table: ' || v_tables(t));
		for i in PrefList.first .. PrefList.last
		loop
			dbms_output.put_line(PrefList(i).prefname || ' => ' || PrefList(i).prefvalue );

			--/*
			dbms_stats.set_table_prefs(
				ownname => '&&v_owner',
				tabname => v_tables(t),
				pname => PrefList(i).prefname,
				pvalue => PrefList(i).prefvalue
			);
			--*/

		end loop;
	end loop;

end;
/

spool off

set echo off



