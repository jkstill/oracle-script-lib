
-- since I can never seem to remember this simple syntax


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

