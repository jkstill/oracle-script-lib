
whenever sqlerror exit 127

declare
	avail_user_count integer;
	not_avail exception;
	pragma exception_init(not_avail,-20000);
begin
	select count(*) into avail_user_count
	from dual
	where user like 'AVAIL%';

	dbms_output.put_line('avail user count: ' || avail_user_count);

	if (avail_user_count < 1 ) then
		dbms_output.put_line('Must be AVAIL account');
		raise not_avail;
	end if;
end;
/

whenever sqlerror continue



