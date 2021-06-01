
/*

21:28:52 ora10gR2.jks.com - jkstill@js01 SQL> desc dba_log_groups
 Name                                                                                                              Null?    Type
 ----------------------------------------------------------------------------------------------------------------- -------- ----------------------------------------------------------------------------
 OWNER                                                                                                             NOT NULL VARCHAR2(30)
 LOG_GROUP_NAME                                                                                                    NOT NULL VARCHAR2(30)
 TABLE_NAME                                                                                                        NOT NULL VARCHAR2(30)
 LOG_GROUP_TYPE                                                                                                             VARCHAR2(19)
 ALWAYS                                                                                                                     VARCHAR2(11)
 GENERATED                                                                                                                  VARCHAR2(14)

21:29:01 ora10gR2.jks.com - jkstill@js01 SQL> desc DBA_LOG_GROUP_COLUMNS
 Name                                                                                                              Null?    Type
 ----------------------------------------------------------------------------------------------------------------- -------- ----------------------------------------------------------------------------
 OWNER                                                                                                             NOT NULL VARCHAR2(30)
 LOG_GROUP_NAME                                                                                                    NOT NULL VARCHAR2(30)
 TABLE_NAME                                                                                                        NOT NULL VARCHAR2(30)
 COLUMN_NAME                                                                                                                VARCHAR2(4000)
 POSITION                                                                                                                   NUMBER
 LOGGING_PROPERTY            


-- contents of gg_env.sql

define v_rep_schema='SOE'
----------------------------


*/

@@gg_env

set line 200

break on owner on table_name on log_group_name skip 1

select 
	lg.owner
	, lg.table_name
	, lg.log_group_name
	, lgc.column_name
	, lgc.logging_property
from dba_log_groups lg
join dba_log_group_columns lgc on lgc.owner = lg.owner
	and lgc.log_group_name = lg.log_group_name
	and lgc.table_name = lg.table_name
where lg.owner = '&&v_rep_schema'
order by lg.owner, lg.table_name, lgc.position
/
