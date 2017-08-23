
-- db_corrupt.sql
-- jkstill@gmail.com - 2013
-- show rows in v$database_block_corruption
-- and look up which objects they are 
--

col file# format 99999
col block# format 9999999999
col blocks format 999999
col corruption_change# format 999999
col corruption_type format a20 head 'CORRUPTION TYPE'


prompt
prompt Corruption types
prompt
prompt ALL ZERO - Block header on disk contained only zeros.
prompt The block may be valid if it was never filled and if it is in an Oracle7 file.
prompt The buffer will be reformatted to the Oracle8 standard for an empty block.
prompt
prompt FRACTURED - Block header looks reasonable, but the front and back of the block are different versions.
prompt
prompt CHECKSUM - optional check value shows that the block is not self-consistent.
prompt It is impossible to determine exactly why the check value fails, but it probably fails
prompt because sectors in the middle of the block are from different versions.
prompt
prompt CORRUPT - Block is wrongly identified or is not a data block (for example, the data block address is missing)
prompt
prompt LOGICAL - Block is logically corrupt
prompt
prompt NOLOGGING - Block does not have redo log entries
prompt (for example, NOLOGGING operations on primary database can introduce this type of corruption on a physical standby)
prompt

select *
from v$database_block_corruption
order by  corruption_change#
/


prompt
prompt Finding Objects of Corrupt Blocks
prompt

set serveroutput on size 1000000

begin

	for crec in (
		select file#, block#, blocks
		from v$database_block_corruption
		order by  corruption_change#
	)
	loop
		for brec in (
			select e.owner, e.segment_name, e.segment_type, e.partition_name, e.tablespace_name
			from dba_extents e
			where e.file_id = crec.file# and crec.block# between e.block_id and e.block_id + e.blocks - 1
		)
		loop
			dbms_output.put_line('==================================================');
			dbms_output.put_line('OWNER	  : ' || brec.owner);
			dbms_output.put_line('SEGMENT   : ' || brec.segment_name);
			dbms_output.put_line('TYPE		  : ' || brec.segment_type);
			dbms_output.put_line('PARTITION : ' || brec.partition_name);
			dbms_output.put_line('TABLESPACE: ' || brec.tablespace_name);

		end loop;
	end loop;
end;
/
