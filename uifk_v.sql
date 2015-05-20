
-- uifk_v.sql
-- Jared Still 
-- adapted from a script by Tom Kyte that is used to
-- find unindexed Foreign Keys
-- http://asktom.oracle.com/tkyte/unindex/unindex.sql
--
-- this view shows table name, constraint name, and CSV 
-- list of columns that make up the FK constraint when
-- there is not a supporting index for the FK

create or replace view user_uifk
as
select a.table_name, a.constraint_name, a.columns
-- uifk_v.sql
-- Jared Still 
-- adapted from a script by Tom Kyte that is used to
-- find unindexed Foreign Keys
-- http://osi.oracle.com/~tkyte/unindex/unindex.sql
--
-- this view shows table name, constraint name, and CSV 
-- list of columns that make up the FK constraint when
-- there is not a supporting index for the FK
from
( select substr(a.table_name,1,30) table_name, 
		 substr(a.constraint_name,1,30) constraint_name, 
	     max(decode(position, 1,    '"'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 2,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 3,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 4,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 5,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 6,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 7,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 8,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 9,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,10,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,11,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,12,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,13,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,14,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,15,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,16,', "'||substr(column_name,1,30)||'"',NULL)) columns
    from user_cons_columns a, user_constraints b
   where a.constraint_name = b.constraint_name
     and b.constraint_type = 'R'
   group by substr(a.table_name,1,30), substr(a.constraint_name,1,30) ) a, 
( select substr(table_name,1,30) table_name, substr(index_name,1,30) index_name, 
	     max(decode(column_position, 1,    '"'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 2,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 3,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 4,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 5,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 6,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 7,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 8,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 9,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,10,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,11,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,12,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,13,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,14,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,15,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,16,', "'||substr(column_name,1,30)||'"',NULL)) columns
    from user_ind_columns 
   group by substr(table_name,1,30), substr(index_name,1,30) ) b
where a.table_name = b.table_name (+)
  and b.columns (+) like a.columns || '%'
  and b.columns is null
/


create or replace view dba_uifk
as
select a.owner, a.table_name, a.constraint_name, a.columns
-- uifk_v.sql
-- Jared Still 
-- adapted from a script by Tom Kyte that is used to
-- find unindexed Foreign Keys
-- http://osi.oracle.com/~tkyte/unindex/unindex.sql
--
-- this view shows table name, constraint name, and CSV 
-- list of columns that make up the FK constraint when
-- there is not a supporting index for the FK
from
( select substr(a.owner,1,30) owner,
        substr(a.table_name,1,30) table_name,
		 substr(a.constraint_name,1,30) constraint_name,
	     max(decode(position, 1,    '"'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 2,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 3,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 4,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 5,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 6,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 7,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 8,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position, 9,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,10,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,11,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,12,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,13,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,14,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,15,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(position,16,', "'||substr(column_name,1,30)||'"',NULL)) columns
    from dba_cons_columns a, dba_constraints b
   where a.owner = b.owner
	  and a.constraint_name = b.constraint_name
     and b.constraint_type = 'R'
   group by substr(a.owner,1,30), substr(a.table_name,1,30), substr(a.constraint_name,1,30) ) a,
( select substr(index_owner,1,30) owner,
        substr(table_name,1,30) table_name, substr(index_name,1,30) index_name,
	     max(decode(column_position, 1,    '"'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 2,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 3,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 4,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 5,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 6,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 7,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 8,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position, 9,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,10,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,11,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,12,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,13,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,14,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,15,', "'||substr(column_name,1,30)||'"',NULL)) ||
	     max(decode(column_position,16,', "'||substr(column_name,1,30)||'"',NULL)) columns
    from dba_ind_columns
   group by substr(index_owner,1,30), substr(table_name,1,30), substr(index_name,1,30) ) b
where a.owner = b.owner(+)
  and a.table_name = b.table_name (+)
  and b.columns (+) like a.columns || '%'
  and b.columns is null
/

grant select on user_uifk to public;
grant select on dba_uifk to dba;

create public synonym user_uifk for sys.user_uifk;
create public synonym dba_uifk for sys.dba_uifk;

