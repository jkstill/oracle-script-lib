
-- build-record.sql
-- Jared Still
-- jkstill@gmail.com
-- create a pl/sql record from table columns

/*

SQL# desc test1
 Name                          Null?    Type
 ----------------------------- -------- --------------------
 OWNER                                  VARCHAR2(120)
 OBJECT_ID                              NUMBER
 OBJECT_NAME                            VARCHAR2(128)

SQL#
SQL# @build_record test1
Build Records for which table(s):
( Include wildcard if needed )
-- table:  test1
  type test1_rectype is record (
    owner test1.owner%type,
    object_id test1.object_id%type,
    object_name test1.object_name%type
  );

*/


@clears

break on table_name skip 1
set pages 0

prompt Build Records for which table(s):
prompt ( Include wildcard if needed )
set feed off term off
col ctables noprint new_value utables
select '&1' ctables from dual;
set feed on term on

set serveroutput on size unlimited

declare
	rec_str varchar2(2000);

	TAB varchar2(1) := chr(9);
	LF varchar2(1) := chr(10);

	rowcount integer;
	curr_row integer;

begin
	for tabrec in (
		select table_name 
		from user_tables 
		where table_name like upper('&utables')
		order by table_name
		)
	loop

		dbms_output.put_line ( TAB || '-- table:  ' || lower(tabrec.table_name)  );
		dbms_output.put_line ( TAB || 'type ' || lower(tabrec.table_name) || '_rectype' || ' is record (' );

		select count(*) into rowcount
		from user_tab_columns
		where table_name = upper(tabrec.table_name);
		
		curr_row := 0;

		for colrec in (
			select column_name
			from user_tab_columns
			where table_name = upper(tabrec.table_name)
			order by column_id
			)
		loop

			curr_row := curr_row + 1;

			dbms_output.put( TAB || TAB || lower(colrec.column_name) || ' ' 
				|| lower(tabrec.table_name) || '.' 
				|| lower(colrec.column_name) || '%type') ;

			if curr_row = rowcount then
				dbms_output.put_line('');
			else 
				dbms_output.put_line(',');
			end if;
			
		end loop;

		
		dbms_output.put_line( TAB || ');' || LF );

	end loop;

end;
/


undef 1

