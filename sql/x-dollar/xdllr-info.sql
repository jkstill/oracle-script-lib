
-- scan must be off as there may be a number of ampersand characters in the comments
set scan off
set tab off

set linesize 160 trimspool on
set pagesize 500

col x_dollar_table format a30
col abstract format a30 wrap
col comments format a80 wrap

with xt as (
	@@xdllr-tablist.sql
),
xa as (
	@@xdllr-abstract-list.sql
),
xc as (
	@@xdllr-comments.sql
)
select 
	xt.x_dollar_table
	, xa.abstract
	, xc.comments
from xt
join xa on xa.id = xt.id
join xc on xc.id = xt.id
/


