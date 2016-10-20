set term on feed on

prompt
prompt SQLID? :
prompt

col u_sqlid new_value u_sqlid noprint

set term off feed off verify off
select '&1' u_sqlid from dual;
set term on feed on


@clear_for_spool
set linesize 32767

col sql_texdt format a32767
set trimspool on
set long 1000000

spool sqltext.txt

select sql_text
from dba_hist_sqltext
where sql_id = '&&u_sqlid'
/


spool off

