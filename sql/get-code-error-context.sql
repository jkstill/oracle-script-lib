
-- get-code-error-context.sql
-- show line of error in context for all pkg/body/function/procedure errors
-- Jared Still 2024

@clears

set serveroutput on size unlimited format truncated

define lines_context=5

set feed off term off echo off verify off
set feed on term on

set pagesize 500
set linesize 400 trimspool on

host mkdir -p logs

spool logs/code-errors.log

-- also need VIEW and TRIGGER
-- maybe MATERALIZED VIEWS

declare

	error_string varchar2(4000);
	msg_string varchar2(4000);
	errpos_string varchar2(4000);
	text_length pls_integer := 3900;

	chkstr varchar2(512) := 'NOOP';
	chkline varchar2(4000) := 'NOOP';

	lines_context pls_integer := &lines_context;

	function format_error_pos (
		owner_in dba_errors.owner%type,
		name_in dba_errors.name%type,
		type_in dba_errors.type%type,
		line_in dba_errors.line%type,
		error_line_length_in pls_integer
		) return varchar2
		is
			error_pos_str varchar2(4000) := rpad(' ',text_length, ' ');
		begin
			for erec in (
				select position + 1 position
				from dba_errors
				where owner = owner_in
					and name = name_in
					and type = type_in
					and line = line_in
				order by position
			)
			loop
				error_pos_str := substr(error_pos_str,1,erec.position-1) || '^' || substr(error_pos_str,erec.position+1);
			end loop;

			return substr(error_pos_str,1,error_line_length_in);
		end;

	function format_error_msg (
		owner_in dba_errors.owner%type,
		name_in dba_errors.name%type,
		type_in dba_errors.type%type,
		line_in dba_errors.line%type,
		error_line_length_in pls_integer
		) return varchar2
		is
			error_msg_str varchar2(4000) := rpad(' ',text_length, ' ');
			msg_pos pls_integer;
		begin
			for erec in (
				select position + 1 position
					, to_char(message_number) msg_number
					,case
					when regexp_like(text,'(PLS-|ORA-)') then
							substr(replace(text,'PL/SQL: ',''), 1, instr(replace(text,'PL/SQL: ',''),':')-1)
					else 'GEN PLSQL'
					end err_msg
				from dba_errors
				where owner = owner_in
					and name = name_in
					and type = type_in
					and line = line_in
				order by position
			)
			loop
				msg_pos := 2;
				if ( length(erec.err_msg) < erec.position ) then
					msg_pos := erec.position - floor( length(erec.err_msg) / 2);
				end if;
				--dbms_output.put_line('DEBUG formst_error_msg message: ' || erec.err_msg);
				--dbms_output.put_line('DEBUG formst_error_msg position:msg_pos: ' || to_char(erec.position) ||':'|| to_char(msg_pos));
				error_msg_str := substr(error_msg_str,1,msg_pos-1) || erec.err_msg || substr(error_msg_str, msg_pos + length(erec.err_msg) + 1 );
			end loop;

			return substr(error_msg_str,1,error_line_length_in);
		end;

	function format_error_pos_num (
		owner_in dba_errors.owner%type,
		name_in dba_errors.name%type,
		type_in dba_errors.type%type,
		line_in dba_errors.line%type,
		error_line_length_in pls_integer
		) return varchar2
		is
			error_pos_str varchar2(4000) := rpad(' ',text_length, ' ');
			msg_pos pls_integer;
		begin
			for erec in (
				select position+1 position, to_char(position+1) pos_str
				from dba_errors
				where owner = owner_in
					and name = name_in
					and type = type_in
					and line = line_in
				order by position
			)
			loop
				if ( erec.position <	 length(erec.pos_str) ) then
					msg_pos := 2;
				else
					msg_pos := erec.position - floor( length(erec.pos_str) / 2);
				end if;
				--dbms_output.put_line('DEBUG formst_error_pos_num msg_pos: ' || to_char(msg_pos));
				error_pos_str := substr(error_pos_str,1,msg_pos-1) || erec.pos_str || substr(error_pos_str,msg_pos+length(erec.pos_str)+1);
			end loop;

			return substr(error_pos_str,1,error_line_length_in);
		end;

begin

	for err_line_rec in (

		with errors_code as (
			select distinct e.owner, e.name, e.type, e.line
			from dba_errors e
			join dba_users u
				on u.username = e.owner
				and u.oracle_maintained != 'Y'
				and e.type in ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION')
			order by e.owner, e.type, e.name, e.line
		)
		select distinct
			s.owner
			, s.type
			, s.name
			, e.line err_line
			, s.line src_line
			--, regexp_replace(text,'[\n]','',1,0) text
			-- embedded newline as last character
			, substr(text,1,length(text)-1) text
			, max(s.line) over (partition by s.owner, s.type, s.name,e.line)	last_line
		from dba_source s
		join errors_code e
			on s.owner = e.owner
			and s.name = e.name
			and s.type = e.type
			-- 'between' will not work here - some error lines overlap with context lines, causing some things to be missed
			-- use a different query for context
			--and s.line between e.line-lines_context and e.line+lines_context
			and s.line = e.line
		--group by s.owner, s.type, s.name, e.line, s.line, substr(text,1,length(text)-1)
		order by s.owner, s.type, s.name, s.line
	)
	loop

		-- have not quite determined where dup line are coming from, so skip them
		if ( chkline = err_line_rec.text ) then
			continue;
		end if;

		--dbms_output.put_line('   TEXT: ' || to_char(err_line_rec.src_line,'99990') || ': ' || err_line_rec.text);
		--continue;

		if ( chkstr != err_line_rec.owner || err_line_rec.name || err_line_rec.type ) then
			dbms_output.new_line;
			dbms_output.put_line(rpad('#',100,'#'));
			dbms_output.put_line('OBJECT: ' || err_line_rec.owner || ',' || err_line_rec.name);
			dbms_output.put_line('  TYPE: ' || err_line_rec.type);
		end if;

		-- context before
		for brec in (
			select s.line
				, substr(text,1,length(text)-1) text
			from dba_source s
			where
				s.owner = err_line_rec.owner
				and s.type = err_line_rec.type
				and s.name = err_line_rec.name
				and s.line between err_line_rec.err_line - lines_context and err_line_rec.err_line -1
			order by line
		)
		loop
			dbms_output.put_line('         : ' || to_char(brec.line,'99990') || ': '|| brec.text);
		end loop;

		if	 ( err_line_rec.src_line = err_line_rec.err_line ) then
			dbms_output.put_line('     TEXT: ' || to_char(err_line_rec.src_line,'99990') || ': ' || err_line_rec.text);
			error_string :=		'   ERRORS: ' || to_char(err_line_rec.src_line,'99990') || ': ' || format_error_pos(err_line_rec.owner,err_line_rec.name,err_line_rec.type,err_line_rec.err_line,text_length);
			  msg_string :=		'   ERRNUM: ' || to_char(err_line_rec.src_line,'99990') || ': ' || format_error_msg(err_line_rec.owner,err_line_rec.name,err_line_rec.type,err_line_rec.err_line,text_length);
		  errpos_string :=		'   ERRPOS: ' || to_char(err_line_rec.src_line,'99990') || ': ' || format_error_pos_num(err_line_rec.owner,err_line_rec.name,err_line_rec.type,err_line_rec.err_line,text_length);
			dbms_output.put_line(error_string);
			dbms_output.put_line(errpos_string);
			dbms_output.put_line(msg_string);
		end if;

		-- context after
		for brec in (
			select s.line
				, substr(text,1,length(text)-1) text
			from dba_source s
			where
				s.owner = err_line_rec.owner
				and s.type = err_line_rec.type
				and s.name = err_line_rec.name
				and s.line between err_line_rec.err_line + 1 and err_line_rec.err_line + lines_context
			order by line
		)
		loop
			dbms_output.put_line('         : ' || to_char(brec.line,'99990') || ': '|| brec.text);
		end loop;


		if ( err_line_rec.src_line = err_line_rec.last_line ) then
			dbms_output.put_line(rpad('-',100,'-'));
		end if;


		chkstr := err_line_rec.owner || err_line_rec.name || err_line_rec.type;
		chkline := err_line_rec.text ;

		--exit;

	end loop;

end;
/

spool off

set linesize 200 trimspool on

--ed logs/code-errors.log


