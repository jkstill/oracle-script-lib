
-- get-sql-for-table.sql
-- Jared Still 2023
-- get SQL that includes table
-- if hard-coded predicates, force_matching_signature is used to discriminate
-- and get only 1 SQL statement, rather than the N similar statements

/*

Find all SQL that includes a table name (or anything really)

Find all sql from v$sqlarea and dba_hist_sql_text that include that table

Use force_matching_signature to limit sql that is the same other than hard coded predicates to just one exmample of the sql

The first parameter is the parsing Username
The second parameter is a table_name

Example:

 @get-sql-for-table.sql % dual

 Username ( % or Username ):

 Tablename:


                                        Parsing
 SQL_ID        FORCE_MATCHING_SIGNATURE User                 SQLTEXT
 ------------- ------------------------ -------------------- ------------------------------------------------------------------------------------------------------------------------------------------------------
 0kysbqzafm47u      6854851513100493293 SYS                  SELECT /*+ OPT_PARAM('_fix_control' '9088510:0') NO_XML_QUERY_REWRITE cursor_sharing_exact */ count(*)  FROM  "SYS"."AQ$SCHEDULER$_EVENT_QTAB" QTVIEW,
                                                              SYS.DUAL WHERE queue = 'AQ$_SCHEDULER$_EVENT_QTAB_E'
 
 0zbft9b0j2pd3     15207209260697423829 SYS                  SELECT /*+ OPT_PARAM('_parallel_syspls_obey_force' 'false') */ USERENV('INSTANCE') FROM DUAL
 1hxfbnas8xr2j      3711745779691471091 SYS                  select dummy from dual where  ora_dict_obj_type='ROLE'
 

*/


set tab off echo off verify off

set linesize 220 trimspool on
set pagesize 200

col sql_id format a13
col sqltext format a150 wrap
col force_matching_signature format 999999999999999999999
col parsing_username format a20 head 'Parsing|User'

col u_table_name new_value u_table_name noprint
col u_username new_value u_username noprint

prompt
prompt Username ( % or Username ):
prompt

set feed off term off

select upper('&1') u_username from dual;

set term on

prompt
prompt Tablename:
prompt

set term off

select lower('&2') u_table_name from dual;

set term on feed on


with getsigs as (
	select distinct force_matching_signature from (
		select
			distinct max(force_matching_signature) over (partition by force_matching_signature) force_matching_signature
		from v$sqlarea
		where lower(to_char(substr(sql_text,1,4000))) like '%&u_table_name%'
		and  force_matching_signature !=	 0
			-- included if sql should originate from a particular account
		and parsing_user_id in (select user_id from dba_users where username like '&u_username')
	union all
		select
			distinct max(s.force_matching_signature) over (partition by s.force_matching_signature) force_matching_signature
		from dba_hist_sqlstat s
		join dba_hist_sqltext t on t.sql_id = s.sql_id
			and t.con_dbid = s.con_dbid
			and t.dbid = s.dbid
			and t.con_id = s.con_id
			and lower(to_char(substr(t.sql_text,1,4000))) like '%&u_table_name%'
			and s.force_matching_signature != 0
			-- included if sql should originate from a particular account
			and s.parsing_user_id in (select user_id from dba_users where username = '&u_username')
	)
),
all_sql as (
	select distinct
		sql_id
		, force_matching_signature
		, parsing_user_id
		, sqltext
	from (
		select
			a.sql_id
			, s.force_matching_signature
			, a.parsing_user_id
			, max(to_char(substr(sql_text,1,4000))) sqltext
		from getsigs s
		join v$sqlarea a on a.force_matching_signature = s.force_matching_signature
		group by a.sql_id, a.parsing_user_id, s.force_matching_signature
		union all
		select
			st.sql_id
			, s.force_matching_signature
			, st.parsing_user_id
			, max(to_char(substr(sql_text,1,4000))) sqltext
		from getsigs s
		join dba_hist_sqlstat st on st.force_matching_signature = s.force_matching_signature
		join dba_hist_sqltext t on t.sql_id = st.sql_id
			and t.con_dbid = st.con_dbid
			and t.dbid = st.dbid
			and t.con_id = st.con_id
			and st.force_matching_signature != 0
		group by st.sql_id, s.force_matching_signature , st.parsing_user_id
	)
),
sqlids as (
	select
		force_matching_signature
		, max(sql_id) sql_id
		--, max(sqltext) over (partition by force_matching_signature ) sqltext
	from all_sql
	group by force_matching_signature
)
select
	a.sql_id
	, a.force_matching_signature
	, u.username parsing_username
	, a.sqltext
from all_sql a
join sqlids s on s.sql_id = a.sql_id
and (
	-- OPT_DYN_SAMP is in optimizer SQL for gathering dynamic statistics
	-- not needed here
	-- exclude DML
	-- there could be false positives here if a column_name included UPDATE, DELETE or INSERT
	not regexp_like(sqltext,'update|delete|insert|SELECT /\* OPT_DYN_SAMP \*/','mi')
	and lower(sqltext) not like 'with getsigs as%' -- ourself
)
join dba_users u on u.user_id = a.parsing_user_id
order by sql_id
/

