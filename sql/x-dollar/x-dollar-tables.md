
x$bh

buffer header

This table is commonly used to find the object and the file\# and
block\# of its header when there's high cache buffers chains latch
contention: select obj, dbarfil, dbablk from x$bh a, v$latch\_children b
where a.hladdr = b.addr for the said latch (whose sleeps you think are
too high). You can also use this table to see if a specific buffer has
too many clones: select dbarfil, dbablk, count(\*) from x$bh group by
dbarfil, dbablk having count(\*) \> 2. Note obj column matches
dba\_objects.data\_object\_id, not object\_id. For performance reason,
don't merge dba\_extents with the query of x$bh that has a group by,
unless you use in-line view and `no_merge` hint (see J. Lewis [Practical
Oracle8i](http://www.jlcomp.demon.co.uk/ind_book.html), p.215) The tch
column, touch count, records how many times a particular buffer has been
accessed. Its flag column is explained by [J.
Lewis](http://www.jlcomp.demon.co.uk/buf_flag.html) (some unused columns
are later used; e.g. bit 29 means plugged\_from\_foreign\_db in 12c);
explanation of state, mode and indx can be found in [Anjo Kolk's
paper](http://www.akadia.com/download/documents/session_wait_events.pdf).
Tim is time the buffer touch happened ([Note 1](#time)). Lru\_flag is
about the buffer's position on LRU lists
([Ref](http://www.ixora.com.au/scripts/sql/blocks_on_hot_latches.sql)
and
[136312.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=136312.1));
2 moved\_to\_tail, 4 on\_auxiliary\_list (auxliary LRU), 8 hot\_buffer
(on hot end of main LRU), and numbers can be added e.g. 6=2+4.

x$ckptbuf

checkpoint buffer (queue)

Lists the buffers on the checkpoint queue. Immediately after a full
checkpoint, the buffers with non-zero buf\_ptr and buf\_dbablk should go
down.

x$dbgalertext

debug alert extented

One use is to find old `alert.log` text long after you recycled the
physical file: select originating\_timestamp, message\_text from
x$dbgalertext. The message\_id and message\_group columns are also
interesting and are not available in `alert.log`.

x$dbglogext

debug log extended

12*c*

x$dbgricx, x$dbgrifx, x$dbgrikx, x$dbgripx

debug repository (Automatic Diagnostic Repository) incident
code?|f?|key|problem ?

You can quickly summarize what kind of errors the database has had:
select error\_facility||'-'||error\_number, count(\*) from x$dbgricx
group by error\_facility||'-'||error\_number order by 2, and optionally
restrict to a certain time range. You can summarize on a more granular
level, such as shared pool vs large pool on error\_arg2 in case of
ORA-4031, and find records of these errors in v$diag\_incident or
(undocumented) v$diag\_diagv\_incident. In any case, you may find this
easier than `grep` alert.log. For each incident, its session info is in
x$dbgrikx.

x$dbkece

debug kernel error, critical error

Base table of undocumented v$diag\_critical\_error but includes facility
dbge (Diagnostic Data Extractor or dde)

x$dbkefefc

debug kernel error, fatal error flood control

Rules for flood control on too many fatal errors.

x$dglparam

data guard logical parameters

Base table of dba\_logstdby\_parameters but includes invisible
parameters.

x$diag\_alert\_ext

diagnostics alert extended

Base table of v$diag\_alert\_ext. Same as x$dbgalertext but has more
lines, slower to query

x$diag\_hm\_run,x$diag\_vhm\_run

diagnostics health monitor runs

Base table of undocumented v$diag\_(v)hm\_run. Health monitor job
records. Maybe complementary to v$hm\_run?

x$diag\_ips\_configuration

diagnostics incident packaging service configuration

Base table of v$diag\_ips\_configuration. Some ADR IPS related config
info. Like a few other v$diag\* (or x$diag\*) tables, some columns such
as adr\_home, name, can't be exactly matched as if there're trailing
characters. CTAS to create a regular table against which you query, or
use subquery factoring with /\*+materialize\*/ hint.

x$dnfs\_meta

dNFS metadata

Some metadata related to dNFS, SGA memory, message timeout, ping
timeout, etc.

x$dra\_failure

data recovery advisor failures

DRA failure names and descriptions.

x$drm\_history,x$drm\_history\_stats

dynamic remastering history, stats

History of RAC DRM and stats. Parent\_key is object\_id. If an object is
remastered to another node (new\_master) too frequently, consider
partitioning the app sessions. In 12.1.0.2, there's also
x$drm\_wait\_stats.

x$ipcor\_topo\_domain,x$ipcor\_topo\_ndev

ipc core topology domain|name device

12*c*R2 RAC. Interconnect interface protocol (e.g. ethernet), names,
MAC. No IP addresses, which are in v$cluster\_interconnects and
v$configured\_interconnects, x$ksipcip\_kggpnp and x$ksipcip.

x$jskjobq

job scheduling, job queue

Internal job queue. Job\_oid is object\_id in dba\_objects. If you must
query this table, exit the session as soon as you're done with your work
because your session after the query holds an exclusive JS lock, which
will block CJQ process\! Rollback or commit won't release the lock.

x$k2gte, x$k2gte2

kernel 2-phase commit, global transaction entry

See
[Note:104420.1](https://supporthtml.oracle.com/ep/faces/secure/km/DocumentDisplay.jspx?id=104420.1).
Find sessions coming from or going to a remote database; in short,
x$k2gte.k2gtdses matches v$session.saddr, .k2gtdxcb matches
v$transaction.addr. select /\*+ ordered \*/
substr(s.ksusemnm,1,10)||'-'|| substr(s.ksusepid,1,10) origin,
substr(g.k2gtitid\_ora,1,35) gtxid, substr(s.indx,1,4)||'.'||
substr(s.ksuseser,1,5) lsession, s.ksuudlna username,
substr(decode(bitand(ksuseidl,11), 1,'ACTIVE', 0, decode(
bitand(ksuseflg,4096) , 0,'INACTIVE','CACHED'), 2,'SNIPED', 3,'SNIPED',
'KILLED'),1,1) status, e.kslednam waiting from x$k2gte g, x$ktcxb t,
x$ksuse s, x$ksled e where g.k2gtdxcb=t.ktcxbxba and
g.k2gtdses=t.ktcxbses and s.addr=g.k2gtdses and e.indx=s.ksuseopc; It's
better than checking for DX locks for outgoing sessions (since a DX lock
only shows up in v$lock for the current distributed transaction
session). X$k2gte2 is the same as x$k2gte except on k2gtetyp which may
show 2 for 'TIGHTLY COUPLED' instead of 0 for 'FREE'. One use of
x$k2gte\[2\] is the clearly translated global transaction ID in
k2gtitid\_ora as opposed to the hex numbers in
v$global\_transaction.globalid.

x$kbrpstat

kernel backup recovery process(?) statistics

12*c*. RMAN related

x$kcbbes

kernel cache, buffer ?

Check incremental checkpoints
([259586.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=259586.1))

x$kcbbf

kernel cache, buffer buffer\_handles

[Jonathan Lewis](http://www.jlcomp.demon.co.uk/buffer_handles.html)
("\_db\_handles")

x$kcbfwait

kernel cache, buffer file wait

A commonly used query breaks down the contents of v$waitstat into
per-datafile statistics: select name, count, time from v$datafile df,
x$kcbfwait fw where fw.indx+1 = df.file\#

x$kcbkpfs

kernel cache, buffer ckpt prefetch statistics

[Tanel
Poder](http://www.freelists.org/archives/oracle-l/08-2004/msg00995.html)

x$kcbkwrl

kernel cache, buffer write list

each row for the write list of one DBWR

x$kcbldrhist

kernel cache, buffer load direct read history

 

x$kcbobh

kernel cache, buffer, objectqueue buffer header

10*g* and up. [Tanel
Poder](http://www.freelists.org/post/oracle-l/different-physical-access-method-because-of-disabling-Automated-Memory-Management,6)

x$kcboqh

kernel cache, buffer, object queue header

See above

x$kcbpdbrm

kernel cache, buffer, PDB resource metric

12*c*. Column value is actual buffer cache usage in db\_block\_size, the
same (except for unit) as buffer\_cache\_bytes of v$rsrc\_pdb or
bc\_size\_kgskmeminfo of x$kgskmeminfo. This table also gives lower
(column minimum, bound by db\_cache\_size if defined) and upper (column
maximum) limits.

x$kcbsw

kernel cache, buffer statistics
why

[Note:34405.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=34405.1):
select kcbwhdes, why0+why1+why2 "Gets", "OTHER\_WAIT" from x$kcbsw s,
x$kcbwh w where s.indx=w.indx and s."OTHER\_WAIT"\>0 order by 3 (That
works for 10*g* only; for newer versions, see x$kcbuwhy);
[Ref1](http://www.jlcomp.demon.co.uk/buffer_usage.html) ("statistics
about the way these \[x$kcbwh\] functions have been used")

x$kcbuwhy

kernel cache, buffer why

For 11*g* and up, select kcbwhdes, why0+why1+why2 "Gets", "OTHER\_WAIT"
from x$kcbsw s, x$kcbwh w, x$kcbuwhy w2 where s.indx=w.indx and
w.indx=w2.indx and s."OTHER\_WAIT"\>0

x$kcbwbpd

kernel cache, buffer workingset buffer pool descriptor

See
[183770.999](https://metalink.oracle.com/metalink/plsql/ml2_documents.showDocument?p_database_id=FOR&p_id=183770.999)
for relationship to x$bh and x$kcbwds. Some people use this query to
find how many blocks of a segment are in each buffer pool: select
decode(pd.bp\_id,1,'KEEP',2,'RECYCLE',3,'DEFAULT',4,'2K SUBCACHE',5,'4K
SUBCACHE',6,'8K SUBCACHE',7,'16K SUBCACHE',8,'32K SUBCACHE','UNKNOWN')
subcache, bh.object\_name,bh.blocks from x$kcbwds ds, x$kcbwbpd pd,
(select /\*+ use\_hash(x) \*/ set\_ds, o.name object\_name, count(\*)
BLOCKS from obj$ o, x$bh x where o.dataobj\#=x.obj and x.state\!=0 and
o.owner\#\!=0 and o.name='*\&mytable*' group by set\_ds, o.name) bh
where ds.set\_id\>=pd.bp\_lo\_sid and ds.set\_id\<=pd.bp\_hi\_sid and
pd.bp\_size\!=0 and ds.addr=bh.set\_ds

x$kcbwds

kernel cache, buffer workingset descriptors

See above. Also see
[Ref1](http://www.ixora.com.au/newsletter/2000_10.htm#cache),
[Ref2](http://www.perfvision.com/papers/06_buffer_cache.ppt),
[Ref3](http://www.oraclefans.cn/forum/showblog.jsp?rootid=6555). Total
row count in this table is \_db\_block\_lru\_latches, although only
db\_writer\_processes rows have real numbers. Full list and descriptions
of the columns are in the note section of
[Ref4](http://www.perfvision.com/papers/06_buffer_cache.ppt) (search for
"Xuan Bui of Oracle France") or in
[Ref5](http://my-oracle.it-blogs.com.ua/post-257.aspx).

x$kcbwh

kernel cache, buffer where/why

See x$kcbsw for SQL.
[Ref1](http://www.jlcomp.demon.co.uk/buffer_usage.html) ("different
functions that may be used to perform different types of logical I/O"),
[Ref2](http://web.archive.org/web/20071205154134/http://www.dizwell.com/prod/node/342)

x$kcccf

kernel cache, controlfilemanagement control file

In 10*g*R1, to find controlfile size as viewed at OS level but from
inside Oracle, select cfnam, (cffsz+1)\*cfbsz from x$kcccf. cfbsz is the
controlfile log block size; should report the same as the command
`dbfsize controlfile` (`$ORACLE_HOME/bin/dbfsize` is available on UNIX,
regardless Oracle version.) In 10*g*R2, block size and file size are
both in v$controlfile although [Reference
manual](http://docs.oracle.com/cd/B19306_01/server.102/b14237/dynviews_1068.htm)
misses them.

x$kcccp

kernel cache, controlfile checkpoint progress

[S. Adams](http://www.ixora.com.au/scripts/redo_log.htm#log_file_usage)
and [K
Gopalakrishnan](http://www.jlcomp.demon.co.uk/faq/redologuse.html) use
this view to find how much the current redo log is filled.
[Eygle](http://www.eygle.com/archives/2006/01/why_oracle_heartbeat2.html)
studied instance heartbeat, column cphbt.

x$kccdi

kernel cache, controlfilemanagement database information

 

x$kccle

kernel cache, controlfile logfile entry

lebsz may be used to show redo logfile block size, usually 512; should
report the same as the command `dbfsize redologfile`
(`$ORACLE_HOME/bin/dbfsize` is available on UNIX only)

x$kccnrs,x$kccrsp

kernel cache, controlfile non-guaranteed restorepoint; kernel cache,
controlfile restore point

Base tables of v$restore\_point, for non-guaranteed and guaranteed
restore points. Retain records of them after they were dropped

x$kcfis\*

kernel cache, file intelligent scan

Exadata smart scan related. Note that views for cell servers per se are
x$kxdcm\_\* (kernel Exadata cell module) plus x$cell\_name

x$kclcrst

kernel cache, (RAC) lock, consistent read statistics

base table of v$cr\_block\_server or v$bsp, used to troubleshoot global
cache cr requests

x$kclfh

kernel cache, (RAC) lock file hashtable

 

x$kclfi

kernel cache, (RAC) lock file index

 

x$kclfx

kernel cache, (RAC) lock (element) freelist statistics

See
[Ref1](https://books.google.com/books?id=F4aNiUWUq-4C&pg=PA69&q=X%24KCLFX),
[Ref2](http://www.freelists.org/archives/oracle-l/11-2008/msg00059.html),
[1492990.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=1492990.1).
If lwm is too low, you may see 'gc freelist' wait.

x$kcluh

kernel cache, (RAC) lock undo header

 

x$kclui

kernel cache, (RAC) lock undo index

 

x$kcmscn

kernel cache, maximum SCN

Cur\_scn is the same as v$database.current\_scn. Cur\_max\_scn should be
16384\*seconds since 1988
([1376995.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=1376995.1)).
This view may be related to the SCN headroom problem.

x$kcnt

kernel cache, nologging transaction

19c. Base table of v$nologging\_standby\_txn. Nologging standby is a
feature
[new](https://docs.oracle.com/en/database/oracle/oracle-database/18/newft/new-features.html#GUID-EA49287B-D55F-44F4-A31D-A7AE231C9BB6)
in 18c.

x$kcrfstrand

kernel cache, redo file strand

10*g* and up. Info about redo strands. Non-zero
pvt\_strand\_state\_kcrfa\_cln (and
strand\_num\_ordinal\_kcrfa\_cln=3735928559 or DEADBEEF in hex) means a
transaction is using this private strand. (Private strands may be
disabled in RAC or if supplemental logging is on, but multistrand redo
is still used.) Strand\_size\_kcrfa is the strand size (meaningful only
if last\_buf\_kcrfa\!='00';
[Ref](http://www.hellodba.com/Doc/Oracle_redo_strand_cn.html)). Also see
[18164614](https://support.oracle.com/epmos/faces/ui/km/BugDisplay.jspx?id=18164614),
[Ref](https://jonathanlewis.wordpress.com/2012/09/17/private-redo-2/).

x$kcrfx

kernel cache, redo file context

"columns bfs (buffer size) and bsz (block size). Dividing bfs by bsz
gives mxr (the maximum number of blocks to read size)" (from [Anjo
Kolk's
paper](http://www.akadia.com/download/documents/session_wait_events.pdf))

x$kcrrlns

kernel cache, recovery process LNS

Related to LNS (redo transport) processes, NSSn (sync) and NSAn (async).

x$kd\_column\_statistics

kernel data, column statistics

12*c*R2. Set \_column\_level\_stats to on to get the stats. Exposed to
the undocumented v$column\_statistics.

x$kdxst

kernel data, index status

used in catalog.sql to create index\_stats

x$kdxhs

kernel data, index histogram

Used in catalog.sql to create index\_histogram

x$kewrtb

kernel server (manageability), workload repository tables

See
[Note:555124.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=555124.1)

x$kfdat

kernel file, disk allocation table?

Only populated in ASM instance. See
[Note:351117.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=351117.1)
and Steve Shaw and Julian Dyke [*Pro Oracle Database 10g RAC on
Linux*](http://www.amazon.com/gp/product/B001CSP9ZA/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B001CSP9ZA&linkCode=as2&tag=englstudforch-20&linkId=3NZEMF373WN3IOSM)![](http://ir-na.amazon-adsystem.com/e/ir?t=englstudforch-20&l=as2&o=1&a=B001CSP9ZA),
pp.232-3. Column v\_kfdat is 'V' for allocated and 'F' for free. For
most ASM-related x$ tables, read [Luca
Canali](https://twiki.cern.ch/twiki/bin/view/PSSGroup/ASM_Internals).

x$kffxp

kernel file, file extent map

Only populated in ASM instance. You can check how many extents are
allocated for each datafile on which disk, e.g. select a.name, d.path,
d.group\_number, d.disk\_number, count(\*) from v$asm\_alias a,
v$asm\_disk d, v$asm\_file f, x$kffxp x where a.group\_number =
x.group\_kffxp and a.file\_number = x.number\_kffxp and d.group\_number
= x.group\_kffxp and d.disk\_number = x.disk\_kffxp and f.group\_number
= a.group\_number and f.file\_number = a.file\_number and f.type =
'DATAFILE' group by a.name, d.path, d.group\_number, d.disk\_number,
f.bytes order by 1;

x$kfklib

kernel file, ? library

You can tell from inside ASM instance whether you're using ASMLib and
its version.

x$kghlu

kernel generic, heap LRUs

Some columns are explained
[here](http://www.ixora.com.au/scripts/sql/shared_pool_lru_stats.sql).

x$kglcursor

kernel generic, librarycache cursor

Base table for v$sql, v$sqlarea. Fixed view based on x$kglob according
to x$kqfdt. One use of this table is to find partially parsed SQLs
because they cause parse failures (viewable in v$sysstat or v$sesstat).
Their kglobt02 (command type) is 0, kglobt09 (child number) is 65535 for
the child, SQL text length is cut to 20 chars, kglobt17 and kglobt18
(parsing and user schema) are 0 or 2147483644 (for 32-bit Oracle)
depending on if it's parent or child, and obviously miss heap 6 (cursor
body). Find them by select kglnaobj, kglnatim, kglobts0, kglnahsh from
x$kglcursor where kglobt02 = 0 (kglobts0 is module; you can further
restrict by kglnatim i.e. first\_load\_time).

x$kgllk

kernel generic, librarycache lock

Used in catblock.sql to build dba\_kgllock. kgllkuse or kgllkses maps to
v$session.saddr, kgllkpnc call pin, kgllkpns session pin, kgllkmod lock
held (0: no lock; 1: null; 2: shared; 3: exclusive), kgllkflg (allegedly
8 for pre-10*g* or 2048 for 10*g* meaning SQL being run,
[Ref](http://zhouwf0726.itpub.net/post/9689/243202); 256 for broken kgl
lock in 10*g* or 1 in 9*i*,
[Ref](http://www.freelists.org/post/oracle-l/How-to-determine-sessions-with-invalid-package-states,7)),
kgllkspn savepoint. If you get library cache lock or pin wait, kgllkhdl
matches v$session\_wait.p1raw (handle address), and kglnaobj is the
first 80 characters of the object name.
[Note:122793.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=122793.1)
has this SQL for our convenience: select \* from x$kgllk lock\_a where
kgllkreq = 0 and exists (select lock\_b. kgllkhdl from x$kgllk lock\_b
where kgllkses = '\&saddr\_from\_v$session' /\* blocked session \*/ and
lock\_a.kgllkhdl = lock\_b.kgllkhdl and kgllkreq \> 0). X$kgllk.kglhdpar
matches x$kglob.kglhdpar if there's a KGL lock on the object. Also see
[LibraryCachePinLockHowToFindBlocker.txt](../oranotes/LibraryCachePinLockHowToFindBlocker.txt).
If the blocker is in an instance other than that of the blocked session
in a RAC database, use object name (kglnaobj and first half of
v$session.p3raw) to find the blocker.

x$kglob

kernel generic, librarycache object

To find library cache object for wait events library cache pin or lock
and pipe get or put, match kglhdadr with v$session.p1raw. Kglobt03 is
sql\_id. Kglhdflg is partially explained in
[Note:311689.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=311689.1)
(for permanent keeping). Kglhddmk may be data object load mask; can be
used to identify the number of the loaded heap, counted from 0 (see
comment of 06/12/01 in
[Bug:1164709](https://support.oracle.com/CSP/main/article?cmd=show&type=BUG&id=1164709)).
Steve Adams'
[objects\_on\_hot\_latches.sql](http://www.ixora.com.au/scripts/sql/objects_on_hot_latches.sql)
finds the way Oracle links a library cache object (based on kglnahsh) to
a specific library cache child latch. X$kglob, and in case of cursors
x$kglcursor too, can be used to find library cache objects that are
partially built therefore not visible in v$sql(XXX), v$open\_cursor,
v$object\_dependency. Kglobhd\[0-7\] is heap descriptor address and
kglobhs\[0-7\] is its size; can join to x$ksmhp.ksmchds to see heap
components.

x$kglpn

kernel generic, librarycache pin

Used in catblock.sql to build dba\_kgllock. Some columns are simiarly
explained for x$kgllk. Newer versions of Oracle use mutex in place of
pin and this table won't have an entry for it although x$kglob.kglhdpmd
will still have a non-zero value.

x$kglrd

kernel generic, librarycache readonly dependency

kglnacnm (container name?) is PL/SQL program unit or anonymous block
while kglnadnm (dependent name?) is the individual SQLs inside the
PL/SQL unit. [Ref](http://www.ixora.com.au/q+a/0110/31164749.htm); this
may be the way to differentiate between user recursive SQLs (code in
PL/SQL, trigger, etc.) from system-generated recursive SQLs (data
dictionary check etc.). (See also v$object\_dependency, but that doesn't
show relation between PL/SQL block and its contents.) In 11*g*,
v$sql.program\_id may be used to tie the constituent SQL to its
containing PL/SQL stored object (not anonymous block).

x$kglst

kernel generic, librarycache statistics

Base table of v$librarycache. Unexposed column kglstidn can be used as
namespace in dbms\_shared\_pool.purge. ([Ref](SharedPoolPurging.html))

x$kgltr

kernel generic, librarycache translation

Maps synonym translation from original (kgltrorg) to final (kgltrfnl)
address, All 3 address columns map to x$kglob.kglhdadr.
[Example](../oranotes/SynonymTranslationInCursor.html).

x$kgskvft

kernel generic, service, ?(resource manager) ? fixed table

Base table of v$blocking\_quiesce. If the blocking session is not in
SYS\_GROUP consumer group according to v$rsrc\_session\_info,
v$blocking\_quiesce ignores it. Workaround is to directly query
x$kgskvft. ([Ref](http://www.itpub.net/thread-1046171-1-1.html);
[Bug 7832504](https://support.oracle.com/CSP/main/article?cmd=show&type=BUG&id=7832504))

x$kjxm

kernel RAC cross-instance messaging

Stats about messages sent and received on RAC instances (not about data
buffers which would be in x$kclcrst i.e. v$cr\_block\_server a.k.a
v$bsp). The kjxmname column is interesting as well as the stats.

x$kjznhangs,x$kjznhangses

kernel RAC diag node hang session

Base tables of v$hang\_info and v$hang\_session\_info so column names
can be deciphered. Retain info after the hang.

x$kkspcib

kernel compilation shared (cursor) parse cursor ??

New in 12.1.0.2. Cursor to session mapping, after v$open\_cursor no
longer has this info? KKSCSPHD: parent addr, KKSCSHDL: child addr

x$kmgsct

kernel memory, sga space ??

Base table of v$sga\_dynamic\_components, v$sga\_current\_resize\_ops
etc., probably used to be named x$ksmgst and x$ksmgsc in 9*i*.

x$kmgstfr

kernel memory, sga space transfer ??

Maybe another way of representing SGA and memory components resizing
operations. Ts: time; startaddr and end: addresses before and after
resizing; donor and receiver: x$kmgsct.grantype

x$knstmvr

kernel replication, statistics materialized view refresh

Base table of v$mvrefresh. Stores MV refresh history info, such as
session SID and serial\#. Un-exposed columns reftype\_knstmvr,
groupstate\_knstmvr and total\_\* are useful; see the query in
[Note:258021.1](https://supporthtml.oracle.com/ep/faces/secure/km/DocumentDisplay.jspx?id=258021.1).

x$kpoxft

kernel programmatic oracle, ? fixed table

19c. Column kpoxftcldrv shows client driver and library versions and
character sets for the clients that recently logged onto the server. In
case of RAC, this info is instance-specific.

x$kqdpg

kernel query, dictionary PGA

Row cache cursor statistics, columns explained in "How can you tune it?"
section of [Tuning the \_row\_cache\_cursors
Parameter](http://www.ixora.com.au/tips/tuning/row_cache_cursors.htm).
Note this is PGA. Need to dump another process's PGA to view it.

x$kqfco

kernel query, fixed table columns

One use is to find all fixed tables given a column name, e.g. select
kqftanam, kqfconam, kqfcoidx from x$kqfco c, x$kqfta t where
t.indx=c.kqfcotab and kqfconam='KGLHDADR', or like part of the column
name. If kqfcoidx is 0, the column is not indexed.

x$kqfdt

kernel query, fixed derived table

Contains x$kglcursor, x$kgltable etc. which are based on x$kglob;
effectively these are views of other x$ tables, but Oracle couldn't call
them views because they already had x$kqfvi.

x$kqfp

kernel query, fixed package

Used in catprc.sql to build disk\_and\_fixed\_objects view. Each object
has two rows, one package and one package body.

x$kqfsz

kernel query, fixed size (size of fixed objects in current version of
Oracle)

 

x$kqfta

kernel query, fixed table

Base table of v$fixed\_table, whose object\_id (indx of x$kqfta) matches
obj\# of tab\_stats$, the table
dbms\_stats.gather\_fixed\_objects\_stats inserts stats into.

x$kqfvi

kernel query, fixed view

 

x$kqlfsqce

kernel query, librarycache fixedtable sql cursor environment

Base table of v$sql\_optimizer\_env. One use is to find all parameters
including underscore ones in the environment of a SQL cursor by not
restricting on column kqlfsqce\_flags as v$sql\_optimizer\_env does.

x$kqrpd

kernel query, rowcache parent definition

Column kqrpdosz is size of this parent rowcache object, not exposed in
v$rowcache\_parent although shown in rowcache dump.

x$kqrsd

kernel query, rowcache subordinate definition

Column kqrsdosz is size of this subordinate rowcache object, not exposed
in v$rowcache\_subordinate although shown in rowcache dump.

x$krbmsft

kernel recovery backuprecovery, miscellaneous search file ?

Commonly used with dbms\_backup\_restore.searchfiles to read the file
list of a directory at OS.
[Ref](http://www.morganslibrary.org/hci/hci002.html)

x$krcfh,x$krcfde,x$krcfbh,x$krcbit

kernel recovery, changetracking file, header, descriptor, bitmap header,
bitmap block

[Alex Gorbachev](http://www.pythian.com/documents/UKOUG06-10gBCT.ppt)

x$krcstat

kernel recovery, changetracking statistics

Value `dba_buffer_count_public*dba_entry_count_public*dba_entry_size` is
the memory that is currently allocated to the change tracking buffers.
(Ref:
[2160776.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=2160776.1))

x$ksbdd

kernel service, background detached (process) definition

Base table of v$bgprocess. Column ksbddfile in 12*c* associates the
process with a header file, which hints at the kernel layer. But you may
wish to see the actual internal names for the processes, in
[10.2.0.1](http://www.juliandyke.com/Internals/BackgroundProcesses.html)
and
[11.2.0.1](http://www.arontunzi.com/cms/index.php?option=com_content&view=article&id=61),
which are more detailed and available in earlier versions as well.

x$ksbsrvdt

kernel service, background server detached (process)

Probably background process slaves.

x$ksbtabact

kernel service, background ? action

Actions performed by certain background processes and their timeout
values

x$ksbucpuwtm

kernel service, background ? CPU wait time

18c. In root container. Background process CPU wait time.

x$ksfdstll

kernel service, file disk (I/O) statistics, ? outlier

Base table of v$io\_outlier (for all I/O's except for LGWR) and
v$lgwrio\_outlier (for LGWR I/O). Timestamp, not exposed, is seconds
since epoch.

x$ksimsi

kernel service, instance management serial (and) instance (numbers)

Base table of v$active\_instances. The un-exposed ksimisum column is
instance incarnation number, matching "Reconfiguration started ... new
inc ..." in alert.log.

x$ksipc\_info and x$ksipc\_proc\_stats

kernel service IPC info and process stats

These two 12*c* tables don't exist although v$fixed\_table has their
names. They probably would contain stats for the new IPC0 background
process. Also related to the new \_ksipc\* parameters.

x$ksi\_reuse\_stats

kernel service, instance, reuse stats

12*c* only. Not sure why it's called this name. Apparently it's about
enqueue resources. The name column is a wondeful alternative brief
description for each enqueue or lock, compared with
v$lock\_type.description: select a.type, a.description, b.name from
v$lock\_type a, x$ksi\_reuse\_stats b where a.type = b.resname order by
1

x$ksled,x$kslei,x$ksles

kernel service, lock, event descriptors, events for instance, events for
session

Base tables for v$event\_name, v$system\_event, and v$session\_event,
respectively. Benefit of querying x$ksles: (1) When ksleswts (wait
count) is 0, v$session\_event won't have the row but x$ksles still has
them with non-zero kslestim (time waited micro) or kslesmxt (max wait
time in micro); (2) Since kslesmxt is in microsec, it could be non-zero
even if v$session\_event.max\_wait is 0. x$kslei has benefit (2) over
v$system\_event. In 12*c*, the new column ksleddsp of x$ksled provides a
better event name, such as "db single block read" for the perpetually
confusing "db file sequential read": select kslednam, ksleddsp from
x$ksled where kslednam \!= ksleddsp

x$kslemap

kernel service, lock, event map

"Indx = event number...Basically map events to a small number of useful
classes like I/O waits"
([Ref](http://oracleweb.ioug.org/portals/0/whitepapers/look-towaitornottowait.pdf))

x$kslhot

kernel service, lock, hot (blocks)

Set \_db\_hot\_block\_tracking to true and track hot blocks in buffer
cache. It's an alternative and probably better way than checking touch
count.
([Ref](http://ksun-oracle.blogspot.com/2014/03/hot-block-identification.html))

x$ksllclass

kernel service, lock,, latch class

"describes the 8 classes", "Specify which latch belongs to which class"
with \_latch\_class\_
([Ref](http://www.ioug.org/techrepository_2/view_file.cfm?ViewFileID=3031))

x$kslltr\_osp,x$kslwsc\_osp

kernel service, lock,, latch ?

Records a few latches "missing" from v$latch\* views, such as "DGA
(domain global area) heap latch".

x$ksllw

kernel service, lock, latch where

Base table of v$latch\_misses. But column ksllwlbl is not exposed in any
view. It's said to record "the 'Why' meaning for some 'Where'"
([Ref](https://andreynikolaev.files.wordpress.com/2012/12/andrey_nikolaev_latch_internals_2012_for_ruoug.pdf))
or "Unit to guard"
([Ref](http://www.vmcd.org/2012/06/oracle-latch-internals/)).

x$kslpo

kernel service, latch
posting

[Bug:653299](https://support.oracle.com/CSP/main/article?cmd=show&type=BUG&id=653299)
says it "tracks which function is posting smon". Ksllwnam column (the
part before semicolon if it exists) can match v$latch\_misses.location
to identify the latch that uses this function. Column ksllwlbl is
explained in the entry for x$ksllw.

x$kslsesout

kernel service,

12*c*R2. Base table of undocumented v$event\_outliers.

x$ksmdd

kernel service, memory segmented (array) definition

[Ref](http://www.juliandyke.com/Presentations/SGAInternals.ppt)

x$ksmfs

kernel service, memory fixed SGA

One of the base tables of v$sgastat. Shows sizes of fixed SGA, buffer
cache, log buffer, shared I/O pool (for SecureFile LOBs), and in 12*c*,
data transfer cache. Even though some of these can be dynamically
resized in modern versions of Oracle, any component in shared memory not
in some kind of pool (v$sgastat where pool is null) is left in this
"fixed" SGA table.

x$ksmfsv

kernel service, memory fixed SGA variables

detailing fixed SGA: select a.ksmfsnam, a.ksmfstyp, a.ksmfssiz,
b.ksmmmval from x$ksmfsv a, x$ksmmem b where a.ksmfsadr = b.addr and
a.ksmfsnam like... (Ref. p.82, [Oracle Internal
Services](http://www.oreilly.com/catalog/orinternals/)). For a latch,
get ksmfsnam by matching x$ksmfsv.ksmfadr with x$kslld.kslldadr. You can
see SGA parameters in ksmfsnam column and get their values with oradebug
dumpvar sga *varname* or all values with oradebug dumpsga. In 12.1.0.2,
to find which database parameter (as in v$parameter and x$ksppi) roughly
[maps](../oranotes/DbParam_CompTimeConst_Map.txt) to which SGA variable,
read the "Dump of Compile-Time Constants" section "Namespace
ksppar\_const\_ns" of the trace file (note indx is off by 1).

x$ksmhp

kernel service, memory heap

[S. Adams](http://orafaq.com/maillist/oracle-l/2000/08/01/0344.htm),
"What it returns depends on which heap descriptor you join to it. It is
effectively a function returning the contents of an arbitrary heap that
takes the heap descriptor as its argument." You need to join this table
to another one on heap descriptor ksmchds, such as in
v$sql\_shared\_memory (joining to x$kglcursor), or to x$ksmsp (on column
ksmchpar), or kglobhd\[0-6\] of x$kglob or x$kglcursor\_child, and
possibly need to use use\_nl hint.
[Example](http://www.sql.ru/forum/actualthread.aspx?bid=3&tid=572522),
[example](http://files.e2sn.com/scripts/tpt_public_win.zip).

x$ksmjch,x$ksmjs

kernel service, memory, java chunks, java (pool) statistics

X$ksmjch shows each chunk of java pool except for free area. (Nor
interesting to me though)

x$ksmlru

kernel service, memory LRU

Refer to Metalink Notes
[61623.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=61623.1)
and
[43600.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=43600.1)
for details. Note that query on this table can only be done once;
subsequent query returns no rows unless large chunk shared pool
allocations happened in the interim.

x$ksmls

kernel service, memory large (pool) statistics

 

x$ksmmem

kernel service, memory

Entire SGA memory map. Each row shows memory content for 8 bytes (on
64-bit Oracle). Due to memory guard pages, you can only select from
x$ksmmem specifying a specific indx or addr (addr=hextoraw('...')), or
by joining to another table on addr column; otherwise the session may
hang or throws ORA-3113 (Windows doesn't seem to have this problem). One
usage is to find the value for an SGA variable, e.g. select ksmmmval
from x$ksmfsv a, x$ksmmem b where a.ksmfsadr=b.addr and
ksmfsnam='kzaflg\_' to see if audit is enabled (what kzaflg\_ means),
which is equivalent to oradebug peek command, or for this particular
purpose, even more simply, oradebug dumpvar sga kzaflg\_.  
Indx is SGA index, i.e. the difference of SGA address and sgabeg (which
is x$ksmmem.addr where indx = 0) divided by architecture word size (4
for 32-bit, 8 for 64-bit machines). E.g., the value stored at address
0000000060001F40 on a 64-bit machine whose sgabeg is 0x60000000 can be
calculated as:  
select (to\_number('0000000060001F40','xxxxxxxx') -
to\_number('60000000','xxxxxxxx')) /8 from dual;  
select ksmmmval from x$ksmmem where indx = 1000;

x$ksmns

kernel service, memory numa (pool) statistics

 

x$ksmpgdst

kernel service, memory PGA detailed statistics

Base table of v$process\_memory\_detail, populated by alter session set
events 'immediate trace name pga\_detail\_get level *pid* and cleaned by
...pga\_detail\_cancel....

x$ksmpp

kernel service, memory pga heap

PGA heap (variable area). PGA subheaps: select /\*+use\_nl(h,p)\*/
h.ksmchds,p.ksmchcom, h.ksmchcom ksmchnam,h.ksmchsiz,
h.ksmchcls,h.ksmchpar from x$ksmhp h,x$ksmpp p where h.ksmchds =
p.ksmchpar and p.ksmchcls like '%recr' and p.ksmchpar \!=
hextoraw('00');

x$ksmsgmap

kernel service, memory SGA map

12*c*R2. Shows the beginning and ending addresses and sizes of fixed and
variable areas of SGA.

x$ksmsp

kernel service, memory sga heap

The 3rd argument of ORA-4031 tells you which section of shared (or java
or large) pool is short of memory. It matches x$ksmsp.ksmchcom (or
v$sgastat.name). SGA heaps: select /\*+use\_nl(h,s)\*/ sess.sid,
sess.username, h.ksmchds, h.ksmchcom ksmchnam, h.ksmchsiz,
h.ksmchcls,h.ksmchpar from x$ksmhp h,x$ksmsp s,v$session sess where
h.ksmchds = s.ksmchpar and s.ksmchcls like '%recr' and s.ksmchpar \!=
hextoraw('00') and h.ksmchown = sess.saddr; SGA subheaps: select
/\*+use\_nl(h,s)\*/ h.ksmchds,s.ksmchcom,h.ksmchcom ksmchnam,
h.ksmchsiz,h.ksmchcls,h.ksmchpar from x$ksmhp h,x$ksmsp s where
h.ksmchds = s.ksmchpar and s.ksmchcls like '%recr'and s.ksmchpar \!=
hextoraw('00'); You can sort on ksmchptr to get a map of memory pieces.
In ksmchcom, the hex number after SQLA^ is the SQL hash value.

x$ksmspr

kernel service, memory shared pool reserved

 

x$ksmsp\_dsnew

kernel service, memory shared pool, ? statistics new

One row summarizes subpools and
[durations](https://support.oracle.com/CSP/main/article?cmd=show&type=BUG&id=14311437).
Dscnt\_kghdsnew is subpool count (distinct dsidx\_ksmnwex in
x$ksmsp\_nwex). Cursiz\_kghdsnew is total duration count (row count of
x$ksmsp\_nwex).

x$ksmsp\_nwex

kernel service, memory shared pool ?

A new efficient fixed table shows subpools and
[durations](https://support.oracle.com/CSP/main/article?cmd=show&type=BUG&id=14311437).
See
[396940.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=396940.1).

x$ksmss

kernel service, memory sga statistics

The 3rd argument of ORA-4031 tells you which section of shared (or java
or large) pool is short of memory. It matches x$ksmss.ksmssnam (or
v$sgastat.name).

x$ksmsst,x$ksmstrs

kernel service, memory, sga streams (pool), streams (pool) statistics

 

x$ksmssinfo

kernel service, memory sga OS (level) info

This 12*c* table shows how OS level shared memory segments are used
(which segment is used by what component of SGA), in effect matching the
rows of \`ipcs -m' with those of v$sga. It also tells you whether and
which segments are using HugePages, so you don't have to check
/proc/*pid*/smaps to see that and is of course more detailed than just
seeing the brief message in alert.log. See
[more](HugePagesQuickTips.html).

x$ksmup

kernel service, memory uga heap

UGA heap (variable area). UGA subheaps: select /\*+use\_nl(h,s)\*/
h.ksmchds,u.ksmchcom,h.ksmchcom
ksmchnam,h.ksmchsiz,h.ksmchcls,h.ksmchpar from x$ksmhp h,x$ksmup u where
h.ksmchds = u.ksmchpar and u.ksmchcls like '%recr' and u.ksmchpar \!=
hextoraw('00');

x$ksolsfts

kernel service, object level statistics, fts?

Base table of v$segstat and v$segment\_statistics. Fts\_stmp records the
last time fts\_staval was updated, fts\_preval the previously recorded
value. Fts\_inte greater than 0 reveals some less known types of
statistics. Note that value in v$segstat or v$segment\_statistics is
cumulative; e.g., if "row lock waits" is non-zero, the waits may not be
happening right now.

x$ksppcv

kernel service, parameter, current (session) value

Base table of v$parameter and v$parameter2. See comments on x$ksppi.

x$ksppi

kernel service, parameter, parameter info

Base table of v$parameter, v$system\_parameter and v$system\_parameter2.
Often used to see undocumented parameters: select a.ksppinm Parameter,
a.ksppdesc Description, b.ksppstvl "Session Value", c.ksppstvl "Instance
Value" from x$ksppi a, x$ksppcv b, x$ksppsv c where a.indx = b.indx and
a.indx = c.indx and a.ksppinm like '\\\_%' escape '\\' order by 1. You
can also see if a specific parameter, underscore or not, is dynamically
changeable etc.: select ksppinm name, ksppity "TYPE", ksppstvl value,
ksppstdvl display\_value, ksppstdf isdefault,
decode(bitand(ksppiflg/256,1),1,'TRUE','FALSE') isses\_modifiable,
decode(bitand(ksppiflg/65536,3),1,'IMMEDIATE',2,'DEFERRED',
3,'IMMEDIATE','FALSE') issys\_modifiable,
decode(bitand(ksppiflg,4),4,'FALSE', decode(bitand(ksppiflg/65536,3), 0,
'FALSE', 'TRUE')) isinstance\_modifiable ,
decode(bitand(ksppstvf,7),1,'MODIFIED',4,'SYSTEM\_MOD','FALSE')
ismodified, decode(bitand(ksppstvf,2),2,'TRUE','FALSE') isadjusted,
decode(bitand(ksppilrmflg/64, 1), 1, 'TRUE', 'FALSE') isdeprecated,
decode(bitand(ksppilrmflg/268435456, 1), 1, 'TRUE', 'FALSE') isbasic,
ksppdesc description, ksppstcmnt update\_comment from x$ksppi x,
x$ksppcv y where x.indx=y.indx and ksppinm = '\&param'; Column ksppiflg
has 30 bits in 11*g* and 32 bits in 12*c*R2, most of which are
unexposed. But for a static parameter, whether it's
[instance-modifiable](../oranotes/StaticInstanceNonmodifiableParameters.txt)
is not one of them. It would be very useful to have this bit.

x$ksppsv

kernel service, parameter, system value

Base table of v$system\_parameter and v$system\_parameter2. See comments
on x$ksppi.

x$ksprstv

kernel service, parameter, reset value

12*c*R2. Base table of undocumented v$system\_reset\_parameter and
v$system\_reset\_parameter2. Shows the value of a parameter if you run
`alter system reset` to clear it from spfile. Also see comments on
x$ksppi.

x$kspspfh

kernel service, parameter spfile header

Column kspspfhmodtime stores the time when you made the last change to
the spfile. Use [Note 1](#time) to convert it to time but set epoch to
19870630. I don't know what's special about that time.

x$ksrcctx,x$ksrcdes

kernel service, (intra-instance) broadcast, channel context, channel
description

Base tables of the undocumented v$channel\_waits, which is used to find
the big contributors to "reliable message" wait event. You can find the
last message publishing time by select a.name\_ksrcdes,
b.totpub\_ksrcctx, b.waitcount\_ksrcctx, b.waittime\_ksrcctx,
new\_time(to\_date(to\_char(lastpub\_ksrcctx/86400+to\_date('19700101','yyyymmdd'),'yyyymmdd
hh24:mi:ss'),'yyyymmdd hh24:mi:ss'), 'GMT', 'CDT') from x$ksrcdes a,
x$ksrcctx b where b.name\_ksrcctx=a.indx and b.waitcount\_ksrcctx\>0.
Column id\_ksrcdes of x$ksrcdes provides alternative keywords you can
use to search for.

x$ksrchdl

kernel service, (intra-instance) broadcast, channel ?

Column ctxp\_ksrchdl matches p1 of 'reliable message' (context) and
owner\_ksrchdl matches ksspaown of x$ksuse (base table of v$session).
Last message time is lastmsg\_ksrchdl seconds since epoch ([Note
1](#time)).

x$kstex

kernel service, trace execution

Base table of v$execution, a table documented poorly and probably wrong
for a long time. The
[definition](http://oracledba.ru/fv11gr2/gv$execution.html) in
v$fixed\_view\_definition probably should restrict on id instead of op
(where id=10), official
[documentation](http://docs.oracle.com/database/121/REFRN/refrn30080.htm)
should call FUNCTION function, PID pid (as v$process.pid), and the view
should expose sid as session ID. This table together with x$trace
provides info about KST trace. Unfortunately it seems to have stopped
working in 11*g* and up.

x$ksugblnetstat,x$ksugblnetstatawr

kernel service, user, global network stats (AWR)

19c. Some TCP parameter settings and statistics.

x$ksulop

kernel service, user long operation

Base table of v$session\_longops. Column ksulotgt, probably for total
gets?, is not exposed.

x$ksulv

kernel service, user locale value

Base table of v$nls\_valid\_values.

x$ksupgp,x$ksupgs

kernel service, user, process group, process group sniped

X$ksupgp.ksupgpnm\!='DEFAULT' may suggest session leaking
([Ref](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=403995.1)).
X$ksupgs is the base table of undocumented
[v$detached\_session](https://support.oracle.com/epmos/faces/DocumentDisplay?id=387077.1)
showing sessions killed (without immediate option) but not cleaned.

x$ksupl,x$ksuru

kernel service, user, process (resource) limit, resource usage

X$ksupl.ksuplstn=x$ksuru.ksurind. Ksuplres is the limit and ksuruse is
the current usage. Not sure what resource (or kernel profile) exactly.
([Ref](http://oracledoug.com/serendipity/index.php?/search/redo/P6.html))

x$ksuprlat

kernel service, user process latch

Base table of v$latchholder. Unexposed columns are ksuprllv (level),
ksuprlty (type), ksuprlmd (mode), ksulawhy (why or reason), and ksulawhr
(where or location).

x$ksuse

kernel service, user session

Base table of v$session. To\_char(ksuseflg,'xxxxxxxx') can be checked
against session state object
[flag](http://www.askmaclean.com/archives/tag/dump). In fact, this
applies to all tables with this column, i.e. x$ksuse, x$ksusesta,
x$ksumysta, x$ksusio, x$ksusecst, x$ksusecon, x$kewssesv. Common bits
are x1 (user session), x2 (recursive session), x4 (audit logon/logoff by
cleanup), x40 (user session logs on), x10 (user session created by
system processes), x8000000 (called NLS alter session). You can e.g. use
it to
[find](http://tech.e2sn.com/oracle/oracle-internals-and-architecture/recursive-sessions-and-ora-00018-maximum-number-of-sessions-exceeded)
hidden recursive sessions.

x$ksusecon

kernel service, user session connection

In 11*g*, check client version with

    with x as (select distinct to_char(ksuseclvsn,'xxxxxxx') v
     from x$ksusecon where ksusenum = &sid)
    select decode(v, '       0', 'no version provided: 10g or lower, or background process?',
     to_number(substr(v,1,2),'xx') || '.' || --maj_rel
     to_number(substr(v,3,1),'x') || '.' || --mnt_rel
     to_number(substr(v,4,2),'xx') || '.' || --ias_rel
     to_number(substr(v,6,1),'x') || '.' || --pat_set
     to_number(substr(v,7,2),'xx')) client_version -- port_mnt
    from x;

([Ref](http://www.freelists.org/post/oracle-l/SQLPlus-version-tracking,9))  
Not needed in 12*c* because v$session\_connect\_info.client\_version
works fine.

x$ksusm

kernel service, user session migration

Base table of undocumented v$tsm\_sessions and v$sscr\_sessions. Related
to migratable sessions, sessions with OCI\_MIGRATE set during creation.

x$ksuvmstat

kernel service, user virtual memory statistics

In 10*g* and up, base table providing physical\_memory\_bytes to
v$osstat (and VM paging stats on Windows). But on Linux up to Oracle
10.2.0.3, this number is system free memory in kilobytes (`grep MemFree
/proc/meminfo`); on other OSes or 10.2.0.4 or up on Linux, it is "Total
number of bytes of physical memory".

x$kswsastab

kernel service, workgroup services, service table

Base table of v$services and a few other service-related views.
v$services may need x$kswsastab.kswsastabpflg=0 restriction; otherwise
stopped services linger in the view till instance bounce.

x$ksxafa

kernel service, execution, (parallel) affinity ?

Shows datafile - node (host) affinity. To test, make sure \_affinity\_on
is true (default), set \_enable\_default\_affinity to a number and
bounce instance. Ksxafnum is file\# in v$datafile or v$tempfile plus
db\_files. Not sure how to test though. Probably limited use with modern
storage technology.

x$ksxm\_dft

kernel service, execution, modification dml frequency tracking

Base table of undocumented v$object\_dml\_frequencies. Set
\_dml\_frequency\_tracking to true to see data.

x$ksxmme

kernel service, execution, modification dml ?

12*c*R2. Base table of undocumented v$dml\_stats. Counts recent DML
operations independent of commit or rollback. Controlled by
\_dml\_monitoring\_enabled. Lastused is seconds from epoch ([Note
1](#time)).

x$ksxpclient

kernel service, ipc, client

On RAC, shows IPC client stats, cache for global cache (cache fusion
traffic), dlm for distributed lock manager (GCS+GES), etc. Source for
[dba\_hist\_ic\_client\_stats](http://docs.oracle.com/database/121/REFRN/refrn23721.htm).
([Ref](https://books.google.com/books?id=5bp5AAAAQBAJ&pg=PA361))

x$ksxpif

kernel service, ipc, interface

On RAC, lists all network interfaces and their stats. The same info as
given by \`ifconfig' or \`ip -s link' except for hardware addresses. But
one nice feature of this table is that the stats for virtual interfaces
(e.g. eth*X*:*X* actually used by Oracle RAC) are separated out of those
of their physical ones.

x$ksxpping

kernel service, ipc, ping

For RAC. Base table of 12*c* v$instance\_ping. Can be used before 12*c*.

x$ksxp\_stats

kernel service, ipc, stats

On RAC, IPC stats for each server process. Same info as in the
\`oradebug ipc' trace but less detailed (to compare, set pid to a
specific process before dump). It shows summary stats for the five
queues, IPC regions, bids prepared, etc.

x$ktcn\*

kernel transaction, change notification \*

all related to database change notification

x$ktcxb

kernel transaction, control, transaction object

Base table of v$transaction. Four bits of ktcxbflg column, exposed as
v$transaction.flag, are
[explained](http://oracledba.ru/fv11gr2/gv$transaction.html) in
v$fixed\_view\_definition. Since v$transaction is empty without a
transaction, you can directly query x$ktcxb to find sessions with
certain attributes, e.g. serializable isolation level: select \* from
v$session where taddr in (select ktcxbxba from x$ktcxb where
bitand(ktcxbflg,268435456)\!=0). Other bits of ktcxbflg not shown in
v$fixed\_view\_definition are: bit 1 read write and read committed, 4(?)
read only, 13 using private strand
([Ref](http://www.hellodba.com/Doc/Oracle_redo_strand_cn.html)), and
there's
[one](http://www.orafaq.com/usenet/comp.databases.oracle.server/2004/06/02/0151.htm)
for distributed transaction. Experiment to find more. Inside Oracle,
symbolic names such as KTCXBALC, KTCXBTRN, KTCXBINV, KTCXBCMT, KTCXBROL
represent them.

x$ktfbfe

kernel tablespace, file bitmap free extent

Free extent bitmap in file header for LMT (equivalent to fet$ in DMT).
Check dba\_free\_space view definition
([Ref](http://www.freelists.org/post/oracle-l/What-is-sysxktfbhcktfbhcsz-and-sysxktfbfektfbfeblks,1)).

x$ktfbhc

kernel tablespace, file bitmap header control

Summarizes free space with one row per datafile. Check dba\_data\_files
or dba\_temp\_files view definition

x$ktfbnstat

kernel tablespace, file bigfile ? stat

In 12*c*. Base table of undocumented v$bts\_stat. Stats populated for
bigfile tablespaces.

x$ktfbue

kernel tablespace, file bitmap used extent

Used extent bitmap in file header for LMT (equivalent to uet$ in DMT)

x$ktifb,x$ktiff,x$ktifp,x$ktifv

kernel transaction, in-memory flush, ?

Related to in-memory undo flushing. X$ktifp shows IMU pools and x$ktiff
shows the events (functions) that trigger IMU flushing and the counts.
([Ref](https://oracleadmins.wordpress.com/2008/08/30/a-new-learning-imu-private-redo-strand/))

x$ktprhist

kernel transaction, parallel (transaction) recovery history

Retains history for some time after a parallel transaction rollback.
Columns usn, slt and seq are what were in v$transaction. Columns stime
and etime can be converted ([Note 1](#time)). See also the documented
views v$fast\_start\_transactions, v$fast\_start\_servers.

x$ktrso

kernel transaction, resumable session ?

Base table of v$resumable, gv$\_resumable2 (which has objid i.e.
tablespace$.ts\#, and type). The only unexposed columns are kssobflg and
kssobown (which is v$session.saddr).

x$ktsimapool

kernel transaction, ? in-memory pool

In 12*c*R2. In-memory pools. Since the sizes (length column) are larger
than alloc\_bytes of v$inmemory\_area (or x$ktsimau), maybe an IM area
is an allocated part of IM pool. Pool \!= area.

x$ktsj\*

kernel transaction, space job(?)

New in 12.1.0.2. Related to space pre-allocation (controlled by
\_enable\_space\_preallocation). Event 60051.

x$ktskstat

kernel transaction/tablespace, segment shrink statistics

Stats for alter table shrink space. Begin and end times are seconds from
epoch ([Note 1](#time)).

x$ktslchunk

kernel transaction/tablespace, space LOB chunk

Probably records transactions on LOB columns. FSB is LOB Free Space
Block, HBB Hash Bucket Block, etc.

x$ktspstat

kernel tablespace, space statistics

Records some ASSM tablespace space management stats. Column ktspstatfsf
"records how many times L1-BMBs are selected then rejected because they
are owned by a different instance"
([Bug 407495](https://support.oracle.com/epmos/faces/ui/km/BugDisplay.jspx?id=4074953%20))

x$ktsso

kernel transaction, sort segment

Base table of v$sort\_usage (or v$tempseg\_usage). From 11.2.0.2,
ktssosqlid provides SQL ID for the SQL associated with this temp segment
usage, not exposed in the v$ views until 12.1.0.2. See
[Bug 17834663](https://support.oracle.com/epmos/faces/ui/km/BugDisplay.jspx?id=17834663)
and
[description](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=17834663.8).

x$ktugd

kernel transaction, undo global data

 

x$ktumascn

kernel transaction, undo minimum active SCN

Used on Exadata only.
[Ref](https://books.google.com/books?id=Mll4CgAAQBAJ&pg=PA392&lpg=PA392&dq=x$ktumascn).

x$ktuqqry

kernel transaction, undo ? query

Base table of flashback\_transaction\_query.

x$kturhist

kernel transaction, undo recovery history

Base table of v$fast\_start\_transactions. The unexposed dtime column
stores the transaction recovery time as seconds since epoch ([Note
1](#time)).

x$ktusmst

kernel transaction, undo system managed, statistics

Base table of v$undostat. Unexposed column ktusmstrqsid may be recursive
SQL ID. It's not always equal to ktusmstrmqi (maxqueryid or "the longest
running SQL statement in the period".

x$ktuxe

kernel transaction, undo transaction entry

"get the SCN of the most recently committed (local) transaction" with
select max(ktuxescnw \* power(2, 32) + ktuxescnb) from x$ktuxe
([Ref](http://www.ixora.com.au/q+a/0009/20125947.htm)); select \* from
x$ktuxe where ktuxecfl = 'DEAD' and ktuxesta = 'ACTIVE' "shows
transaction dead waiting for cleanup"
([1561125](https://support.oracle.com/CSP/main/article?cmd=show&type=BUG&id=1561125))

x$kvii,x$kvit

kernel (performance) view, instance, initialization, transitory
(parameters)

Various database and instance parameters related to buffer cache working
mechanisms, CPUs, etc. In pre-10*g*, there's also x$kvis for sizes of
internal structures.

x$kwqbpmt

kernel OLTP queue ?

Streams memory percentage used (frused\_kwqbpmt),
\_buffered\_publisher\_flow\_control\_threshold (flbp\_kwqbpmt, default
5000), \_capture\_publisher\_flow\_control\_threshold (flcp\_kwqbpmt,
default 15000).

x$kxdbio\_stats,x$kxdcm\*, x$kxdrs

kernel Exadata, block (level) intelligent operations stats, callback for
metrics, resilvering

Some are 12*c*R2 only. Exadata only. See `oradebug doc component`
([Ref](http://tech.e2sn.com/oracle/troubleshooting/oradebug-doc)).

x$kxfbbox

kernel execution, fast (parallel process) black box

12*c*. Base table of undocumented v$px\_process\_trace.

x$kxfpbs

kernel execution, fast (parallel) process batch size

Settings related to parallel processes, e.g. whether to use large pool
(true if using ASMM, parallel\_automatic\_tuning is true, or
\_PX\_use\_large\_pool is true), \_parallel\_min\_message\_pool, etc.

x$kxfpcds,x$kxfpcms, x$kxfpcst

kernel execution, fast (parallel) process, coordinator, dequeue stats,
message stats, (query) stats

Coordinator stats. See below for slave stats.

x$kxfpinstload

kernel execution, fast (parallel) process instance load

Trace file after setting \_px\_trace has the same info, and is more
complete. See notes
[444164.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=444164.1),
[1508338.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=1508338.1),
[1630039.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=1630039.1).

x$kxfpsds,x$kxfpsms, x$kxfpsst

kernel execution, fast (parallel) process, slave, dequeue stats, message
stats, (query) stats

Current list of reasons for parallel execution slave and stats. For
dequeuing, see wait event "parallel query dequeue wait" in [Anjo Kolk's
paper](http://www.akadia.com/download/documents/session_wait_events.pdf).
X$kxfpsst is the base table of v$pq\_sesstat.

x$kxsbd

kernel execution, SQL bind data

Base table of v$sql\_bind\_data. Column kxsbdof2 (or shared\_flag2 of
v$sql\_bind\_data) is oacfl2 (not oacflg2 as in
[Note:39817.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=39817.1))
in SQL trace. "System-generated binds have a value of 256 in the
SHARED\_FLAG2 column". According to
[Bug 4359367](https://support.oracle.com/CSP/main/article?cmd=show&type=BUG&id=4359367),
when it's 0x300, the bind variable is marked as unsafe (affecting
cursor\_sharing=similar).
[Note:296377.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=296377.1)
has more on its value.

x$kxttstecs,x$kxttstehs,x$kxttsteis,x$kxttstets

kernel execution, temporary table stats, column stats, histograms, index
stats, table stats

12*c*. Gather stats for a global temporary table and you'll see stats in
here (not in dba\_tables, dba\_indexes etc).

x$kywm\*

kernel ? workload management

Related to work load management (WLM), event 10739, dbms\_wlm package,
undocumented v$calltag, v$wlm\*.

x$kzspr,x$kzsro

kernel security, session, privilege, role

Session-specific. X$kzspr is the base table for v$enabledprivilege,
which is base table of session\_privs. X$kzsro is the base table of
session\_roles, and is used by many SQL scripts in ?/rdbms/admin.

x$le

lock element

Base table of v$gc\_element. See the definition of gv$bh for its
relationship with x$bh.

x$lobsegstat,x$lobstat, x$logstathist

LOB (segment) stats, history

X$lobsegstat seems to allow one query only and becomes empty (until
populated later)? Ktslbegtime may be seconds from epoch ([Note
1](#time)). X$lobstat is more persistent and is the base table of
undocumented v$lobstat (space allocation/deallocation columns not
exposed). Lobcurrenttime is seconds since epoch ([Note 1](#time)). KTSJ
Slave process W000 may query v$lobstat in doing space management. For
basic LOB stats, v$sesstat and v$sysstat have 'lob reads', 'lob writes'
etc., and v$segstat has segment-specific stats.

x$logbuf\_readhist

Log buffer read
histogram

[951152.1](https://support.oracle.com/epmos/faces/ui/km/DocContentDisplay.jspx?id=951152.1)

x$messages

(background process) messages

May be the place where background processes (dest) store and fetch
messages about what they do. Related to \_messages parameter (should be
much higher than row count of this table; 2\*processes by default),
messages latch, and "rdbms ipc (message|reply)" wait events.

x$modact\_length

(sql) module action length (limit)

Not sure why necessary. The lengths stored in here are used to truncate
long module and action strings in views such as dba\_hist\_sqlstat,
sqltune related views, etc (find all by `select view_name, text from
user_views where lower(text_vc) like '%x$modact_length%'` as sys in
12*c*).

x$qesmmiwt

query execution, sql memory management ? workarea ?

Base table of v$sql\_workarea\_active, but columns sqlsig, siblings (for
parallel slaves), cap\_size (mem size limit), min\_mem, onepass\_mem,
optimal\_mem, ds\_flags, isize (for input?), osize (output?), ktssosize
are not exposed. Note that
[223730.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=223730.1)
says "Small active sorts (under 64 KB) are excluded from the view"
v$sql\_workarea\_active, which is built on x$qesmmiwt without a
where-clause.

x$qesmmsga

query execution, sql memory management sga

Base table of v$pgastat, which does not show invisible stats (where
qesmmsgavs=0).

x$qksfgi\_cursor

query compilation, sql fine-grained invalidation(?) cursor

Objn\_qksfgi points to objects whose changes may invalidate the SQL
(sqlid\_qksfgi).

x$qksbgses,x$qksbgsys

query compilation service, bug session or system

Base tables of v$session\_fix\_control and v$system\_fix\_control.
Unexposed columns are bits\_qksbgs\[ey\]row (number of bits used),
flag\_qksbgs\[ey\]row, id\_qksbgs\[ey\]row.

x$qksceses,x$qkscesys

query compilation service, compilation environment, session or system

Base tables for v$ses\_optimizer\_env and v$sys\_optimizer\_env,
respectively. There're so many optimizer parameters the two documented
views are missing that sometimes you need to query these base tables
directly. For unexposed session CBO params, select pname\_qksceserow
from x$qksceses minus select name from v$ses\_optimizer\_env. For sys
params, select pname\_qkscesyrow from x$qkscesys minus select name from
v$sys\_optimizer\_env.

x$shadow\_datafile

shadow datafile

12*c*R2. For shadow lost write protection.
[2159248.1](https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=2159248.1).

x$skgxp\_connection,x$skgxp\_port

OS kernel generic interface IPC, connections, ports

RAC only. Show network connections on the interconnect. If you find
significant 'gc blocks lost' in gv$sysstat, check the highest retrans of
x$skgxp\_connection and narrow down to the specific socket connections
based on remote IP's and PID's (rem\_ip\* and rem\_pid). Or check the
highest lost\_msgs in x$skgxp\_port.

x$targetrba

target RBA

[Ref](http://www.ixora.com.au/notes/rba.htm)

x$trace

trace

KST tracing
([Ref](http://nocoug.org/download/2006-02/Advanced_Research_Techniques.pdf)).
From 11*g*, time is microseconds since 2000-01-01 (assumes CDT local
timezone here): select
new\_time(to\_date(to\_char(time/86400000000+to\_date('20000101','yyyymmdd'),'yyyymmdd
hh24:mi:ss'),'yyyymmdd hh24:mi:ss'), 'GMT', 'CDT') from x$trace. Below
11*g*, op column indicates various operations, such as 7 for wait, 11
for latch post
([896098](https://support.oracle.com/epmos/faces/ui/km/BugDisplay.jspx?id=896098)).
10*g* RAC bdump/cdmp\_*time* directory has
[trw](../oranotes/KstTraceCdmpTrwFiles.txt) files that contain the same
info (the trace file has columns TimeInMicroSec:?, OraclePid, SID,
event, OpCode, TraceData). In 11*g* and up, the files are named
\*\_bucket.trc.

x$uganco

user global area, network connection

Base table of v$dblink. Since it's about UGA, each session has different
content. After you end your distributed transactions (distributed
queries included) and close database links, v$dblink no longer shows the
entries. But x$uganco still has them, which unfortunately are not
visible from another session.

x$xplton,x$xpltoo

explain plan sql trace(?) operation name,
option

[Ref](http://tech.e2sn.com/oracle/sql/oracle-execution-plan-operation-reference)

x$xs\_sessions

? sessions

Probably "lightweight user sessions", or Fusion Security sessions. May
be created by a specially constructed OCI or Java program. Also said to
be proxy sessions, but apparently not sessions created by proxy logon.

x$zasa\*

?

Maybe related to Audit Vault.

