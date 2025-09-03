
-- timestamp-types.sql
-- Jared Still
--  jkstill@gmail.com

-- uncomment this code in a database where you can create a table

--/*

--to see the types from a table

drop table tz_convert purge;

create table tz_convert (
   sysdate_plain date,
   systimestamp_without_tz timestamp,
   systimestamp_with_tz timestamp with time zone,
   curr_timestamp timestamp,
   curr_timestamp_tz timestamp with time zone,
   curr_timestamp_local_tz timestamp with local time zone
);


insert into tz_convert(
   sysdate_plain
   , systimestamp_without_tz
   , systimestamp_with_tz
   , curr_timestamp
   , curr_timestamp_tz
   , curr_timestamp_local_tz
)
select
   sysdate
   , systimestamp
   , systimestamp
   , current_timestamp
   , current_timestamp
   , current_timestamp
from dual;

commit;

--*/

set serveroutput on size unlimited

declare

	cursor time_funcs is
	with tz_data as (
		select rownum id, column_value t_name
		from
   		table(
      		sys.odcivarchar2list(
				'sysdate'
				, 'systimestamp'
				, 'cast(systimestamp as timestamp)'
				, 'current_timestamp'
				, 'localtimestamp'
				, 'dbtimezone'
				, 'sessiontimezone'
				)
			)
		),
	tz_format as (
		select rownum id, column_value t_format
		from
   		table(
      		sys.odcivarchar2list(
				'yyyy-mm-dd hh24:mi:ss' -- sysdate
				, 'yyyy-mm-dd hh24:mi:ss.fftzh:tzm' -- systimestamp
				, 'yyyy-mm-dd hh24:mi:ss.ff' -- systimestamp as timestamp
				, 'yyyy-mm-dd hh24:mi:ss.fftzh:tzm' -- current_timestamp
				, 'yyyy-mm-dd hh24:mi:ss.ff' -- localtimestamp
				, 'NA' -- dbtimezone
				, 'NA' -- sessionimezone
			)
		)
	)
	select t_name, t_format
	from tz_data d, tz_format f
	where f.id = d.id;

	v_date_str varchar2(50);
	v_dump_data varchar2(200);

	v_sql clob;

	procedure pl (msg_in clob)
	is
	begin
		dbms_output.put_line(msg_in);
	end;

	procedure nl
	is
	begin
		dbms_output.new_line;
	end;

	procedure hdr (
		msg_in clob,
		hdr_chr_in char default '=',
		hdr_len_in integer default 80
	)
	is 
	begin
		dbms_output.put_line(rpad(hdr_chr_in,hdr_len_in,hdr_chr_in));
		dbms_output.put_line(rpad(hdr_chr_in,3,hdr_chr_in) || ' ' || msg_in);
		dbms_output.put_line(rpad(hdr_chr_in,hdr_len_in,hdr_chr_in));
	end;


begin

	hdr('time functions');

	for trec in time_funcs
	loop
		pl(lpad('name: ',20) || trec.t_name);
		v_sql := 'select to_char(' || trec.t_name 
			|| case trec.t_format 
				when 'NA' then ')' 
				else  ',''' || trec.t_format || ''')'
				end
			|| ', dump(' || trec.t_name || ')'
			|| ' from dual'
		;
		--pl('v_sql: ' || v_sql);
		execute immediate v_sql into v_date_str, v_dump_data;
		pl(lpad('data: ',24) || v_date_str);
		pl(lpad('dump: ',24)  || v_dump_data);
		nl;
	end loop;

	hdr('tz_convert columns');

	-- only 1 row, but the loop is a convenient method
	for trec in (
		select 
			sysdate_plain
			, dump(sysdate_plain) sysdate_plain_dump
			--
			, systimestamp_without_tz
			, dump(systimestamp_without_tz) systimestamp_without_tz_dump
			--
			, systimestamp_with_tz
			, dump(systimestamp_with_tz) systimestamp_with_tz_dump
			--
			, curr_timestamp
			, dump(curr_timestamp) curr_timestamp_dump
			--
			, curr_timestamp_tz
			, dump(curr_timestamp_tz) curr_timestamp_tz_dump
			--
			, curr_timestamp_local_tz
			, dump(curr_timestamp_local_tz) curr_timestamp_local_tz_dump
		from tz_convert)
	loop
		pl(lpad('sysdate_plain: ',30));
		pl(lpad('data: ',25) || trec.sysdate_plain);
		pl(lpad('dump: ',25) || trec.sysdate_plain_dump);
		nl;
		pl(lpad('systimestamp_without_tz: ',30));
		pl(lpad('data: ',25) || trec.systimestamp_without_tz);
		pl(lpad('dump: ',25) || trec.systimestamp_without_tz_dump);
		nl;
		pl(lpad('systimestamp_with_tz: ',30));
		pl(lpad('data: ',25) || trec.systimestamp_with_tz);
		pl(lpad('dump: ',25) || trec.systimestamp_with_tz_dump);
		nl;
		pl(lpad('curr_timestamp: ',30));
		pl(lpad('data: ',25) || trec.curr_timestamp);
		pl(lpad('dump: ',25) || trec.curr_timestamp_dump);
		nl;
		pl(lpad('curr_timestamp_tz: ',30));
		pl(lpad('data: ',25) || trec.curr_timestamp_tz);
		pl(lpad('dump: ',25) || trec.curr_timestamp_tz_dump);
		nl;
		pl(lpad('curr_timestamp_local_tz: ',30));
		pl(lpad('data: ',25) || trec.curr_timestamp_local_tz);
		pl(lpad('dump: ',25) || trec.curr_timestamp_local_tz_dump);
		nl;
	end loop;

end;
/


