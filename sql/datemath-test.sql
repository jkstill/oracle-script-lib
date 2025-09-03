
-- datemath-test.sql
-- datemath package test script
-- build the datemath package with datemath-pkg.sql


col epoch_timestamp_tz format 9999999999.999999999
col    epoch_timestamp format 9999999999.999999999
col         epoch_date format 9999999999
col epoch_timestamp_col format a35
col epoch_timestamp_tz_col format a35

set feedback off
alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ssxff';
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_tz_format =  'yyyy-mm-dd hh24:mi:ss tzh:tzm';
set feedback on

select datemath.get_epoch(systimestamp) epoch_timestamp_tz from dual;
select datemath.get_epoch(localtimestamp) epoch_timestamp from dual;
select datemath.get_epoch(sysdate) epoch_date from dual;
select datemath.get_timestamp_from_epoch(datemath.get_epoch(systimestamp)) timestamp_col from dual;
select datemath.get_date_from_epoch(datemath.get_epoch(systimestamp)) date_col from dual;

