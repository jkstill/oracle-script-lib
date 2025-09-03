
-- run all advice scripts

-- ls -1 *advic*.sql| grep -v run-advice-scripts | xargs -I {}  perl -e 'print "prompt\nprompt #### {}\nprompt\n\@{}\n"'

set echo off term on feed on ver off pages 100 lines 200 trimspool on

spool run-advice-scripts.log

prompt
prompt #### db_cache_advice.sql
prompt
@db_cache_advice.sql
prompt
prompt #### pga_advice_hist.sql
prompt
@pga_advice_hist.sql
prompt
prompt #### pga_advice_selective.sql
prompt
@pga_advice_selective.sql
prompt
prompt #### pga_advice.sql
prompt
@pga_advice.sql
prompt
prompt #### sga_advice_selective.sql
prompt
@sga_advice_selective.sql
prompt
prompt #### shared_pool_advice_selective.sql
prompt
@shared_pool_advice_selective.sql
prompt
prompt #### shared_pool_advice.sql
prompt
@shared_pool_advice.sql



spool off


