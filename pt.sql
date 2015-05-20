
-- pt.sql
-- Valentin Nikotin
-- Improved print_table - easier quoting on input
-- @pt "select * from dual where dummy = 'X'"


set lin 250 pages 1000 verify off termout off echo off
col 1 new_val 1
col 2 new_val 2
col 3 new_val 3
col 4 new_val 4

select 1,2,3,4 from dual where 1=0;

col query_text new_val query_text
col cols_rem new_val cols_rem
col cols_shr new_val cols_shr
col val_to_ign new_val val_to_ign

select q'{&1}' as query_text,
	''''||replace('&2', ',', ''',''')||'''' as cols_rem,
	''''||replace('&3', ',', ''',''')||'''' as cols_shr,
	q'{&4}' as val_to_ign
from dual;
set termout on

set serveroutput on

declare
	type ttbl is table of varchar2(30);
	p_exclude_cols  ttbl := ttbl (&cols_rem);
	p_shrink60_cols ttbl := ttbl (&cols_shr);
	p_query         varchar2(30000) := q'{&query_text}';
	l_theCursor     integer default dbms_sql.open_cursor;
	l_columnValue   varchar2(4000);
	l_status        integer;
	l_descTbl       dbms_sql.desc_tab;
	l_colCnt        number;
begin
	execute immediate q'{alter session set nls_date_format='dd-mon-yyyy hh24:mi:ss'}';
	dbms_sql.parse(  l_theCursor,  p_query, dbms_sql.native );
	dbms_sql.describe_columns ( l_theCursor, l_colCnt, l_descTbl );
	for i in 1 .. l_colCnt loop
		dbms_sql.define_column (l_theCursor, i, l_columnValue, 4000);
	end loop;
	l_status := dbms_sql.execute(l_theCursor);
	while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
		for i in 1 .. l_colCnt loop
			if not l_descTbl(i).col_name member of p_exclude_cols then
				dbms_sql.column_value ( l_theCursor, i, l_columnValue );
				if l_descTbl(i).col_name member of p_shrink60_cols then
					l_columnValue := substr(l_columnValue, 1, 60);
				end if;
				if nvl(l_columnValue, 'NULL') <> nvl('&val_to_ign', '341rqkfbehjbwjrkggbqxgkb') then 
					dbms_output.put_line ( rpad( l_descTbl(i).col_name, 30 ) || ': ' || l_columnValue );
				end if;
			end if;
		end loop;
		dbms_output.put_line( '-----------------' );
	end loop;
end;
/

col 1 clear
col 2 clear
col 3 clear
col 4 clear
col query_text clear
col cols_rem clear
col cols_shr clear
col val_to_ign clear
undef 1 2 3 4 query_text cols_rem cols_shr val_to_ign


