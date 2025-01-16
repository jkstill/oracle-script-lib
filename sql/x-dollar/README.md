

## Gathering X$ Information

The definitions for many X$ tables can be found via google.

Much of the external knowledge about Oracle X$ tables comes from:
  Oracle Support Note 22241.1 ;
  List of X$ Tables and how the names are derived

This note is no longer available from Oracle.  Some skillful web searching may turn up a copy of it though.

The information will be used to provide some descriptions of the x$ tables with on one of the describe scripts


### Yong's compilation

Yong Huang has compiled some of the information from Oracle Note 22241.1  and other sources into a web page.

We are scraping that note for use in some SQL.

Please note that (pandoc)[https://pandoc.org/] is required for this step.

Please note that (pandoc)[https://pandoc.org/] is required for this step

```curl 'http://yong321.freeshell.org/computer/x$table.html' | pandoc -f html -t gfm  > x-dollar-tables.md```

Manually edit the MD file, remove lines at beginning and end of the file that do not describe x$ tables

It will be necessary to put multiple tables on a single line:

```text
x$t1,
x$t2
```

should be 

```text
x$t1,x$t2
```

### Now create a json file:

```
$ ./x-dollar-parse.pl < x-dollar-tables.md  > x-dollar-tables.json
```

It will be necessary to manually remove the final trailing comma,
or modify `x-dollar-parse.pl` to not print the final comma.

Now the JSON can be used to create some rather convoluted SQL.

The whole purpose of this is to provide some descriptions of an x$table on demand, without creating objects in the database.

### create the SQL

Some extra care needed in quoting single quotes for awk

```text
$ jq -r '.Data[] | .Table ' x-dollar-tables.json | awk '{ print "q'\''''[" $1 "]'\''''," }'
...
q'[x$qesmmiwt]',
q'[x$qesmmsga]',
q'[x$qksfgi_cursor]',
...
```

Now use this to generate 3 SQL files.

```text
$ cp gen-pre.sql xdllr-tablist.sql
$ jq -r '.Data[] | .Table ' x-dollar-tables.json | awk '{ print "q'\''''[" $0 "]'\''''," }' >> xdllr-tablist.sql
$ cat gen-post.sql >> xdllr-tablist.sql

```

Now it will be necessary to manually remove the final trailing comma from the list in the file.
Also, change `varchar2_data` to `x_dollar_table`

Now follow similar steps for the abstract lines and the comments.

```text
$ cp gen-pre.sql xdllr-abstract-list.sql
$ jq -r '.Data[] | .Abstract ' x-dollar-tables.json | awk '{ print "q'\''''[" $0 "]'\''''," }' >> xdllr-abstract-list.sql 
$ cat gen-post.sql >> xdllr-abstract-list.sql 
```

Change `varchar2_data` to `abstract` and remove the final trailing comma.

Do the same for the comments

```text
$ cp gen-pre.sql xdllr-comments.sql
$ jq -r '.Data[] | .Comments ' x-dollar-tables.json | awk '{ print "q'\''''[" $0 "]'\''''," }' >> xdllr-comments.sql
$ cat gen-post.sql >> xdllr-comments.sql
```

Change `varchar2_data` to `comments` and remove the final trailing comma.

The script `xdllr-info.sql` will join all of these:

```text
X_DOLLAR_TABLE                 ABSTRACT                       COMMENTS
------------------------------ ------------------------------ --------------------------------------------------------------------------------
x$ckptbuf                      checkpoint buffer (queue)       Lists the buffers on the checkpoint queue. Immediately after a full checkpoint,
                                                               the buffers with non-zero buf_ptr and buf_dbablk should go down.

x$dbgalertext                  debug alert extented            One use is to find old `alert.log` text long after you recycled the physical fi
                                                              le: select originating_timestamp, message_text from interesting and are not avai
                                                              lable in `alert.log`.

x$dbglogext                    debug log extended              12*c*

x$dbgricx, x$dbgrifx, x$dbgrik debug repository (Automatic Di  code?|f?|key|problem ? You can quickly summarize what kind of errors the databa
x, x$dbgripx                   agnostic Repository) incident  se has had: select error_facility||'-'||error_number, count(*) from x$dbgricx gr
                                                              oup by error_facility||'-'||error_number order by 2, and optionally restrict to
                                                              a certain time range. You can summarize on a more granular level, such as shared
                                                               pool vs large pool on error_arg2 in case of ORA-4031, and find records of these
                                                               errors in v$diag_incident or (undocumented) v$diag_diagv_incident. In any case,
                                                               you may find this easier than `grep` alert.log. For each incident, its session
                                                              info is in
```

## Describe X$ tables

Some scripts that provide varying level of information about X$ tables

### xdesc.sql

Run this to get the column list for the table, and a description (if available)


```text
SQL# @xdesc x$k2gte
Which X$ Table:
Name                           Null?    Type
------------------------------ -------- ------------------------------
ADDR                                    RAW (8)
INDX                                    NUMBER
INST_ID                                 NUMBER
CON_ID                                  NUMBER
K2GTIFMT                                NUMBER
K2GTITLN                                NUMBER
K2GTIBLN                                NUMBER
K2GTITID_ORA                            VARCHAR2 (64)
K2GTITID_EXT                            RAW (64)
K2GTIBID                                RAW (64)
K2GTECNT                                NUMBER
K2GTDSES                                RAW (8)
K2GTDBRN                                RAW (8)
K2GTDXCB                                RAW (8)
K2GTERCT                                NUMBER
K2GTDPCT                                NUMBER
K2GTDFLG                                NUMBER
K2GTETYP                                NUMBER
K2GTEILH                                RAW (8)
K2GTEID1                                NUMBER
K2GTEGTX                                NUMBER
K2GTBILH                                RAW (8)
K2GTBID2                                NUMBER
K2GTBGTX                                NUMBER

PL/SQL procedure successfully completed.


X_DOLLAR_TABLE                 ABSTRACT                       COMMENTS
------------------------------ ------------------------------ --------------------------------------------------------------------------------
x$k2gte, x$k2gte2              kernel 2-phase commit, global   See [Note:104420.1](https://supporthtml.oracle.com/ep/faces/secure/km/DocumentD
                               transaction entry              isplay.jspx?id=104420.1). Find sessions coming from or going to a remote databas
                                                              e; in short, v$transaction.addr. select /*+ ordered */ substr(s.ksusemnm,1,10)||
                                                              '-'|| substr(s.ksusepid,1,10) origin, substr(g.k2gtitid_ora,1,35) gtxid, substr(
                                                              s.indx,1,4)||'.'|| substr(s.ksuseser,1,5) lsession, s.ksuudlna username, substr(
                                                              decode(bitand(ksuseidl,11), 1,'ACTIVE', 0, decode( bitand(ksuseflg,4096) , 0,'IN
                                                              ACTIVE','CACHED'), 2,'SNIPED', 3,'SNIPED', 'KILLED'),1,1) status, e.kslednam wai
                                                              ting from x$k2gte g, x$ktcxb t, g.k2gtdses=t.ktcxbses and s.addr=g.k2gtdses and
                                                              e.indx=s.ksuseopc; It's better than checking for DX locks for outgoing sessions
                                                              (since a DX lock only shows up in v$lock for the current distributed transaction
                                                               session). X$k2gte2 is the same as x$k2gte except on k2gtetyp which may show 2 f
                                                              or 'TIGHTLY COUPLED' instead of 0 for 'FREE'. One use of k2gtitid_ora as opposed
                                                               to the hex numbers in v$global_transaction.globalid.


1 row selected.
```


### xdesc-all.sql

This script generates output showing all x$ tables and their columns (if possible)

For cases where `dbms_sql.describe` encounters an error, you can always use the sqlplus `describe` command.

```text

me                           Null?    Type
------------------------------ -------- ------------------------------

########################################################
## X$KQFTA
########################################################
ADDR                                    RAW (8)
INDX                                    NUMBER
INST_ID                                 NUMBER
CON_ID                                  NUMBER
KQFTAOBJ                                NUMBER
KQFTAVER                                NUMBER
KQFTANAM                                VARCHAR2 (128)
KQFTATYP                                NUMBER
KQFTAFLG                                NUMBER
KQFTARSZ                                NUMBER
KQFTACOC                                NUMBER

########################################################
## X$KQFVI
########################################################
ADDR                                    RAW (8)
INDX                                    NUMBER
INST_ID                                 NUMBER
CON_ID                                  NUMBER
KQFVIOBJ                                NUMBER
KQFVIVER                                NUMBER
KQFVINAM                                VARCHAR2 (128)

########################################################
## X$KQFVT
########################################################
ADDR                                    RAW (8)
INDX                                    NUMBER
INST_ID                                 NUMBER
CON_ID                                  NUMBER
KQFTPSEL                                VARCHAR2 (4000)
...
```




