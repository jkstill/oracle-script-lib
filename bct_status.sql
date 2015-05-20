
col filename format a50
col status format a10

select filename, status from v$block_change_tracking
/

