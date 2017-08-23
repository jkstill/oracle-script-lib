

-- change statspack SQL collection levels
-- limit to very high usage SQL
-- this is based on the SAP PRD instance

begin
	statspack.modify_statspack_parameter( 
		i_disk_reads_th		=> 100000
		, i_executions_th		=> 500000
		, i_parse_calls_th	=> 1000		/* default value */
		, i_buffer_gets_th	=> 1000000
	);
end;
/


