
-- awr-event-histogram.sql

/*


Pass a list of wait classes to ignore

To see everything pass an empty list 
('Idle' is always excluded )

@awr-event-histogram ''

@awr-event-histogram '"Other","Cluster"'

@awr-event-histogram '"Other"'

@awr-event-histogram  '"Other","Cluster","System I/O"'

The 'all_waits' column is a histgram that represents all chosen  activity.

The values can be quite large, so these are divided by a calculated value for display

Note: this script will exit with an error if logged into a PDB and the AWR_PDB_EVENTS_HISTOGRAM view has zero rows.
 
  running "pdb-awr-enable.sql" may fix that

*/

var all_waits_char varchar2(1)
set feed off
exec :all_waits_char := '*'

col  wait_time_milli_avg on format   99,999.999990
col  wait_time_minutes on format   999,999,999,999,999.90
col  wait_time_seconds on format   999,999,999.99
col  wait_time_milli on format   99,999.999990 
col  wait_count on format   999,999,999,999
col  wait_class on format   a30
col  event_name on format   a50
col  event on format   a50
col instance_number format 9999 head 'INST'

-- this one for use with to_char(begin_interval_time)
col begin_interval_time format a19
-- use this one for standard timestamp
--col begin_interval_time format a25
col histogram format a110 head histogram
col all_waits format a50 

set linesize 300 trimspool on
set pagesize 100

set verify off 
btitle off 
ttitle off
set feed off pause off echo off heading on term on

col ignore_list new_value ignore_list noprint
set term off heading off
select replace(decode('&1','','''nothing''','&1'),'"','''') ignore_list from dual;

-- get the type of view to use
var db_type varchar2(30)
col db_view new_value db_view noprint

declare
   no_such_parm exception;
   pragma exception_init(no_such_parm,-2003);
begin
   :db_type := sys_context('userenv','con_id');
exception
when no_such_parm then
   :db_type := 0;
when others then
   raise;
end;
/

select decode(:db_type,
   0,'DBA_HIST_EVENT_HISTOGRAM',
   1,'CDB_HIST_EVENT_HISTOGRAM',
   'AWR_PDB_EVENT_HISTOGRAM') db_view
from dual
/

set term on
set serveroutput on size 1000000

--prompt running rowcheck
whenever sqlerror exit 1

-- exit if zero rows, such as in a PDB that is not AWR enabled
declare
	view_rowcount pls_integer;
   no_rows exception;
   pragma exception_init(no_rows,-20000);
begin
	select count(*) into view_rowcount from &db_view;
	--dbms_output.put_line('rows: ' || view_rowcount);
	if view_rowcount = 0 then
		dbms_output.put_line('there are 0 rows in &db_view');
		dbms_output.put_line('if this is a PDB, then the you may need to run "pdb-awr-enable.sql"');
		raise no_rows;
	end if;
end;
/

whenever sqlerror continue
set feed off

set serveroutput off

col all_waits_divisor new_value all_waits_divisor noprint


-- get the divisor value from the data
-- all_waits histogram will never be more than 50 characters
select 
	floor(max(sum(wait_count)/50))  all_waits_divisor
from &db_view
where (
	wait_class not in ('Idle')
	and
	wait_class not in (&ignore_list)
)
group by snap_id, instance_number
order by instance_number, snap_id
/


set term on heading on feed on

prompt Using view &db_view

with wc_symbols as
(
   select rownum id, column_value wc_symbol
   from (
      table(
			-- the alternative list with punctuation looks more interesting
         --sys.odcivarchar2list('M','P','L','C','R','G','D','N','O','Q','S','I','U')
           sys.odcivarchar2list('!','@','#','$','%','^','*','=','+','-',':','<','>')
      )
   )
) ,
-- currently known classes
classes as (
   select rownum id, column_value wait_class
   from (
      table (
         sys.odcivarchar2list(
            'Administrative'  -- 'M' or !
            ,'Application'    -- 'P' or @
            ,'Cluster'        -- 'L' or #
            ,'Commit'         -- 'C' or $
            ,'Concurrency'    -- 'R' or %
            ,'Configuration'  -- 'G' or ^
            ,'Idle'           -- 'D' or *
            ,'Network'        -- 'N' or =
            ,'Other'          -- 'O' or +
            ,'Queueing'       -- 'Q' or -
            ,'Scheduler'      -- 'S' or :
            ,'System I/O'     -- 'I' or <
            ,'User I/O'       -- 'U' or >
         )
      )
   )
),
rawdata as (
	select
		to_char(s.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') begin_interval_time
		, h.instance_number
		, h.wait_class
		, s.wc_symbol
		, sum(h.wait_time_milli)/60000 wait_time_minutes
		, sum(h.wait_count) wait_count
	from &db_view h
	join dba_hist_snapshot s on s.snap_id = h.snap_id
		and h.instance_number = s.instance_number
		and h.dbid = s.dbid
		and (
			h.wait_class not in ('Idle')
			and 
			h.wait_class not in (&ignore_list)
		)
	join classes c on c.wait_class = h.wait_class
	join wc_symbols s on s.id = c.id
	group by to_char(s.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') ,h.instance_number, h.wait_class, s.wc_symbol
),
data as (
	select distinct
		begin_interval_time
		, instance_number
		, wait_class
		, wc_symbol
		, wait_count
		--, wait_time_minutes
		--, wait_count
		--, (1000 * wait_time_minutes) / wait_count wait_time_milli_avg
		, sum(wait_count) over (partition by begin_interval_time, instance_number) wait_count_sum
	from rawdata r
	order by begin_interval_time, wc_symbol
),
aggs as (
select
		begin_interval_time
		, instance_number
		, wc_symbol
		, wait_count
		, wait_count_sum
		, round(wait_count / wait_count_sum * 100) wait_pct
		, sum(wait_count / wait_count_sum * 100) over (partition by begin_interval_time, instance_number order by begin_interval_time, instance_number) total_pct
from data
),
histparts as (
select
		begin_interval_time
		, instance_number
		, wc_symbol
		, wait_count
		, wait_count_sum
		, wait_pct
		-- C D G I L M N O P Q R S U
		, rpad(case when wait_pct < 1 then '' else wc_symbol end, floor(wait_pct), case when wait_pct < 1 then '' else wc_symbol end) histpart
		--, case when wait_pct < 1 then '' else 'C' end test
from aggs
)
select 
	begin_interval_time
	, instance_number
	--, wc_symbol
	--, wait_count
	--, wait_pct
	, wait_count_sum
	--, histpart
	, listagg(histpart,'') within group(order by begin_interval_time, instance_number ) histogram
	, rpad(:all_waits_char, floor(wait_count_sum/&all_waits_divisor) , :all_waits_char) all_waits
from histparts
group by begin_interval_time, instance_number, wait_count_sum
order by instance_number, begin_interval_time
/


undef 1


