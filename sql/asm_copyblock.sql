
-- asm_copyblock.sql
-- does not dump blocks to hex, but dumps to a datafile format
-- How to dump or extract a raw block from a file stored in ASM diskgroup (Doc ID 603962.1)
--  local: sqlplus / as sysasm
-- remote: sqlplus sys/password@//hostname/+ASM1 as sysasm
-- file will be on the db/asm server

declare
	v_AsmFilename varchar2(4000);
	v_FsFilename varchar2(4000);
	v_offstart number;
	v_numblks number;
	v_filetype number;
	v_filesize number;
	v_lbks number;
	v_typename varchar2(4000);
	v_pblksize number;
	v_handle number;
begin
	dbms_output.enable(500000);

	v_AsmFilename := '&ASM_File_Name';
	v_offstart := '&block_to_extract';
	v_numblks := '&number_of_blocks_to_extract';
	v_FsFilename := '&FileSystem_File_Name';

	dbms_diskgroup.getfileattr(v_AsmFilename,v_filetype,v_filesize,v_lbks);
	dbms_diskgroup.open(v_AsmFilename,'r',v_filetype,v_lbks,v_handle,v_pblksize,v_filesize);
	dbms_diskgroup.close(v_handle);

	select 
		decode
		(
			v_filetype
			,1,'Control File'
			,2,'Data File'
			,3,'Online Log File'
			,4,'Archive Log'
			,5,'Trace File'
			,6,'Temporary File'
			,7,'Not Used'
			,8,'Not Used'
			,9,'Backup Piece'
			,10,'Incremental Backup Piece'
			,11,'Archive Backup Piece'
			,12,'Data File Copy'
			,13,'Spfile'
			,14,'Disaster Recovery Configuration'
			,15,'Storage Manager Disk'
			,16,'Change Tracking File'
			,17,'Flashback Log File', 18,'DataPump Dump File'
			,19,'Cross Platform Converted File'
			,20,'Autobackup'
			,21,'Any OS file'
			,22,'Block Dump File', 23,'CSS Voting File'
			,24,'CRS'
		) into v_typename 
	from dual;

	dbms_output.put_line('File: '||v_AsmFilename); dbms_output.new_line;
	dbms_output.put_line('Type: '||v_filetype||' '||v_typename); dbms_output.new_line;
	dbms_output.put_line('Size (in logical blocks): '||v_filesize); dbms_output.new_line;
	dbms_output.put_line('Logical Block Size: '||v_lbks); dbms_output.new_line;
	dbms_output.put_line('Physical Block Size: '||v_pblksize); dbms_output.new_line;

	dbms_diskgroup.patchfile(v_AsmFilename,v_filetype,v_lbks,v_offstart,0,v_numblks,v_FsFilename,v_filetype,1,1);

end;
/


