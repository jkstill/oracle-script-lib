
-- spacemap.sql
-- jared still
-- jkstill@gmail.com

-- create a spacemap, showing all space used and free,

drop table freespace_map;

create table freespace_map (
	tablespace_name varchar2(30),
	segment_name varchar2(30),
	file_name varchar2(60),
	block_id number,
	bytes number,
	blocks number
)
/

insert into  freespace_map( tablespace_name, file_name, segment_name, block_id, bytes, blocks )
select  
	s.tablespace_name tablespace_name, 
	f.file_name file_name, 
	'FREE' segment_name, 
	s.block_id block_id, 
	s.bytes bytes, 
	s.blocks blocks
from dba_free_space s, dba_data_files f
where  f.file_id = s.file_id
union
select  
	e.tablespace_name tablespace_name, 
	f.file_name file_name, 
	e.segment_name,
	e.block_id block_id, 
	e.bytes bytes, 
	e.blocks blocks
from dba_extents e, dba_data_files f
where  f.file_id = e.file_id 
/

commit;

@spacemap_rpt

