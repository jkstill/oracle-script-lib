
-- plsql-error.sql
-- show line of error in context from
-- package headers and body, functions, procedures, triggers
-- Jared Still

@clears

define lines_context=5

col u_pkg new_value u_pkg noprint

set feed off term off echo off verify off
select upper('&1') u_pkg from dual;
set feed on term on

col linenum format a12 head 'Line#'
col text format a150 head 'Line'
col type format a50 head 'Type'

set pagesize 500
set linesize 250 trimspool on

break on type skip 1

/*
use a range of -N -1 to +N 
for line boundaries
example:

@plsql-error broken_trigger

Type                           Line#        Line
------------------------------ ------------ ---------------------------------------------------------
TRIGGER BROKEN_TRIGGER              1       trigger broken_trigger
                               ===> 2       after insert or update or delete
                                            ERROR-49: PLS-00049: bad bind variable 'NEW.B4'

                                    3       on parse_tab
                                    4       for each row
                                    5       begin
                                    6               :new.b4 := cast(hextoraw('DEADBEEF') as blob);
                                    7       end;
7 rows selected.
*/

with gen_neg(id) as (
	select 0 id from dual
	union all
	select gen_neg.id - 1 as id
	from gen_neg
	where id > -&&lines_context
),
gen_pos(id) as (
	select 1 id from dual
	union all
	select gen_pos.id + 1 as id
	from gen_pos
	where id < &&lines_context
),
gen_range as (
	select id from gen_neg
	union all
	select id from gen_pos
),
error_context_lines as (
	select distinct e.type, e.line + g.id line
		--, e.line, g.id
	from user_errors e,
 	gen_range g
	where e.name='&&u_pkg'
	and e.line + g.id > 0
	order by 1
)
select 
	s.type || ' ' || s.name type
		--case when s.type = 'PACKAGE BODY' then ' (body)' else '' end type
	, case when e.line >0 then '===> ' else '     ' end ||
		to_char(s.line) linenum
	, s.text || 
	case when e.line >0 then e.attribute || '-' || to_char(e.message_number) || ': ' || e.text else '' end text
from user_source s
join error_context_lines ecl
on 
	s.name = '&&u_pkg'
	and ecl.type = s.type 
	and ecl.line = s.line
left outer join user_errors e
	on e.name = s.name
	and e.type = s.type
	and e.line = s.line
order by s.type, s.line
/

undef 1

clear break

