define prefix='v'
set document off

doc

$Source: /home/jkstill/oracle/admin/gh/RCS/latch_statsa.sql,v $
$Revision: 1.2 $
$Author: jkstill $
$Date: 1998/05/24 22:59:31 $

This SQL*PLUS script reports on some latch get and miss rates.

"% of gets" is the % of latch gets which were for this latch.

% of misses" is the % of latch misses which were for this latch.

"Miss rate %" is the % of time a request for this latch did not 
succeed on the first try.

"spin succ %" is the %age of time that the latch could be got 
within the first spin_count tries

"Avg sleeps" is the average number of sleeps which occured once the 
latch could not be obtained after trying spin_lock times.

"Waits holding%" is the %age of times a process held the latch and went into a wait state.


Guy Harrison
gharriso@werple.mira.net.au

#

@stat_ctl

set termout off
drop table gh$latch_stat;

set feedback off

column name format a23 heading "Latch|Name"
column gets format 9.99EEEE  heading "Gets"    print
column misses format 99,990 heading "Miss|/1000"   noprint
column sleeps format 99,990 heading "Sleeps|/1000" noprint
column avg_sleeps format 99.0 heading "Avg|Sleeps" print
column first_spin_success format 900.0 heading "spin|success|%" noprint
column miss_rate format 90.00 heading "Miss|rate %"
column sleep_rate format 90.00 heading "Sleep|rate %"
column pct_of_gets format 999.0 heading "% of|gets"
column pct_of_misses format 999.0 heading "% of|Misses" 
column pct_of_sleeps format 999.0 heading "% of|Sleeps" 
column miss_flag heading "" 
column waits_holding_pct format 99.0 heading "Waits|holding|%" noprint


ttitle center 'ORACLE latch statistics:  &instance_name' right '&print_date' skip center '&period_comment_' skip 2


spool off;
set termout on
spool latch_statsa.txt

undefine v_total_misses
undefine v_total_gets
undefine v_total_sleeps

variable v_total_misses number
variable v_total_gets number
variable v_total_sleeps number

BEGIN
	select sum(abs(gets)),sum(abs(misses)),sum(abs(sleeps))
          into :v_total_gets,:v_total_misses,:v_total_sleeps
	  from &prefix.$latch; 
END;
/

create table gh$latch_stat as 
select name,
       abs(gets) gets,
       0 pct_of_gets,
       abs(misses) misses,
       0 pct_of_misses,
       0 pct_of_sleeps,
       ' '                        miss_flag,
       sleeps,
       abs(sleeps)/decode(abs(gets),0,1,abs(gets))*100 sleep_rate,
       abs(misses)/decode(abs(gets),0,1,abs(gets))*100 miss_rate,
       (spin_gets/decode(abs(misses),0,1,abs(misses)))*100 first_spin_success,
       sleeps/decode(abs(misses)-spin_gets,0,1,abs(misses)-spin_gets) avg_sleeps,
       waits_holding_latch*100/decode(abs(misses),0,1,abs(misses)) waits_holding_pct
 from &prefix.$latch
where gets !=0
/

update gh$latch_stat set
   pct_of_misses= misses/decode(:v_total_misses,0,1,:v_total_misses)*100 
/
update gh$latch_stat set
   pct_of_sleeps= sleeps/decode(:v_total_sleeps,0,1,:v_total_sleeps)*100 
/
update gh$latch_stat s set
   pct_of_gets= gets/decode(:v_total_gets,0,1,:v_total_gets)*100 
/

update gh$latch_stat
   set miss_flag='*'
 where (miss_rate > 1
        and pct_of_misses > 1)
    or sleep_rate>.5
/

select name,gets gets,pct_of_gets, sleeps/1000 sleeps,misses/1000 misses,
       pct_of_sleeps,pct_of_misses,sleep_rate,miss_rate,miss_flag,
       first_spin_success,avg_sleeps,
       waits_holding_pct
 from gh$latch_stat
where pct_of_gets >.1 or pct_of_misses > .1 or pct_of_sleeps >.1
 order by sleeps desc,misses desc,gets desc
/

drop table gh$latch_stat;

prompt
prompt Notes:
prompt -------------------------------------------------------------------;
prompt
prompt Miss rates and Sleep rates should be less that 1% generally,  although
prompt higher rates may not matter if the latch accounts for a very small 
prompt %age of latch gets
prompt
prompt To reduce contention for the redo allocation latch;
prompt try creating more latches (LOG_SIMULTANEOUS_COPIES)
prompt up to 2xCPU_COUNT.  If this fails,  try forcing 
prompt pre-build of redo entries by upping 
prompt LOG_ENTRY_PREBUILD_THRESHOLD
prompt
prompt To reduce contention for library cache latch,  reduce dynamic SQL.
prompt In 7.2,  consider increasing _kgl_latch_copies
prompt
prompt To reduce contention for the cache buffers lru chain,  increase 
prompt _db_block_hash_buckets and/or reduce physical reads by increasing 
prompt db_block_buffers.  ORACLE 7.3 has multiple lru chain latches.
prompt 
prompt Increasing spin count may reduce latch free waits in V$SYSTEM_EVENT
prompt and may increase the spin succ% rate shown above at the cost of 
prompt increased CPU utilisation.
prompt ------------------------------------------------------------------;


spool off
