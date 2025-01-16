
-- get_date_range.sql
-- get a beginning and ending date for whatever
-- format for input is YYYY-MM-DD HH24:MI:SS
-- Jared Still
-- 
-- jkstill@gmail.com


define d_date_format='YYYY-MM-DD HH24:MI:SS'
col d_begin_date new_value d_begin_date noprint
col d_end_date new_value d_end_date noprint

prompt
prompt Please enter dates as &d_date_format
prompt

prompt Beginning Date:

set term off feed off
select '&&1' d_begin_date from dual;
set term on

prompt Ending Date:

set term off feed off
select '&&2' d_end_date from dual;
set term on	 feed on

-- exit if dates not valid
whenever sqlerror exit

select to_char(to_date('&d_begin_date','&d_date_format'),'&d_date_format') begin_date,
	to_char(to_date('&d_end_date','&d_date_format'),'&d_date_format') end_date
from dual;

-- exit if ending is lt beginning

var v_begin_date varchar2(30)
var v_end_date varchar2(30)

declare
	n_date_compare number;
begin
	select
		to_date('&d_end_date','&d_date_format') -
		to_date('&d_begin_date','&d_date_format')
	into n_date_compare
	from dual;

	if n_date_compare <= 0 then
		raise_application_error(-20000,'end date must be > begin date');
	end if;

	:v_begin_date := '&d_begin_date';
	:v_end_date := '&d_end_date';

end;
/


whenever sqlerror continue

undef 1 2
