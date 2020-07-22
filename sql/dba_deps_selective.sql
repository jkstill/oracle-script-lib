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
	WHERE d.owner = 'SYS'
		and d.name in ('DBMS_SHARED_POOL','UTL_TCP','UTL_FILE','UTL_HTTP','UTL_SMTP','UTL_XML')
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
	owner ||'.'|| name called_object
	, referenced_owner ||'.'|| referenced_name caller_object
	, referenced_type
from dep_recurse dr
where lvl=1
order by 1,2
/
