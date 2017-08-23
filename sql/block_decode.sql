

-- block_decode.sql
-- find object name for block
-- useful with arg from ORA-1578 errors to find
-- file and segment generating the error

@clears

col cfileid new_value ufileid noprint
col cblockid new_value ublockid noprint

prompt File ID: 
set term off feed off
select '&1' cfileid from dual;

set feed on term on
prompt Block ID:
set term off feed off
select '&2' cblockid from dual;
set feed on term on

--define ufileid=8
--define ublockid=129601


select file_name "FILE CONTAINING BLOCK"
from dba_data_files
where file_id = &ufileid
/

col segment_name format a30
col segment_type format a15

select segment_name, segment_type 
from dba_extents  
where file_id = &ufileid  and &ublockid  between block_id and  
block_id + blocks - 1
/

undef 1 2

