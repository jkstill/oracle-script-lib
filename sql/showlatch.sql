
col clatch noprint new_value ulatch
prompt Latches like? :
set term off echo off
select '&1' clatch from dual;
@getlatch &ulatch
