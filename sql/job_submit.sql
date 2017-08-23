

-- job_submit.sql
-- example of submitting a job to run
-- daily at 01:00

VARIABLE jobno number;
BEGIN
	DBMS_JOB.SUBMIT(
		:jobno,
		'my_proc;',
		-- this adds new rows to dm.defect tracking
		-- this currently takes 8 minutes ( 2/26/02 )
		-- run every morning at 01:00
		trunc(sysdate+1) + ( 60 / 1440 ),
		-- every morning at 01:00
		'trunc(sysdate+1) + ( 60 / 1440 )'
	);
	commit;
END;
/
print :jobno

-- here is how to run a job on the hour, every hour

variable jobno number;
begin
	dbms_job.submit(
		:jobno
		, 'my_proc;'
		-- every hour on the hour
		, trunc(sysdate + ( 60 - to_number(to_char(trunc(sysdate,'mi'),'mi'))) / (24*60),'mi')
		, 'trunc(sysdate + ( 60 - to_number(to_char(trunc(sysdate,''mi''),''mi''))) / (24*60),''mi'')'
	);
commit;
end;
/

print :jobno

-- here is how to run a job every 15 minutes at 00,15,30 and 
-- 45 minutes after the hour without any time creep

variable jobno number;
begin
	dbms_job.submit(
		:jobno
		, 'my_proc;'
		-- every 15 minutes at 00,15,30 and 45
		, trunc(sysdate,'hh24') +  ( ( 15 + ( 15 * floor(to_number(to_char(sysdate,'mi')) / 15))) / ( 24 * 60 ))
		, 'trunc(sysdate,''hh24'') +  ( ( 15 + ( 15 * floor(to_number(to_char(sysdate,''mi'')) / 15))) / ( 24 * 60 ))'
	);
commit;
end;
/

print :jobno


