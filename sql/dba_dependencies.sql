
-- obj-dependencies.sql
-- find the dependenices for any database object
-- call with object_owner object_name object_type
--
-- this example returns no rows
-- @obj-dependencies.sql scott emp table
-- 
-- this one returns 200+ rows
-- @obj-dependencies.sql sys dbms_stats_internal 'package body'
--
-- use of upper() is convenient for many arguments, but will cause errors
-- with those having mixed case names, such as Java classes
--
-- see below to switch between hierarchical and list view


set term off head off verify off pause off
btitle off
ttitle off

-- switch between hierarchical and list view
def u_display_type = 'H' -- heirarchy
--def u_display_type = 'L' -- list of dependencies

col u_hier_view new_value u_hier_view noprint
col u_list_view new_value u_list_view noprint

select decode('&u_display_type','H','--','') u_list_view from dual;
select decode('&u_display_type','L','--','') u_hier_view from dual;

set pagesize 100
set linesize 300 trimspool on

set term on feed on head on
set echo off tab off verify off


col u_owner new_value u_owner noprint
col u_object new_value u_object noprint
col u_type new_value u_type noprint

col owner format a30 noprint
col name format a30 noprint
col idx noprint

col type format a18
col object format a75

col referenced_owner format a30
col referenced_name format a30
col referenced_link_name format a30
col referenced_type format a18
col dependency_type format a4

prompt
prompt Owner: 
prompt


set feed off term off 
select upper('&1') u_owner from dual;
set feed on term on 

prompt
prompt Object Name: 
prompt

set feed off term off 
select upper('&2') u_object from dual;
set feed on term on 

prompt
prompt Object Type: 
prompt

set feed off term off 
select upper('&3') u_type from dual;
set feed on term on 

prompt
prompt Dependencies for &u_type &u_owner..&u_object
prompt

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
	WHERE d.owner = '&u_owner'
		and d.name = '&u_object'
		and d.type = '&u_type'
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
&u_hier_view SELECT  distinct
	 --lpad(' ', lvl*2-1,' ') || owner ||'.'|| name object
	 &u_hier_view lpad(' ', lvl*2-1,' ') || referenced_owner ||'.'|| referenced_name object
	&u_hier_view , idx
	&u_hier_view , referenced_type
&u_hier_view from dep_recurse dr
--&u_hier_view order by idx
--
&u_list_view SELECT  distinct
	 &u_list_view  referenced_owner ||'.'|| referenced_name object
	&u_list_view , referenced_type
&u_list_view from dep_recurse dr
&u_list_view order by 1
/

undef 1 2 3

