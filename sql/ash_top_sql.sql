
-- ash_top_sql.sql

/*
	TOP SQL from dba_hist_active_sess_history no v$active_session_history
	filter by DBID if necessary

	output looks like:

	 RANKED SQL_ID												 PLAN_HASH TYPE					 CPU		  WAIT		IO		  TOTAL
 --------- --------------------------------------- ---------- --------------- ------- ---------- ------- ----------
			1 30k1v1qaxnz64									3582572096 SELECT					 223			  0		 1			 224
			2 3cvyfd4m4nd55									3582572096 SELECT					  93			  1		 4			  98
			3 30bxza5tsc1qv									2919527181 SELECT					  68			  0		 0			  68
			4 8j53dscbsbqmb									4119093589 SELECT					  49			  0		 0			  49
			5 54stdqhzkupxu									3491655024 SELECT					  43			  0		 4			  47
			6 a326j107p6xwr									 738672717 SELECT					  46			  0		 0			  46
			7 4y31k002mvh9u									 973983616 SELECT					  35			  1		 0			  36


*/

set pagesize 100
set linesize 200 trimspool on
set echo off pause off term on feed on

col type for a15
col "CPU" for 999999
col "IO" for 999999

select rownum ranked, topsql.* from (
select
	  ash.SQL_ID , ash.SQL_PLAN_HASH_VALUE Plan_hash, aud.name type,
	  sum(decode(ash.session_state,'ON CPU',1,0))	  "CPU",
	  sum(decode(ash.session_state,'WAITING',1,0))	  -
	  sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0))		"WAIT" ,
	  sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0))		"IO" ,
	  sum(decode(ash.session_state,'ON CPU',1,1))	  "TOTAL"
from gv$active_session_history ash,
--from dba_hist_active_sess_history ash,
	  audit_actions aud
where SQL_ID is not NULL
	-- and ash.dbid=ampersand-DBID
	and ash.sql_opcode=aud.action
	-- and ash.sample_time > sysdate - ampersand-minutes /( 60*24)
	and ash.user_id not in (select user_id from dba_users where oracle_maintained = 'Y')
	-- solar winds and something else that seems a local monitoring account
	and ash.user_id not in (select user_id from dba_users where username in ('SA_DPA','LOCAL_MON_1','LOCAL_MON_2')) 
group by sql_id, SQL_PLAN_HASH_VALUE	, aud.name
order by sum(decode(session_state,'ON CPU',1,1)) desc
) topsql
where rownum <= 50
/

