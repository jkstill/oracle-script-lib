
Enable SQL Trace and Tracefile Identifier for a Multiple Sessions of a User
===========================================================================

This is a two part process
- first, set the tracefile identifier for the user sessions
- second, enable SQL trace for the user sessions

## Set the tracefile identifier for the user sessions

Using set-tracefile-id-external.sql script, set the tracefile identifier for the user sessions.

The default identifier is 'SQLTRACE'.

```text
@set-tracefile-id-external.sql USERNAME
```

This will find all sesssions for the user and generate a script `_set-tracefile-id-external.sql` to set the tracefile identifier for the user sessions.

The script is then run.

Here I have started 10 sessions for the user 'JKSTILL' and set the tracefile identifier for the user sessions.

```text
SQL> @set-tracefile-id-external.sql JKSTILL

Set tracefile identifier for all sessions of which user?
SYS@ora192rac02/pdb1.jks.com AS SYSDBA%
SYS@ora192rac02/pdb1.jks.com AS SYSDBA% oradebug SETORAPID 120
Oracle pid: 120, Unix process pid: 32263, image: oracle@ora192rac02.jks.com
SYS@ora192rac02/pdb1.jks.com AS SYSDBA% oradebug SETTRACEFILEID SQLTRACE
ORA-32522: restricted heap violation while executing ORADEBUG command: [kghalo bad heap ds] [0x0133BED74] [0x060172100]
SYS@ora192rac02/pdb1.jks.com AS SYSDBA%
SYS@ora192rac02/pdb1.jks.com AS SYSDBA% oradebug SETORAPID 108
Oracle pid: 108, Unix process pid: 32249, image: oracle@ora192rac02.jks.com
SYS@ora192rac02/pdb1.jks.com AS SYSDBA% oradebug SETTRACEFILEID SQLTRACE
ORA-32522: restricted heap violation while executing ORADEBUG command: [kghalo bad heap ds] [0x0133BED74] [0x060172100]
SYS@ora192rac02/pdb1.jks.com AS SYSDBA%
SYS@ora192rac02/pdb1.jks.com AS SYSDBA% oradebug SETORAPID 117
Oracle pid: 117, Unix process pid: 32255, image: oracle@ora192rac02.jks.com
...
```
There is a good chance of seeing the ORA-32522 error. 

This is a bug, and I believe it is a harmless bug.

From the comments in the script:

```text

SQL> oradebug SETTRACEFILEID SQLTRACE
ORA-32522: restricted heap violation while executing ORADEBUG command: [kghalo bad heap ds] [0x0133BED74] [0x060172100]

This note says "Do not use oradebug settracefileid for remote processes"
Bug 25293381 - ORADEBUG command failed with ORA-32522: [KGHALO BAD HEAP DS] for remote processes (Doc ID 25293381.8)

However, the same error appears whether logged on remotely, or directly on the db server.

I believe it is a bug, as the tracefile identifier does get set correctly, despite the error.
```

As this is optional, you do not have to run it if you do not want to.

It does simplify locating the trace files.

## Enable SQL trace for the user sessions

Use the script `dumptracem_on.sql`.

```text
@dumptracem_on.sql USERNAME
```
This script will iterate through all sessions for the user and enable SQL trace for each session.

This is being done with the `sys.dbms_system.set_ev` procedure.

## Disable SQL trace for the user sessions

Use the script `dumptracem_off.sql`.

```text
@dumptracem_off.sql USERNAME
```



