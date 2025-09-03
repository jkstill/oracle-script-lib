
@clears

col cview noprint new_value uview
prompt View name ( partial ok) :
set term off
select '&1' cview from dual;
set term on

@clear_for_spool
col view_name format a30
col text format a200

set long 50000
set linesize 240
set trimspool on

spool ./view.txt

select view_name, text
from dba_views
where view_name like upper('%&&uview%')
/

--select view_name, view_definition
--from v$fixed_view_definition
--where view_name like upper('%&&uview%')
--/

spool off
set term on

undef 1
--@clears

set pagesize 100
set linesize 200 trimspool on


ed view.txt

