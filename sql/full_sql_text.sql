
-- full_sql_text.sql
-- use this to return the full text of a sql statement
-- from statspack data
-- the only column available for it (stats$sql_summary.sql_text) 
-- is not populated as of 9.2.0.6
-- see sp_plan.sql for usage

create or replace function full_sql_text( 
	hash_value_in stats$sqltext.hash_value%type,
	snap_id_in stats$sqltext.last_snap_id%type
)
return varchar2 deterministic
is
	v_sqltext varchar2(32567);
begin
	for srec in (
		select sql_text
		from stats$sqltext
		where hash_value = hash_value_in
		and last_snap_id = snap_id_in
		order by piece
	)
	loop
		v_sqltext := v_sqltext || srec.sql_text;
	end loop;

	return(substr(v_sqltext,1,2000));
end;
/


show error function full_sql_text

