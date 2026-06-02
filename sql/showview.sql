
-- showview.sql
-- Jared Still
-- Added union all to v$fixed_view_definition to show fixed views as well as dba_views
-- prior to 19c this was not needed as some fixed views were included in dba_views

@clears

col cview noprint new_value uview
prompt View name ( partial ok) :
set term off
select '&1' cview from dual;
set term on

@clear_for_spool
col source format a10
col view_name format a30
col text format a200

set linesize 240
set trimspool on

spool ./view.txt

select 'DBA_VIEW' source, view_name, text_vc text
from dba_views
where view_name like upper('%&&uview%')
union all
select 'FIXED' source, view_name, view_definition text
from v$fixed_view_definition
where view_name like upper('%&&uview%')
order by 1
/

spool off
set term on

undef 1
--@clears

set pagesize 100
set linesize 200 trimspool on

ed view.txt

