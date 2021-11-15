
-- spacemap_sum.sql
-- jared still
-- jkstill@gmail.com
-- 
--
-- creates a summary table of the freespace_map table
-- must run spacemap.sql first

drop table freespace_map_sum purge;

create table freespace_map_sum
as 
select *
from freespace_map
where 1=0
/


declare
	frec_prev freespace_map_sum%rowtype;
	first_row boolean := true;
	block_sum number := 0;
	byte_sum number := 0;
	starting_block_id number;
begin
	for frec in (
		select *
		from freespace_map
		order by file_name, block_id
	)
	loop

		if first_row then
			block_sum := frec.blocks;
			byte_sum  := frec.bytes;
			starting_block_id := frec.block_id;
			first_row := false;
		else

			if frec.file_name = frec_prev.file_name
				and frec.segment_name = frec_prev.segment_name
			then
				block_sum := block_sum + frec.blocks;
				byte_sum  := byte_sum  + frec.bytes;
			else
				insert into freespace_map_sum (
					tablespace_name, segment_name, file_name,
					block_id, bytes, blocks
				)
				values (
					frec_prev.tablespace_name, frec_prev.segment_name, frec_prev.file_name,
					starting_block_id, byte_sum, block_sum
				);

				block_sum := frec.blocks;
				byte_sum  := frec.bytes;
				starting_block_id := frec.block_id;

			end if;
		

		end if;

		frec_prev := frec;

	end loop;

	commit;

end;
/

@spacemap_sum_rpt


