
-- csv-split.sql
-- split list of CSV on the command line to values
-- Jared Still  jkstill@gmail.com
--
-- requires a list of at least two elements
-- spaces are not allowed
-- @csv one,two,three


--def u_list='one,two,three,four,five,six'
--def u_list='one,two'

col u_list new_value u_list noprint

prompt
prompt list: 
prompt

set feed off term off head off verify off
select '&1' u_list from dual;
set feed on term on head on

set linesize 200 trimspool on 
set pagesize 100

col idx format 999
col string format a40
col lft format a40
col rght format a40
col cloc format 999999
col val format a30

with csv (idx,string,cloc,val,rght) as (
	select 
		0 as idx
		, t.string
		, instr('&u_list',',') cloc
		, substr(t.string,1,instr('&u_list',',') -1)  val
		, substr(t.string,instr('&u_list',',')) rght
	from  (select upper(regexp_replace('&u_list','\s+','')) string from dual) t
	union all
	select 
		csv.idx + 1 as idx
		, csv.string
		, instr(csv.rght,',') cloc
		,
		case
		when instr(csv.rght,',') != instr(csv.rght,',', -1)  -- last two elements will 'val,val'
			then substr
			(
				csv.rght, -- string
				instr(csv.rght,',')+1,  -- start
				instr(csv.rght,',', instr(csv.rght,',')+1) - instr(csv.rght,',') -1 -- length
			)
		else substr(csv.rght,instr(csv.rght,',')+1)
		end val
		, 
		case when instr(csv.rght,',') > 0 
			then substr(csv.rght,instr(csv.rght,',')+1)
		else''
		end rght
	from csv
	where instr(csv.rght,',') > 0
)
select idx, val from csv
/


