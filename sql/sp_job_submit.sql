

-- job_submit.sql
-- run statspack snapshot every sp_interval minutes
-- at the quarter hour

-- here is how to run a job every sp_interval minutes at the correct time
-- without any time creep

def sp_interval = 30

variable jobno number;
begin
	dbms_job.submit(
		:jobno
		, 'statspack.snap;'
		-- every sp_interval minutes
		, trunc(sysdate,'hh24') +  ( ( &sp_interval + ( &sp_interval * floor(to_number(to_char(sysdate,'mi')) / &sp_interval))) / ( 24 * 60 ))
		, 'trunc(sysdate,''hh24'') +  ( ( &sp_interval + ( &sp_interval * floor(to_number(to_char(sysdate,''mi'')) / &sp_interval))) / ( 24 * 60 ))'
	);
commit;
end;
/

print :jobno


