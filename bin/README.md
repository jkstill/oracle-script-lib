

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

./get-bind-info.pl orcl_ora_48585_doio5cpk2xyzk-.trc

``` text
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


