

-- get size of buffers currently allocated for BCT change tracking
-- RMAN-08606: WARNING: The Change Tracking File Is Invalid (Doc ID 2160776.1)

select dba_buffer_count_public*dba_entry_count_public*dba_entry_size
from x$krcstat
/


