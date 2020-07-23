<<<<<<< HEAD


col called_object format a40
col caller_object format a40

set linesize 200 trimspool on
set pagesize 100

=======
>>>>>>> 5f6806d60129ba35b598d6f1789a92b0f960df05
with dep_recurse (
	owner
	, name
	, type
	, referenced_owner
	, referenced_name
	, referenced_type
	, referenced_link_name
	, dependency_type
	, lvl
	, idx
) as (
	select
		d.owner
		, d.name
		, d.type
		, d.referenced_owner
		, d.referenced_name
		, d.referenced_type
		, d.referenced_link_name
		, d.dependency_type
		, 1 as lvl
		, rownum - 1 as idx
	FROM dba_dependencies d
<<<<<<< HEAD
	WHERE d.name in (
		select object_name
		from dba_objects
		where owner not in (
			select name
			from system.LOGSTDBY$SKIP_SUPPORT
			where action = 0
		)
		and object_type in ('FUNCTION','PACKAGE','PROCEDURE','TYPE','VIEW')
	)
=======
	WHERE d.owner = 'SYS'
		and d.name in ('DBMS_SHARED_POOL','UTL_TCP','UTL_FILE','UTL_HTTP','UTL_SMTP','UTL_XML')
>>>>>>> 5f6806d60129ba35b598d6f1789a92b0f960df05
	-- anchor member
	union all
	-- recursive member
	select
		d.owner
		, d.name
		, d.type
		, d.referenced_owner
		, d.referenced_name
		, d.referenced_type
		, d.referenced_link_name
		, d.dependency_type
		, dr.lvl +1 as lvl
		, dr.idx +1 as idx
	FROM dba_dependencies d
	JOIN dep_recurse dr
		on d.owner = dr.referenced_owner
		and d.name = dr.referenced_name
		and d.type = dr.referenced_type
)
search depth first by owner set order1 -- display in std heirarchical order
--search breadth first by owner set order1 -- display in order of levels
-- distinct:  there may be multiple rows in the anchor member resulting in a partial car
SELECT  distinct
<<<<<<< HEAD
	owner ||'.'|| name caller_object
	, type
	, referenced_owner ||'.'|| referenced_name called_object
	, referenced_type
from dep_recurse dr
where lvl=1
and owner not in (
	select name schema_to_exclude
	from system.LOGSTDBY$SKIP_SUPPORT
	where action = 0
	union all
	select 'PUBLIC' name from dual
)
and referenced_owner || '.' || referenced_name not in ('SYS.STANDARD')
order by 1,2
/


=======
	owner ||'.'|| name called_object
	, referenced_owner ||'.'|| referenced_name caller_object
	, referenced_type
from dep_recurse dr
where lvl=1
order by 1,2
/
>>>>>>> 5f6806d60129ba35b598d6f1789a92b0f960df05
