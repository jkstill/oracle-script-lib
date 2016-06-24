
-- orapwdhash.sql
-- adapted from Pete Finnigans Oracle Password Cracker
-- http://www.petefinnigan.com/oracle_password_cracker.htm

col v_username new_value v_username noprint 
col v_password new_value v_password noprint 

prompt
prompt Generate old style password hash for an Oracle Password
prompt This requires the username and the password

set feed off term off verify off echo off head off 
ttitle off
btitle off

prompt
prompt Username: 
prompt

select upper('&1') v_username from dual;
set term on 

prompt
prompt Password:
prompt

select upper('&2') v_password from dual;
set term on feed on head on

set serveroutput on size 1000000 format wrapped

declare
        raw_ip raw(128);
		  username varchar2(30) := '&v_username';
        password varchar2(30) :='&v_password';
        raw_key raw(128):= hextoraw('0123456789ABCDEF');
        raw_key2 raw(128);
        enc_raw raw(128);
        pwd_hash raw(2048);
        hexstr varchar2(2048);
        len integer;
        password_hash varchar2(16);

	procedure unicode_str(userpwd in varchar2, unistr out raw)
	is
		enc_str varchar2(124):='';
		tot_len number;
		curr_char char(1);
		padd_len number;
		ch char(1);
		mod_len number;
		debugp varchar2(256);
	begin
		tot_len:=length(userpwd);
		--debugw(pv_level => '5',
		--	pv_str => 'tot_len:='||tot_len);
		for i in 1..tot_len loop
			curr_char:=substr(userpwd,i,1);
			--debugw(pv_level => '5',
			--	pv_str => 'curr_char:='||curr_char);
			enc_str:=enc_str||chr(0)||curr_char;
		end loop;
		-- padd to 8 byte boundaries
		mod_len:= mod((tot_len*2),8);
		if (mod_len = 0) then
			padd_len:= 0;
		else
			padd_len:=8 - mod_len;
		end if;
		--debugw(pv_level => '5',
		--	pv_str => 'padd_len:='||padd_len);
		for i in 1..padd_len loop
			enc_str:=enc_str||chr(0);
		end loop;
		-- /* debug code
		for i in 1..tot_len*2+padd_len loop
			ch:=substr(enc_str,i,1);
			if (ch = chr(0)) then
				debugp:=debugp||'|*';
			else
				debugp:=debugp||'|'||ch;
			end if;
		end loop;
		-- end debug code */
		unistr:=utl_raw.cast_to_raw(enc_str);
	end;

begin


        unicode_str(username || password,raw_ip);

        dbms_obfuscation_toolkit.DESEncrypt(input => raw_ip,
                key => raw_key, encrypted_data => enc_raw );


        hexstr:=rawtohex(enc_raw);
        len:=length(hexstr);
        raw_key2:=hextoraw(substr(hexstr,(len-16+1),16));
        dbms_obfuscation_toolkit.DESEncrypt(input => raw_ip,
                key => raw_key2, encrypted_data => pwd_hash );

        hexstr:=hextoraw(pwd_hash);
        len:=length(hexstr);
        password_hash:=substr(hexstr,(len-16+1),16);

        dbms_output.put_line('Hash: ' || password_hash);

end;
/
