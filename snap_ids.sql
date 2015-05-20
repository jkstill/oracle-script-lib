
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;
column host      heading "Host"

prompt
prompt Instances in this Statspack schema
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

select 
       dbid            dbid
     , instance_number inst_num
     , db_name         dbb_name
     , instance_name   instt_name
     , host_name       host
	  , max(startup_time) startup_time
  from stats$database_instance
  group by dbid,instance_number,db_name,instance_name,host_name
  order by startup_time
/

prompt
prompt Using &&dbid for database Id
prompt Using &&inst_num for instance number


--
--  Set up the binds for dbid and instance_number

variable dbid       number;
variable inst_num   number;
begin
  :dbid      :=  &dbid;
  :inst_num  :=  &inst_num;
end;
/


--
--  Ask for the snapshots Id's which are to be compared

set termout on;
column instart_fmt noprint;
column inst_name   format a12  heading 'Instance';
column db_name     format a12  heading 'DB Name';
column snap_id     format 99999990 heading 'Snap|Id';
column snapdat     format a17  heading 'Snap Started' just c;
column lvl         format 99   heading 'Snap|Level';
column commnt      format a20  heading 'Comment';
column startup_time format a22 heading 'DB Start Time'

break on inst_name on db_name on host on instart_fmt skip 1;

ttitle lef 'Completed Snapshots' skip 2;

set term off
set linesize 110
set pagesize 60

spool $HOME/tmp/spsnap.txt

select to_char(s.startup_time,' dd Mon "at" HH24:mi:ss') instart_fmt
     , di.instance_name                                  inst_name
     , di.db_name                                        db_name
     , s.snap_id                                         snap_id
     , to_char(s.snap_time,'mm/dd/yyyy hh24:mi')         snapdat
	  , to_char(s.startup_time,'mm/dd/yyyy hh24:mi')      startup_time
     , s.snap_level                                      lvl
     , substr(s.ucomment, 1,60)                          commnt
  from stats$snapshot s
     , stats$database_instance di
 where s.dbid              = :dbid
   and di.dbid             = :dbid
   and s.instance_number   = :inst_num
   and di.instance_number  = :inst_num
   and di.dbid             = s.dbid
   and di.instance_number  = s.instance_number
   and di.startup_time     = s.startup_time
 order by db_name, instance_name, snap_id;

spool off

clear break;
ttitle off;
set term on


prompt
prompt Snapshot IDs may be found in ~/tmp/spsnap.txt
prompt


