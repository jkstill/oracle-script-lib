
-- dba_table_audit_flags.sql
--
-- show audit owner, table, status of auditing on
-- SELECT, INSERT, UPDATE, DELETE
--
-- works on 7.3+

drop view dba_table_audit_flags;

create or replace view dba_table_audit_flags
(
	owner
	, table_name
	, select_audit
	, insert_audit
	, update_audit
	, delete_audit
	, alter_audit
	, audit_audit
	, comment_audit
	, grant_audit
	, index_audit
	, lock_audit
	, rename_audit
	, references_audit
	, execute_audit
	--, audit_flags
)
as
select u.name, o.name
		 , decode(substr(t.audit$,19,2),'--','N','Y') -- select
		 , decode(substr(t.audit$,13,2),'--','N','Y') -- insert
		 , decode(substr(t.audit$,21,2),'--','N','Y') -- update
		 , decode(substr(t.audit$, 7,2),'--','N','Y') -- delete
		 , decode(substr(t.audit$, 1,2),'--','N','Y') -- alter 
		 , decode(substr(t.audit$, 3,2),'--','N','Y') -- audit
		 , decode(substr(t.audit$, 5,2),'--','N','Y') -- comment
		 , decode(substr(t.audit$, 9,2),'--','N','Y') -- grant
		 , decode(substr(t.audit$,11,2),'--','N','Y') -- index
		 , decode(substr(t.audit$,15,2),'--','N','Y') -- lock
		 , decode(substr(t.audit$,17,2),'--','N','Y') -- rename
		 , decode(substr(t.audit$,23,2),'--','N','Y') -- references
		 , decode(substr(t.audit$,25,2),'--','N','Y') -- execute
       --, t.audit$
from sys.user$ u, sys.tab$ t, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = t.obj#
  and (instr(t.audit$,'S') > 0 or instr(t.audit$,'A') > 0)
union all
select u.name, o.name
		 , decode(substr(v.audit$,19,2),'--','N','Y') -- select
		 , decode(substr(v.audit$,13,2),'--','N','Y') -- insert
		 , decode(substr(v.audit$,21,2),'--','N','Y') -- update
		 , decode(substr(v.audit$, 7,2),'--','N','Y') -- delete
		 , decode(substr(v.audit$, 1,2),'--','N','Y') -- alter 
		 , decode(substr(v.audit$, 3,2),'--','N','Y') -- audit
		 , decode(substr(v.audit$, 5,2),'--','N','Y') -- comment
		 , decode(substr(v.audit$, 9,2),'--','N','Y') -- grant
		 , decode(substr(v.audit$,11,2),'--','N','Y') -- index
		 , decode(substr(v.audit$,15,2),'--','N','Y') -- lock
		 , decode(substr(v.audit$,17,2),'--','N','Y') -- rename
		 , decode(substr(v.audit$,23,2),'--','N','Y') -- references
		 , decode(substr(v.audit$,25,2),'--','N','Y') -- execute
       --, t.audit$
from sys.user$ u, sys.view$ v, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = v.obj#
  and (instr(v.audit$,'S') > 0 or instr(v.audit$,'A') > 0)
/


create public synonym dba_table_audit_flags for sys.dba_table_audit_flags;

grant select on dba_table_audit_flags to dba;

