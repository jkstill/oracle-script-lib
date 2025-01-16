
set term on feed on

prompt
prompt SQLID? :
prompt


-- which ever is an empty string indicates the mode used
define ash_mode=''
define awr_mode='--'

col u_sqlid new_value u_sqlid noprint

set term off feed off verify off
select '&1' u_sqlid from dual;
set term on feed on


@clear_for_spool
set linesize 32767

col sql_text format a32767
set trimspool on
set long 1000000

spool sqltext.txt

select 
	&ash_mode sql_fulltext sql_text
	&awr_mode sql_text
&ash_mode from v$sqlarea
&awr_mode from dba_hist_sqltext
where sql_id = '&&u_sqlid'
  and rownum < 2
/


spool off

set term on feed on
set linesize 200 trimspool on 
set pages 60

