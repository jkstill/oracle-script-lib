

# oracle-connect-rate.sh

Determine the connection rate from the Oracle alert log

Getting this info from the listener.log will include failed connections, making it possible to see how frequent connection attempts are regardless of errors during the connect.

## Options

```
     ./oracle-connect-rate.sh

     -f listener log file
     -S service 
     -s summarize by second
     -m summarize by minute
     -h summarize by hour
     -d dryrun - do not execute commands
     -? help

```


## Dry run with -d

The command to be used is displayed, but not executed

```
./oracle-connect-rate.sh -d -h -f listener.log -S orcl 
CMD: grep -h "orcl.** establish *" listener.log | awk -v timeStrLen=2 '{ print $1, substr($2,0,timeStrLen) }' | uniq -c | awk -v timePadStr=':00:00' '{ print $2,$3 timePadStr"," $1 }'
```

## Specify the service to search for with -S

The following examples all look for connections to the orcl service.
If not specified, all connections are searched.

### per second

```
./oracle-connect-rate.sh  -s -f listener.log -S orcl | head  >> README.md
16-OCT-2017 00:03:01,2
16-OCT-2017 00:03:02,1
16-OCT-2017 00:03:03,14
16-OCT-2017 00:03:04,9
16-OCT-2017 00:03:05,9
16-OCT-2017 00:03:06,9
16-OCT-2017 00:03:07,8
16-OCT-2017 00:03:08,9
16-OCT-2017 00:03:09,10
16-OCT-2017 00:03:10,4
```


### per minute

```
./oracle-connect-rate.sh  -m -f listener.log -S orcl | head  >> README.md
16-OCT-2017 00:03:00,282
16-OCT-2017 00:04:00,418
16-OCT-2017 00:05:00,317
16-OCT-2017 00:06:00,315
16-OCT-2017 00:07:00,370
16-OCT-2017 00:08:00,236
16-OCT-2017 00:09:00,287
16-OCT-2017 00:10:00,386
16-OCT-2017 00:11:00,312
16-OCT-2017 00:12:00,236
```


### per hour

```
./oracle-connect-rate.sh  -h -f listener.log -S orcl | head  >> README.md
16-OCT-2017 00:00:00,16403
16-OCT-2017 01:00:00,14530
16-OCT-2017 02:00:00,13200
16-OCT-2017 03:00:00,12805
16-OCT-2017 04:00:00,12413
16-OCT-2017 05:00:00,12399
16-OCT-2017 06:00:00,13640
16-OCT-2017 07:00:00,15833
16-OCT-2017 08:00:00,17286
16-OCT-2017 09:00:00,18575
```

# get-bind-info.pl

The get-bind-info.pl script can pull bind information from a 10046 trace file.

This is useful where multiple executions of a SQL are run with different bind values during testing.

Currently the Cursor# is hardcoded into the script.

An improvement would be to detect the cursor# by the SQL_ID, as it is possible for the cursor# to change.

example:


``` text

./get-bind-info.pl orcl_ora_48585_doio5cpk2xyzk.trc

...

====== tim: 1510368247005494 =========

Execution Statistics

         row count: 0
    optimizer goal: ALL_ROWS
      elapsed time: 4.210786
          cpu time: 3.817419
    physical reads: 56
   consistent gets: 726000
      current gets: 0
 total logical IOs: 726000


 Bind Values
 BIND#0=9812850
 BIND#1="RESULT"
 BIND#2="FAIL"
 BIND#3=1
 BIND#4="SALESREVIEW"
 BIND#5=1
 BIND#6=2
 BIND#7=4
 BIND#8="ROUTING"
 BIND#9="N"
 BIND#10="N"
 BIND#11="N"
 BIND#12="CUSTOMER"
 BIND#13="STATE"
 BIND#14="N"
 BIND#15="N"
 BIND#16="ROUTENUM"
 BIND#17=1
 FETCH: FETCH #140304068176776:c=269959,e=725736,p=59,cr=40022,cu=0,mis=0,r=0,dep=0,og=1,plh=1619557942,tim=1510368246997484


====== tim: 1510368246269998 =========

Execution Statistics

         row count: 0
    optimizer goal: ALL_ROWS
      elapsed time: 0.725736
          cpu time: 0.269959
    physical reads: 59
   consistent gets: 40022
      current gets: 0
 total logical IOs: 40022


 Bind Values
 BIND#0=8191335
 BIND#1="RESULT"
 BIND#2="FAIL"
 BIND#3=1
 BIND#4="SALESREVIEW"
 BIND#5=1
 BIND#6=2
 BIND#7=4
 BIND#8="ROUTING"
 BIND#9="N"
 BIND#10="N"
 BIND#11="N"
 BIND#12="CUSTOMER"
 BIND#13="STATE"
 BIND#14="N"
 BIND#15="N"
 BIND#16="ROUTENUM"
 BIND#17=1

```


# rman-chk-syntax.sh

Use this script to check the syntax of RMAN commands or scripts

No connection is made to any database

## Commands on the Linux command line

```bash

>  rman-chk-syntax.sh "restore database from tag='RMAN_2018-09_14:30' validate header"
RMAN CMD: restore database from tag='RMAN_2018-09_14:30' validate header

Recovery Manager: Release 12.1.0.2.0 - Production on Fri Aug 17 09:46:04 2018

Copyright (c) 1982, 2014, Oracle and/or its affiliates.  All rights reserved.

RMAN>
RMAN>
The command has no syntax errors

RMAN>
RMAN>

Recovery Manager complete.

```

## Commands from an RMAN script

```bash
>  cat lvl_1.rman

run {
allocate channel ch1 device type 'sbt' PARMS="SBT_LIBRARY=oracle.disksbt,BLKSIZE=131072,ENV=(BACKUP_DIR=/mnt/lestrade/nfs1/ts10_backups)";
allocate channel ch2 device type 'sbt' PARMS="SBT_LIBRARY=oracle.disksbt,BLKSIZE=131072,ENV=(BACKUP_DIR=/mnt/lestrade/nfs1/ts10_backups)";
allocate channel ch3 device type 'sbt' PARMS="SBT_LIBRARY=oracle.disksbt,BLKSIZE=131072,ENV=(BACKUP_DIR=/mnt/lestrade/nfs1/ts10_backups)";
backup incremental level=1 format '%d_T%T_db_s%s_p%p_t%t' database filesperset 4 TAG LVL_1_BCT_2008_02_25_21_52;
backup format '%d_T%T_arch_s%s_p%p_t%t' archivelog all filesperset 4 TAG LVL_1_BCT_2008_02_25_21_52 delete input;
}

jkstill@poirot ~/oracle/oracle-script-lib/bin $
>  rman-chk-syntax.sh < lvl_1.rman

Recovery Manager: Release 12.1.0.2.0 - Production on Fri Aug 17 09:48:23 2018

Copyright (c) 1982, 2014, Oracle and/or its affiliates.  All rights reserved.

RMAN> 2> 3> 4> 5> 6> 7>
The command has no syntax errors

RMAN>

Recovery Manager complete.
```

# get-alert-logs.sh

Retrieve the most recent 20k lines of the alert log from all instances.

The script is RAC aware, and will detect the instance on up to 4 nodes.

The script must be run on each node separately.

The files are place in the ./logs directory.

Contents of oratab:

```text
+ASM1:/u01/app/19.0.0/grid:N
ohome:/u01/app/oracle/product/19.0.0/dbhome_1:N
cdb:/u01/app/oracle/product/19.0.0/dbhome_1:N
cdb1:/u01/app/oracle/product/19.0.0/dbhome_1:N
```

```text
$ ./get-alert-logs.sh
potential sid: ohome
   localInst:

Alert log filename not set - is the instance up?

potential sid: cdb
   localInst: cdb1
   alert log: /u01/app/oracle/diag/rdbms/cdb/cdb1/trace/alert_cdb1.log
potential sid: cdb1
   localInst:

Alert log filename not set - is the instance up?
```

The script will fail on ohome and cdb1, as those do not represent instances, but are there for convenience.


# get-lgwr-trace.sh

Retrieve the LGWR trace files per instance.

The files are place in the ./trace directory.


The script is RAC aware, and will detect the instance on up to 4 nodes.

The script must be run on each node separately.

Contents of oratab:

```text
+ASM1:/u01/app/19.0.0/grid:N
ohome:/u01/app/oracle/product/19.0.0/dbhome_1:N
cdb:/u01/app/oracle/product/19.0.0/dbhome_1:N
cdb1:/u01/app/oracle/product/19.0.0/dbhome_1:N
```

The script will fail on ohome and cdb1, as those do not represent instances, but are there for convenience.

```text
$ ./get-lgwr-trace.sh
potential sid: ohome
   localInst:

Tracefile not set - is the instance up?

potential sid: cdb
   localInst: cdb1
   tracefile: /u01/app/oracle/diag/rdbms/cdb/cdb1/trace/cdb1_lgwr_5988.trc
potential sid: cdb1
   localInst:

Tracefile not set - is the instance up?
```

# memory sizes

Getting size of the bytes of memory actually allocated to a process is always tricky.

Some memory is shared, such as shown in `ipcs -m`.

There are other types of shared memory as well, such as that used by shared libraries.

These scripts attempt to determine how much memory is allocated to a process. 

This is not the same as the amount of memory that is currently in use by the process.

That would be the Resident Set Size, also known as RSS.

Check the man pages for proc and pmap for more info on that.

The results on Oracle Linux 6 seem reasonable, but YMMV.

Both will likely require root access.


## memsz.sh

This script attempts to determine memory usage for a single PID.

The `procmem.pl` script is likely more accurate.

```text
# ./memsz.sh 4774
16351232
```

Or in verbose mode:
```text
# MSZ_VERBOSE=Y ./memsz.sh  4774
172f9000 - 172aa000 =  323584
18ece000 - 18e07000 =  815104
7ff46df51000 - 7ff46dcf1000 =  2490368
7ff46e3e1000 - 7ff46e0f1000 =  3080192
7ff46e4b1000 - 7ff46e491000 =  131072
7ff46ed29000 - 7ff46eb11000 =  2195456
7ff46ee0a000 - 7ff46ed79000 =  593920
7ff46ee8a000 - 7ff46ee7a000 =  65536
7ff46eeea000 - 7ff46eeba000 =  196608
7ff46efba000 - 7ff46eeea000 =  851968
7ff46f03a000 - 7ff46efba000 =  524288
7ff46f24a000 - 7ff46f245000 =  20480
7ff46f964000 - 7ff46f764000 =  2097152
7ff46fb77000 - 7ff46fb71000 =  24576
7ff470366000 - 7ff470361000 =  20480
7ff47057f000 - 7ff47057d000 =  8192
7ff470799000 - 7ff470797000 =  8192
7ff4709b5000 - 7ff4709b1000 =  16384
7ff471334000 - 7ff471331000 =  12288
7ff471596000 - 7ff471594000 =  8192
7ff472231000 - 7ff472230000 =  4096
7ff473110000 - 7ff47310b000 =  20480
7ff473fee000 - 7ff473fed000 =  4096
7ff4745fc000 - 7ff474422000 =  1941504
7ff474614000 - 7ff474611000 =  12288
7ff474617000 - 7ff474616000 =  4096
7ffc6a820000 - 7ffc6a749000 =  880640

Total Memory allocated for 4774: 16351232 Bytes
```

## memsz-all.sh

Sum the amount of private memory for all of a users processes:

```text
# ./memsz-all.sh  oracle
PID 4313: 115994624
PID 4399: 5763072
PID 4401: 5767168
...
PID 12582: 9719808
PID 15902: 14594048
PID 32612: 48971776

Total Private Memory allocated for User: oracle 1647730688 Bytes
```

## procmem.pl

This script parses the /proc/PID/pagemap file, and sums the memory used where the pages in question are referenced only by that PID.

Any shared memory is excluded by default.

`perldoc procmem.pl` and `procmem.pl --help` for usage.

Examples:

```text
# ./procmem.pl --pid 24422  
68144K
```
Verbose:

```text
# 
# ./procmem.pl --pid 24422  --verbose

line: 1724c000-172aa000 rw-p 16c4c000 08:11 211023021                          /u01/app/oracle/product/19.0.0/dbhome_1/bin/oracle
pfn: 001538CC
memSize: 376K
data:  1000000110000000000000000000000000000000000101010011100011001100
pgCount: 00000001
Memory Resident
=================
line: 172aa000-172f9000 rw-p 00000000 00:00 0 
pfn: 00000000
memSize: 316K
data:  0000000010000000000000000000000000000000000000000000000000000000
pgCount: 00000001
Page Table Entry: soft-dirty
=================
line: 17af1000-17b3d000 rw-p 00000000 00:00 0                                  [heap]
pfn: 0014C0B8
memSize: 304K
data:  1000000110000000000000000000000000000000000101001100000010111000
pgCount: 00000001
Memory Resident

...

=================
line: 7ffe00b1a000-7ffe00ba5000 rw-p 00000000 00:00 0                          [stack]
pfn: 0009D6CB
memSize: 556K
data:  1000000110000000000000000000000000000000000010011101011011001011
flags: ACTIVE - ANON - BUDDY - COMPOUND_HEAD - ERROR - HUGE - HWPOISON - LOCKED - NOPAGE - SLAB - SWAPBACKED - UNEVICTABLE - UPTODATE
pgCount: 00000001
Memory Resident
=================
line: 7ffe00bc4000-7ffe00bc7000 r--p 00000000 00:00 0                          [vvar]
pfn: 00000000
memSize: 12K
data:  0000000010000000000000000000000000000000000000000000000000000000
pgCount: 00000001
Page Table Entry: soft-dirty
=================
Mem Used: 68144K
```

## sga-smallpage-detector.pl

This script will detect Oracle SGA segments that are not using HugePages.

It works by getting the pid and sid of all the ora_pmon_<SID> processes

Then the memory segment maps are captured from /proc/PID/smaps

If the segment is over a few megabytes in size, and the KernelPageSize for the segment is < 2M, then a warning is printed

sample output

```text
     ##############################
     PID: 161290 SID: cdb01
     shmid: 1272971277
       segment size: 20971520
       kernelPageSize: 2097152
     shmid: 1273233429
	skipping due to small segment size
     shmid: 1273167891
       segment size: 115343360
       kernelPageSize: 2097152
     shmid: 1273069584
       segment size: 48184164352
       kernelPageSize: 2097152
     ##############################
     PID: 161729 SID: cdb02
     shmid: 1273561128
       segment size: 20971520
       kernelPageSize: 2097152
     shmid: 1273823280
       segment size: 67108864
       kernelPageSize: 2097152
     shmid: 1274052663
	skipping due to small segment size
     shmid: 1274019894
       segment size: 48234496
       kernelPageSize: 2097152
     shmid: 1273921587
       segment size: 21340618752
       kernelPageSize: 4096
     !!! sid: cdb02 pid: 161729 shmid: 1273921587 is not using HugePages !!!

```

# network

## sqlnet-io-rates.pl

Get the rates of network IO from v$sesstat

```text
$ ./sqlnet-io-rates.pl -database orcl -username scott -password XXX -iterations 30 -interval-seconds 5
timestamp,elapsed,schema,client roundtrips,dblink roundtrips,bytes from client,bytes from dblink,bytes to client,bytes to dblink
2021-11-16 00:33:30,5.007873,SCOTT,7,0,3850,0,4830,0
2021-11-16 00:33:30,5.007873,SOE,144,0,17060,0,8104,0
2021-11-16 00:33:30,5.007873,SYS,0,0,0,0,0,0
2021-11-16 00:33:30,5.007873,SYSRAC,0,0,0,0,0,0
2021-11-16 00:33:35,5.008368,SCOTT,7,0,3850,0,52719,0
2021-11-16 00:33:35,5.008368,SOE,130,0,14947,0,7194,0
2021-11-16 00:33:35,5.008368,SYS,0,0,0,0,0,0
2021-11-16 00:33:35,5.008368,SYSRAC,0,0,0,0,0,0
2021-11-16 00:33:40,5.007935,SCOTT,13,0,4612,0,122745,0
2021-11-16 00:33:40,5.007935,SOE,171,0,20839,0,9296,0
2021-11-16 00:33:40,5.007935,SYS,0,0,0,0,0,0
2021-11-16 00:33:40,5.007935,SYSRAC,0,0,0,0,0,0


```







