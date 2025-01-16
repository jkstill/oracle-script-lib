

/*

 DBMS_SQL ref, including the record types
 https://docs.oracle.com/en/database/oracle/oracle-database/18/arpls/DBMS_SQL.html

 Data Types
 https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/Data-Types.html#GUID-A3C0D836-BADB-44E5-A5D4-265BA5968483

 data types reference
 'Oracle Built-in Data Types' in the SQL Language Reference
 as of 19c
 https://docs.oracle.com/cd/B19306_01/server.102/b14200/sql_elements001.htm

 There are X$ tables that can be joined to get the X$ columns.
 However, there are some version dependent difficulties in joining these tables, as found by Frits Hoogland

 https://fritshoogland.wordpress.com/2019/10/31/oracle-internal-data-dictionary-oddity/

 Using the dbms_sql.describe is less convenient, but there is no need to care about the oracle version

 The definitions for many X$ tables can be found via google.

 Much of the external knowledge about Oracle X$ tables comes from Oracle Support Note 22241.1 ;
 'List of X$ Tables and how the names are derived'

 This note is no longer available from Oracle.  Some skillful web searching may turn up a copy of it though.



*/


set serveroutput on size unlimited

DECLARE
  c           number;
  d           number;
  col_cnt     integer;
  f           boolean;
  rec_tab     dbms_sql.desc_tab2;
  col_num    number;
	h1 	varchar2(80);
	h2 	varchar2(80);

	e_cross_container_query exception;
	e_no_such_table exception;
	pragma exception_init(e_cross_container_query, -65318);
	pragma exception_init(e_no_such_table, -942);

	type v_data_mapt is table of varchar2(30) index by pls_integer;
	v_col_types v_data_mapt;

	procedure print_rec(rec in dbms_sql.desc_rec2) is
		v_precision_str varchar2(128) := ' ';
		v_desc_str varchar2(256);
		v_nullable varchar2(8);
	begin

		if  v_col_types(rec.col_type) = 'NUMBER'  then
			if  rec.col_precision = 0 then
				v_precision_str := '';
			else
				v_precision_str := '(' || to_char(rec.col_precision) || ',' || to_char(rec.col_scale) || ')';
			end if;
		elsif v_col_types(rec.col_type) in ('RAW','VARCHAR2','CLOB','CHAR','BLOB') then
			v_precision_str := '(' || to_char(rec.col_max_len) || ')';
		end if;

		-- 30 char for colname
		-- 8 char for null
		-- 20 char for type
		if rec.col_null_ok then
			v_nullable := ' ';
		else
			v_nullable := 'NOT NULL';
		end if;

		v_desc_str := rpad(rec.col_name,31) 
			|| rpad(v_nullable,9) 
			|| v_col_types(rec.col_type) || ' ' || v_precision_str;
		dbms_output.put_line(v_desc_str);

END;


	procedure map_types 
	is
	begin
		-- also NVARCHAR2
		v_col_types(1) := 'VARCHAR2';

		-- also FLOAT
		v_col_types(2) := 'NUMBER';

		v_col_types(8) := 'LONG';

		v_col_types(12) := 'DATE';
		v_col_types(100) := 'BINARY_FLOAT';  -- different in 10g
		v_col_types(101) := 'BINARY_DOUBLE';  -- different in 10g
		v_col_types(180) := 'TIMESTAMP';
		v_col_types(181) := 'TIMESTAMP WITH TIME ZONE';
		v_col_types(231) := 'TIMESTAMP WITH LOCAL TIME ZONE';
		v_col_types(182) := 'INTERVAL YEAR TO MONTH';
		v_col_types(183) := 'INTERVAL DAY TO SECOND';
		v_col_types(23) := 'RAW';
		v_col_types(24) := 'LONG RAW';
		v_col_types(69) := 'ROWID';
		v_col_types(208) := 'UROWID';
		-- also NCHAR
		v_col_types(96) := 'CHAR';
		-- also NCLOB
		v_col_types(112) := 'CLOB';
		v_col_types(113) := 'BLOB';
		v_col_types(114) := 'BFILE';


	end;

	procedure table_banner(table_name_in varchar2)
	is
	begin
		dbms_output.new_line;
		dbms_output.put_line('########################################################');
		dbms_output.put_line('## ' || table_name_in );
		dbms_output.put_line('########################################################');
	end;

	-- for unexpected errors
   procedure show_errors
   is
   begin
      dbms_output.put_line ('-------SQLERRM-------------');
      dbms_output.put_line ('Err Msg Length: ' || to_char(length(sqlerrm)));
      dbms_output.put_line (SQLERRM);
      dbms_output.put_line ('-------FORMAT_ERROR_STACK--');
      dbms_output.put_line ('Err Stack Length: ' ||  to_char(length (dbms_utility.format_error_stack)));
      dbms_output.put_line (dbms_utility.format_error_stack);
   END;

BEGIN
	
	
	map_types;


	h1 := rpad('Name',31) 
		|| rpad('Null?',9)
		|| 'Type';

	h2 := rpad('-',30,'-') || ' ' 
		|| rpad('-',8,'-') || ' '
		|| rpad('-',30,'-');

	dbms_output.put_line(h1);
	dbms_output.put_line(h2);

	for xrec in (select name from v$fixed_table where name like 'X$%')
	loop

		--dbms_output.put_line(xrec.name);
		table_banner(xrec.name);

		c := dbms_sql.open_cursor;

		begin
			dbms_sql.parse(c, 'select * from ' || xrec.name || ' where 1=0', dbms_sql.native);
		exception
		when e_cross_container_query then
			dbms_output.put_line('===========================================');
			dbms_output.put_line('Error 65318: e_cross_container_query error');
			dbms_output.put_line('Table: ' || xrec.name);
			dbms_output.put_line('===========================================');
			dbms_sql.close_cursor(c);
			continue;
		when e_no_such_table then
			dbms_output.put_line('===========================================');
			dbms_output.put_line('Error 942: Table does not exist');
			dbms_output.put_line('Table: ' || xrec.name);
			dbms_output.put_line('===========================================');
			dbms_sql.close_cursor(c);
			continue;
		when others then 
			dbms_output.put_line('===========================================');
			dbms_output.put_line('Table: ' || xrec.name);
			show_errors;
			dbms_output.put_line('===========================================');
			dbms_sql.close_cursor(c);
			continue;
		end;

		d := dbms_sql.execute(c);
		dbms_sql.describe_columns2(c, col_cnt, rec_tab);

		-- Following loop could simply be for j in 1..col_cnt loop.
		col_num := rec_tab.first;
		if (col_num is not null) then
			loop
				print_rec(rec_tab(col_num));
				col_num := rec_tab.next(col_num);
				exit when (col_num is null);
			end loop;
		end if;
 
		dbms_sql.close_cursor(c);

	end loop;

END;
/


