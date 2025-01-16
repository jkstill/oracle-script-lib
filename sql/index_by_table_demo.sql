
-- since I can never seem to remember this simple syntax

set serveroutput on size unlimited

prompt
prompt
prompt Index By Demo
prompt
prompt

declare

	type v_tabtyp_i is table of varchar2(100) index by pls_integer;
	type v_tabtyp_v is table of varchar2(100) index by varchar2(100);

	v_table_i v_tabtyp_i;
	v_table_v v_tabtyp_v;

	v_index varchar2(100);

begin

	v_table_i(1) := 'first entry';
	v_table_i(2) := 'second entry';
	v_table_i(3) := 'third entry';

	v_table_v('portland') := 'oregon';
	v_table_v('vancouver') := 'washington';
	v_table_v('boise') := 'idaho';


	for i in v_table_i.first .. v_table_i.last
	loop
		dbms_output.put_line(v_table_i(i));
	end loop;

	v_index := v_table_v.first;
	while v_index is not null loop
		dbms_output.put_line(v_table_v(v_index));
		v_index := v_table_v.next(v_index);
	end loop;

end;
/

-- sorting an index by table of varchar2 with an associative array

prompt
prompt
prompt Sorting an Index By Table
prompt
prompt



declare
	type string_table is table of varchar2(50) index by binary_integer;
	my_table string_table;

	type sort_typ is table of integer index by varchar2(50);
	sort_table sort_typ;
	s_idx varchar2(50);
begin

	my_table(1) := 'Apple';
	my_table(2) := 'Banana';
	my_table(3) := 'Orange';
	my_table(4) := 'Kiwi';
	my_table(5) := 'Grapes';
  
	for i in 1 .. my_table.last	
	loop
		null;
		sort_table(my_table(i)) := i;
	end loop;

	s_idx := sort_table.first;
	while s_idx is not null
	loop
		dbms_output.put_line(sort_table(s_idx) || ' ' || s_idx);
		s_idx := sort_table.next(s_idx);
	end loop;
end;
/


