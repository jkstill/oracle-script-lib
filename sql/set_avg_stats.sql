
@@stats_config

@@logsetup set_avg_stats

set timing on

prompt
prompt ===========================================
prompt == Set Average stats for tables/indexes
prompt == when rows == 0
prompt ===========================================
prompt

set echo on
set serveroutput on size 1000000

declare
	type v_tabtyp_i is table of varchar2(100) index by pls_integer;
   v_tables v_tabtyp_i;

	cursor c_tab_zero(owner_in varchar2, tabname_in varchar2) is
		select table_owner, table_name, partition_name, partition_position
		from dba_tab_partitions
		where table_owner = owner_in
		and table_name = tabname_in
		and num_rows = 0
		and partition_position > 1;

	cursor c_tab_avg(owner_in varchar2, tabname_in varchar2) is
		select 
			floor(avg(num_rows)) num_rows_avg
			, floor(avg(blocks)) num_blocks_avg
			, floor(avg(avg_row_len)) avg_row_len
		from dba_tab_partitions
		where table_owner = owner_in
		and table_name = tabname_in
		and num_rows > 0
		and partition_position > 1;

	r_tab_avg c_tab_avg%rowtype;

	cursor c_ind_zero(owner_in varchar2, tabname_in varchar2, indname_in varchar2) is
		select i.table_name, i.index_name, ip.partition_name,  ip.partition_position
		from dba_indexes i
		join dba_ind_partitions ip on ip.index_name = i.index_name and ip.index_owner  = i.owner
		where i.owner = owner_in
		and i.table_name = tabname_in
		and i.index_name = indname_in
		and ip.num_rows = 0
		and ip.partition_position > 1;

	cursor c_ind_avg(owner_in varchar2, tabname_in varchar2, indname_in varchar2) is
		select 
			floor(avg(ip.num_rows)) num_rows_avg
			, floor(avg(ip.leaf_blocks)) num_leaf_blocks_avg
			, floor(avg(ip.distinct_keys)) num_distinct_keys_avg
		from dba_indexes i
		join dba_ind_partitions ip on ip.index_name = i.index_name and ip.index_owner  = i.owner
		where i.owner = owner_in
		and i.table_name = tabname_in
		and i.index_name = indname_in
		and ip.num_rows > 0
		and ip.partition_position > 1;

	r_ind_avg c_ind_avg%rowtype;

	b_chk_ind boolean := false;

begin


@@table_list

	for t in v_tables.first .. v_tables.last
	loop
		dbms_output.put_line('######################################');
		dbms_output.put_line('### Table: ' || v_tables(t));

		-- get avg rows for parts
		open c_tab_avg('&&v_owner',v_tables(t));
		fetch c_tab_avg into r_tab_avg;
		close c_tab_avg;
		

		-- look for parts with 0 rows
		b_chk_ind := false;
		for trec in c_tab_zero('&&v_owner',v_tables(t))
		loop
			b_chk_ind := true;
			dbms_output.put_line('## TAB: ' || trec.table_name || ' PART: ' || trec.partition_name || ' AVG: ' || r_tab_avg.num_rows_avg);
			--/*
			dbms_stats.set_table_stats (
				ownname =>  trec.table_owner
				, tabname =>  trec.table_name
				, partname => trec.partition_name
				, numrows => r_tab_avg.num_rows_avg
				, numblks => r_tab_avg.num_blocks_avg
				, avgrlen => r_tab_avg.avg_row_len
				, no_invalidate => true
			);
			--*/
		end loop;

		-- iterate indexes
		if b_chk_ind then
			for irec in (
				select i.owner, i.table_name, i.index_name
				from dba_indexes i
				where i.owner = '&&v_owner'
				and i.table_name =  v_tables(t)
			)
			loop

				-- get avg rows for parts
				open c_ind_avg(irec.owner, irec.table_name, irec.index_name);
				fetch c_ind_avg into r_ind_avg;
				close c_ind_avg;

				dbms_output.put_line('IND: ' || irec.index_name || ' AVG: ' || r_ind_avg.num_rows_avg);
				dbms_output.put_line('IND: ' || irec.index_name || ' AVG BLKS: ' || r_ind_avg.num_leaf_blocks_avg);

				for iprec in c_ind_zero(irec.owner, irec.table_name, irec.index_name)
				loop
					dbms_output.put_line('ZERO: ' || iprec.partition_name);
					--/*
					dbms_stats.set_index_stats (
						ownname =>  irec.owner
						, indname =>  irec.index_name
						, partname => iprec.partition_name
						, numrows => r_ind_avg.num_rows_avg
						, numlblks => r_ind_avg.num_leaf_blocks_avg
						, numdist => r_ind_avg.num_distinct_keys_avg
						, no_invalidate => true
					);
					--*/
				end loop;
			end loop;
		end if;

	end loop;

	-- verify results
	dbms_output.put_line('######################################');
	dbms_output.put_line('####### VERIFICATION #################');
	dbms_output.put_line('#### success=zero row parts found ####'); 

	for t in v_tables.first .. v_tables.last
	loop
		dbms_output.put_line('### Table: ' || v_tables(t));

		-- look for parts with 0 rows
		b_chk_ind := false;
		for trec in c_tab_zero('&&v_owner',v_tables(t))
		loop
			b_chk_ind := true;
			dbms_output.put_line('## TAB: ' || trec.table_name || ' PART: ' || trec.partition_name || ' AVG: ' || r_tab_avg.num_rows_avg);


		end loop;
	end loop;

end;
/

spool off

set echo off


