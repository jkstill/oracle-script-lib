
-- timestamp-trunc.sql
-- Jared Still
--  jkstill@gmail.com

-- there is no function available to truncate a timestamp 
-- so that the time portion is removed, returning a timestamp
-- trunc(systimestamp) returns a DATE type

-- note that SYSTIMESTAMP_TRUNC_DUMP is a DATE type, not a timestamp

col sysdate_std format a12
col sysdate_dump format a35

col systimestamp_std format a35
col systimestamp_dump format a70

col systimestamp_trunc format a35
col systimestamp_trunc_dump format a70

col systimestamp_trunc_as_ts format a35
col systimestamp_trunc_dump_as_ts format a70

set linesize 200

select 
	sysdate sysdate_std
	, dump(sysdate) sysdate_dump
from dual;

select
	systimestamp systimestamp_std
	, dump(systimestamp) systimestamp_dump
from dual
/

select 
	trunc(systimestamp) systimestamp_trunc
	, dump(trunc(systimestamp)) systimestamp_trunc_dump
from dual
/

select
	cast(trunc(systimestamp) as timestamp) systimestamp_trunc_as_ts
	, dump(cast(trunc(systimestamp) as timestamp)) systimestamp_trunc_dump_as_ts
from dual
/

