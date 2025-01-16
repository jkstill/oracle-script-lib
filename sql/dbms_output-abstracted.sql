

-- dbms_output-abstracted.sql
-- some abstracted functions and procedures for using dbms_output
-- Jared Still  jkstill@gmail.com
-- Pythisn 2019
-- these are demonstrated here in an anonymous block, but are really best
-- used in stored procedures and packages; especially packages

-- at least in sqlplus it is still necessary to turn serveroutput on external to the PL/SQL
set serveroutput on
set feed off

declare

	v_msg varchar2(1024);

	/*
	== abstracted interface to dbms_output
	*/

	-- do not set these outside of the control procedures
	b_p_enabled boolean := false;
	b_logging boolean := false;
	v_platform varchar2(10) := 'unix';

	/*
	===============================================
	== procedure set platform
	== valid input values are 'windows' and 'unix'
	== default is 'unix'
	===============================================
	*/

	procedure set_platform ( platform_in in varchar2 default v_platform)
	is
		invalid_platform exception;
		pragma exception_init(invalid_platform, -20001);
	begin
		if platform_in not in ('unix', 'windows') then
			raise invalid_platform;
		end if;
		v_platform := platform_in;
	exception
	when invalid_platform then
		-- p() not available at this point
		-- could be used if this were a package
		dbms_output.put_line('invalid platform of "' || platform_in || '"');
	when others then
		raise;
	end;

	/*
	===============================================
	== get platform - return the value of v_platform
	===============================================
	*/

	function get_platform return varchar2
	is
	begin
		return v_platform;
	end;

	/*
	===============================================
	== function embed_newline
	== returns a newline character
	== pass platform => 'windows' and it will return CRLF
	===============================================
	*/

	function embed_newline ( platform in varchar2 default 'unix') return varchar2
	is
		newline_str varchar2(2);
	begin
		if get_platform = 'windows' then
			newline_str := chr(13)||chr(10);
		else
			newline_str := chr(10);
		end if;
		return newline_str;
	end;


	/*
	===============================================
	== function p_enabled
	== return true/false to check if dbms_output
	== is enabled internally
	===============================================
	*/
	function p_enabled return boolean
	is
	begin
		return b_p_enabled;
	end;

	/*
	===============================================
	== procedure p_enable
	== enable dbms_output
	===============================================
	*/
	procedure p_enable 
	is 
	begin
		-- NULL == unlimited
		dbms_output.enable(null);
	end;

	/*
	===============================================
	== procedure p_on
	== internally enable dbms_output use via p() and pl()
	===============================================
	*/
	procedure p_on
	is
	begin
		p_enable;
		b_p_enabled := true;
	end;

	/*
	===============================================
	== procedure p_off
	== internally disable dbms_output use via p() and pl()
	===============================================
	*/
	procedure p_off
	is
	begin
		b_p_enabled := false;
	end;


	/*
	===============================================
	== procedure p
	== print a line without linefeed
	===============================================
	*/
	procedure p (p_in varchar2)
	is
	begin
		if p_enabled then
			dbms_output.put(p_in);
		end if;
	end;

	/*
	===============================================
	== procedure p;
	== print a line with linefeed
	===============================================
	*/
	procedure pl (p_in varchar2)
	is
	begin
		if p_enabled then
			p(p_in);
			dbms_output.new_line;
		end if;
	end;

	/*
	===============================================
	== procedure banner;
	== print a line of 80 '='
	== specify an optional character with v_banner_char_in
	===============================================
	*/

	procedure banner( v_banner_char_in varchar2 default '=')
	is
	begin
		pl(rpad(v_banner_char_in,80,v_banner_char_in));
	end;


begin

	-- dbms_output.put_line is used for testing purposes only

	dbms_output.put_line('Testing the p_ procedures');

	dbms_output.put_line('Output from the following lines will not be seen');

	p_off;

	pl('This is a test - output is disabled');

	dbms_output.put_line('Output now enabled with p_on()');

	p_on;

	banner;
	pl('output is enabled ');
	banner;

	-- create a multiline message
	-- dbms_output will use the correct line terminator for whatever platform it is installed on
	-- the embed_newline function is useful for creating multiline text with the correct line terminator
	
	set_platform('unix');
	v_msg := 'this is line 1' || embed_newline || 'this is line 2' || embed_newline || 'this is line 3';
	pl(v_msg);
	
end;
/


set feed on

