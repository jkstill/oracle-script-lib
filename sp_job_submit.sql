

-- job_submit.sql
-- run statspack snapshot every 15 minutes
-- at the quarter hour

-- here is how to run a job every 15 minutes at 00,15,30 and 
-- 45 minutes after the hour without any time creep

variable jobno number;
begin
	dbms_job.submit(
		:jobno
		, 'statspack.snap;'
		-- every 15 minutes at 00,15,30 and 45
		, trunc(sysdate,'hh24') +  ( ( 15 + ( 15 * floor(to_number(to_char(sysdate,'mi')) / 15))) / ( 24 * 60 ))
		, 'trunc(sysdate,''hh24'') +  ( ( 15 + ( 15 * floor(to_number(to_char(sysdate,''mi'')) / 15))) / ( 24 * 60 ))'
	);
commit;
end;
/

print :jobno


