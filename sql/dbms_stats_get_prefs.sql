
-- dbms_stats_get_prefs.sql
-- use dbms_stats.get_prefs to get statitics prefs per table
-- includes indexes

@clears

col v_owner new_value v_owner noprint
col v_table_name new_value v_table_name noprint

prompt
prompt Schema Name? :
prompt

set feed off term off
select upper('&1') v_owner from dual;
set feed on term on

prompt
prompt Table Name? :
prompt

set feed off term off
select upper('&2') v_table_name from dual;
set feed on term on

declare
	type v_tabtyp_v is table of varchar2(100) index by pls_integer;
	v_cbo_attr v_tabtyp_v;
	v_cbo_attr_val varchar2(100);

	--v_tabname varchar2(30) :='CUSTOM_FIELDS_VAL';
	--v_schema varchar2(30) :='EMTADMIN_E2';
	v_tabname varchar2(30) := upper('&&v_table_name');
	v_schema varchar2(30) := upper('&&v_owner');

procedure get_prefs ( v_attr_in varchar2, v_schema_in varchar2, v_obj_in varchar2)
is
	v_cbo_attr_val varchar2(100);
begin
		v_cbo_attr_val :=  dbms_stats.get_prefs(v_attr_in, v_schema_in, v_obj_in);
		dbms_output.put_line(v_attr_in || ': ' || v_cbo_attr_val);
end;

procedure banner ( v_banner_in varchar2 )
is
	v_char varchar2(1) := '=';
	v_hdr varchar2(100);
begin
	v_hdr := rpad(v_char,40,v_char);
	dbms_output.put_line(v_hdr);
	dbms_output.put_line(rpad(v_char,2,v_char) || ' ' ||	v_banner_in);
	dbms_output.put_line(v_hdr);
end;

begin

	v_cbo_attr(1) := 'CASCADE';
	v_cbo_attr(2) := 'DEGREE';
	v_cbo_attr(3) := 'ESTIMATE_PERCENT';
	v_cbo_attr(4) := 'METHOD_OPT';
	v_cbo_attr(5) := 'NO_INVALIDATE';
	v_cbo_attr(6) := 'GRANULARITY';
	v_cbo_attr(7) := 'PUBLISH';
	v_cbo_attr(8) := 'INCREMENTAL';
	v_cbo_attr(9) := 'STALE_PERCENT';
	v_cbo_attr(10) := 'AUTOSTATS_TARGET';

	banner('CBO Prefs for table: ' || v_schema ||'.' || v_tabname);
	for i in v_cbo_attr.first .. v_cbo_attr.last
	loop
		get_prefs(v_cbo_attr(i),v_schema,v_tabname);
	end loop;

	for irec in (
		select index_name
		from dba_indexes
		where owner = v_schema
		and table_name = v_tabname
	)
	loop

		banner('CBO Prefs for index: ' || v_schema ||'.' || irec.index_name);
		for i in v_cbo_attr.first .. v_cbo_attr.last
		loop
			get_prefs(v_cbo_attr(i),v_schema,irec.index_name);
		end loop;
	end loop;


end;
/
