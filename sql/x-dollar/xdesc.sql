

-- DBMS_SQL ref, including the record types
-- https://docs.oracle.com/en/database/oracle/oracle-database/18/arpls/DBMS_SQL.html

-- Data Types
-- https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/Data-Types.html#GUID-A3C0D836-BADB-44E5-A5D4-265BA5968483

-- data types reference
-- 'Oracle Built-in Data Types' in the SQL Language Reference
-- as of 19c
-- https://docs.oracle.com/cd/B19306_01/server.102/b14200/sql_elements001.htm

set serveroutput on size unlimited
set scan on

col v_xtab new_value v_xtab noprint
var b_xtab varchar2(30)


prompt Which X$ Table:
set term off
select '&1' v_xtab from dual;

exec :b_xtab := '&v_xtab'

set term on

DECLARE
  c           number;
  d           number;
  col_cnt     integer;
  f           boolean;
  rec_tab     dbms_sql.desc_tab2;
  col_num    number;
	h1 	varchar2(80);
	h2 	varchar2(80);

	type v_data_mapt is table of varchar2(30) index by pls_integer;
	v_col_types v_data_mapt;

	procedure print_rec(rec in dbms_sql.desc_rec2) is
		v_precision_str varchar2(30) := ' ';
		v_desc_str varchar2(60);
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


BEGIN
	
	map_types;

	c := dbms_sql.open_cursor;

	h1 := rpad('Name',31) 
		|| rpad('Null?',9)
		|| 'Type';

	h2 := rpad('-',30,'-') || ' ' 
		|| rpad('-',8,'-') || ' '
		|| rpad('-',30,'-');

	dbms_output.put_line(h1);
	dbms_output.put_line(h2);

	dbms_sql.parse(c, 'select * from &v_xtab' , dbms_sql.native);

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

END;
/


-- scan must be off as there may be a number of ampersand characters in the comments
set scan off
set tab off

set linesize 160 trimspool on
set pagesize 500

col x_dollar_table format a30
col abstract format a30 wrap
col comments format a80 wrap

with xt as (
	@@xdllr-tablist.sql
),
xa as (
	@@xdllr-abstract-list.sql
),
xc as (
	@@xdllr-comments.sql
)
select 
	xt.x_dollar_table
	, xa.abstract
	, xc.comments
from xt
join xa on xa.id = xt.id
join xc on xc.id = xt.id
where xt.x_dollar_table like lower('%' || :b_xtab || '%') 
/



