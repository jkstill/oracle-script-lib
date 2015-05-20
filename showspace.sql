
-- showspace.sql
-- use dbms_space to determine actual space used.
-- e.g. showspace schema_name object_name object_type


set verify off
set echo off feed off


-- schema name
col cschema_name noprint new_value uschema_name
prompt Schema Name: 
set feed off term off
select upper('&1') cschema_name from dual;
set feed on term on


-- object name
col cobject_name noprint new_value uobject_name
prompt Object Name: 
set feed off term off
select upper('&2') cobject_name from dual;
set feed on term on


-- object type
col cobject_type noprint new_value uobject_type
prompt Object Type: 
set feed off term off
select upper('&3') cobject_type from dual;
set feed on term on


set serverout on size 1000000

declare

	total_blocks	number;
	unused_blocks	number;

	total_bytes		number;
	unused_bytes	number;

	last_used_extent_file_id 	number;
	last_used_extent_block_id	number;
	last_used_block				number;

	free_blocks number;


begin

	dbms_space.free_blocks(
		SEGMENT_OWNER =>upper('&&uschema_name'),
		SEGMENT_NAME => upper('&&uobject_name'),
		SEGMENT_TYPE => upper('&&uobject_type'),
		FREELIST_GROUP_ID => 0,
		FREE_BLKS => free_blocks
	);

	dbms_space.unused_space(
		upper('&&uschema_name'),upper('&&uobject_name'),upper('&&uobject_type'),
		total_blocks, total_bytes,
		unused_blocks, unused_bytes,
		last_used_extent_file_id ,
		last_used_extent_block_id,
		last_used_block
	);
	dbms_output.put_line(
		'Total space used by ' || 
		upper('&&uschema_name') || '.' || 
		upper('&&uobject_name')
	);
	dbms_output.put_line('	TOTAL   BLOCKS: ' || to_char( total_blocks ));
	dbms_output.put_line('	TOTAL   BYTES : ' || to_char( total_bytes ));
	dbms_output.put_line('	USED    BLOCKS: ' || to_char( total_blocks - unused_blocks ));
	dbms_output.put_line('	USED    BYTES : ' || to_char( total_bytes - unused_bytes ));
	dbms_output.put_line('	UNUSED  BLOCKS: ' || to_char( unused_blocks ));
	dbms_output.put_line('	UNUSED  BYTES : ' || to_char( unused_bytes ));
	dbms_output.put_line('	FREE    BLOCKS: ' || to_char( free_blocks ));

end;
/

set feed on

undef 1 2 3


