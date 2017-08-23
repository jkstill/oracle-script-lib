

-- drcp_pool_stats.sql
-- pass the entire SQL to the script
-- @print_table_2 'select * from dual'
-- see http://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:4845523000346615725


@print_table_2 'select * from V$CPOOL_STATS'

