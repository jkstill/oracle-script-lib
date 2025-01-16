
-- bind var is :v_sqltempfile

set feed off

begin
	-- this will raise a sqlplus error if the variable was not set in save-sqlplus-settings.sql
	-- there is no method to trap sqlplus errors from within a sql script
	if length(:v_sqltempfile) > 0 then
		null;
	end if;
end;
/

@@&sqltempfile

