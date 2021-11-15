
-- set-default-profile-unlimited.sql
-- useful for test databases
-- Jared Still 2020-12-30 jkstill@gmail.com 

begin

	for prec in (
		select column_value profile_limit 
		from 
		(
			table
			(
				sys.odcivarchar2list
				(
					'FAILED_LOGIN_ATTEMPTS',
					'PASSWORD_LIFE_TIME',
					'PASSWORD_LOCK_TIME',
					'PASSWORD_GRACE_TIME'
				)
			)
		)
	)
	loop
		execute immediate 'alter profile default limit ' || prec.profile_limit || ' unlimited';
	end loop;

end;
/






