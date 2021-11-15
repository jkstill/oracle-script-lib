
-- spacemap_sum_rpt.sql
-- jared still
-- jkstill@gmail.com
-- 
--
-- report on freespace_map_sum
-- see spacemap2.sql
--

@clears

@title 'Space Map Summary' 200

break on tablespace_name skip 1  on file_name skip 1

column tablespace_name format a15 head 'TABLE SPACE'
column file_name format a70 head 'FILE NAME'
column segment_name format a30 head 'SEGMENT'
column block_id format 999999 head 'BLOCK ID'
column bytes format 999,999,999,999 head 'BYTES'
column blocks format 99,999,999 head 'BLOCKS'
 
set trimspool on

select  
	file_name
	, segment_name
	, block_id
	, blocks
	, bytes
from freespace_map_sum
order by file_name, block_id

spool spacemap_sum_rpt.txt
/

spool off

--ed spacemap_sum_rpt.txt

