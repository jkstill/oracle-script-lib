-- see sys.aux_stats$

set serveroutput on size unlimited

declare

	type typetab is table of  varchar2(100) index by binary_integer;
	parmtab typetab;

	v_pname varchar2(30);
	v_pvalue number;
	v_status varchar2(20);
	v_dstart date;
	v_dstop date;

	b_first_time boolean := true;


begin
	parmtab(1) := 'iotfrspeed';
	parmtab(2) := 'ioseektim';
	parmtab(3) := 'sreadtim';
	parmtab(4) := 'mreadtim';
	parmtab(5) := 'cpuspeed';
	parmtab(6) := 'cpuspeednw';
	parmtab(7) := 'mbrc';
	parmtab(8) := 'mbrc';
	parmtab(9) := 'maxthr';
	parmtab(10) := 'slavethr';

	for i in 1 .. parmtab.last
	loop
		dbms_stats.get_system_stats(
			status	=> v_status,
			dstart	=> v_dstart,
			dstop		=> v_dstop,
			pname		=> parmtab(i),
			pvalue	=> v_pvalue
		);

		if b_first_time then
			b_first_time := false;
			dbms_output.put_line('STATUS: ' || v_status);
			dbms_output.put_line('START : ' || to_char(v_dstart,'mm/dd/yyyy hh24:mi:ss'));
			dbms_output.put_line('STOP	 : ' || to_char(v_dstop,'mm/dd/yyyy hh24:mi:ss'));
			dbms_output.put_line('PARAMETERS ');
		end if;

		dbms_output.put_line(lpad(parmtab(i),20,' ') || ': ' || to_char(v_pvalue));

	end loop;

end;
/

