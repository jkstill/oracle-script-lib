-- getaud.sql
--
-- SCRIPT: Generate AUDIT and NOAUDIT Statements for Current Audit Settings [ID 287436.1]
--
-- Script to generate (equivalents *) of current AUDIT options
-- and the NOAUDIT statements to remove the current audit options.
-- 
-- It is intended for DBA's to get insight in current audit options,
-- backup / transfer purposes, can be used to manipulate audit needs
-- by selectively editing the resulting audit_redo.sql and audit_undo.sql
-- scripts and any other purpose I cannot immediately think of.
--
-- (C) Oracle Corporation 2004
-- Written by Harm Joris ten Napel, Oracle Support Services, The Netherlands
--
-- *) Note for example that if you specify statement options or system
-- privileges that audit data definition language (DDL) statements, then Oracle
-- automatically audits by access regardless of whether you specify the
-- BY SESSION clause or BY ACCESS clause.
-- 
-- For statement options and system privileges that audit SQL statements other
-- than DDL, you can specify either BY SESSION or BY ACCESS. BY SESSION is
-- the default. The audit_redo.sql script will however include it for clarity.

-- Audit options are managed internally in AUDIT$ table only, both DBA views
-- DBA_STMT_AUDIT_OPTS and DBA_PRIV_AUDIT_OPTS select from this SYS table.
-- The success and failure columns have the following description from sql.bsq:
--
-- success  :    audit on success? 
-- failure  :    audit on failure? 
-- null = no audit, 1 = audit by session, 2 = audit by access 
--
-- Only values 01,02,10,11,20,22 are valid.

-- Limitations:
--
-- * Only Statement and Privilege auditing options administered in AUDIT$ are
--   considered here.

set pages 1000
set echo off
set heading off
set feedback off
spool audit_redo.sql

select 'AUDIT '||m.name||decode(u.name,'PUBLIC',' ',' BY '||u.name)||
       decode(nvl(a.success,0)  + (10 * nvl(a.failure,0)),
       1,' BY SESSION WHENEVER SUCCESSFUL ', 
       2,' BY ACCESS WHENEVER SUCCESSFUL ',
       10,' BY SESSION WHENEVER NOT SUCCESSFUL ',
       11,' BY SESSION ',   -- default 
       20, ' BY ACCESS WHENEVER NOT SUCCESSFUL ',
       22, ' BY ACCESS',' /* not possible */ ')||' ;'
 "AUDIT STATEMENT"
        FROM sys.audit$ a, sys.user$ u, sys.stmt_audit_option_map m
        WHERE a.user# = u.user# AND a.option# = m.option#
              and bitand(m.property, 1) != 1  and a.proxy# is null
              and a.user# <> 0
        UNION
select 'AUDIT '||m.name||decode(u1.name,'PUBLIC',' ',' BY '||u1.name)||
       ' ON BEHALF OF '|| decode(u2.name,'SYS','ANY',u2.name)||
       decode(nvl(a.success,0)  + (10 * nvl(a.failure,0)),
       1,' WHENEVER SUCCESSFUL ',
       2,' WHENEVER SUCCESSFUL ',
       10,' WHENEVER NOT SUCCESSFUL ',
       11,' ',   -- default
       20, ' WHENEVER NOT SUCCESSFUL ',
       22, ' ',' /* not possible */ ')||';'
 "AUDIT STATEMENT"
     FROM sys.audit$ a, sys.user$ u1, sys.user$ u2, sys.stmt_audit_option_map m
     WHERE a.user# = u2.user# AND a.option# = m.option# and a.proxy# = u1.user#
              and bitand(m.property, 1) != 1  and a.proxy# is not null 
UNION
select 'AUDIT '||p.name||decode(u.name,'PUBLIC',' ',' BY '||u.name)||
       decode(nvl(a.success,0)  + (10 * nvl(a.failure,0)),
       1,' BY SESSION WHENEVER SUCCESSFUL ',
       2,' BY ACCESS WHENEVER SUCCESSFUL ',
       10,' BY SESSION WHENEVER NOT SUCCESSFUL ',
       11,' BY SESSION ',   -- default
       20, ' BY ACCESS WHENEVER NOT SUCCESSFUL ',
       22, ' BY ACCESS',' /* not possible */ ')||' ;'
 "AUDIT STATEMENT"
        FROM sys.audit$ a, sys.user$ u, sys.system_privilege_map p
        WHERE a.user# = u.user# AND a.option# = -p.privilege
              and bitand(p.property, 1) != 1 and a.proxy# is null
         and a.user# <> 0
UNION
select 'AUDIT '||p.name||decode(u1.name,'PUBLIC',' ',' BY '||u1.name)||
       ' ON BEHALF OF '|| decode(u2.name,'SYS','ANY',u2.name)||
       decode(nvl(a.success,0)  + (10 * nvl(a.failure,0)),
       1,' WHENEVER SUCCESSFUL ',
       2,' WHENEVER SUCCESSFUL ',
       10,' WHENEVER NOT SUCCESSFUL ',
       11,' ',   -- default
       20, ' WHENEVER NOT SUCCESSFUL ',
       22, ' ',' /* not possible */ ')||';'
 "AUDIT STATEMENT"
   FROM sys.audit$ a, sys.user$ u1, sys.user$ u2, sys.system_privilege_map p
   WHERE a.user# = u2.user# AND a.option# = -p.privilege and a.proxy# = u1.user#
              and bitand(p.property, 1) != 1 and a.proxy# is not null 
;

spool off

spool audit_undo.sql

select 'NOAUDIT '||m.name||decode(u.name,'PUBLIC',' ',' BY '||u.name)||
              decode(nvl(a.success,0)  + (10 * nvl(a.failure,0)),
       1,' WHENEVER SUCCESSFUL ',
       2,' WHENEVER SUCCESSFUL ',
       10,' WHENEVER NOT SUCCESSFUL ',
       11,' ', 
       20, ' WHENEVER NOT SUCCESSFUL ',
       22, ' ',' /* not possible */ ')||' ;'
 "NOAUDIT STATEMENT"
        FROM sys.audit$ a, sys.user$ u, sys.stmt_audit_option_map m
        WHERE a.user# = u.user# AND a.option# = m.option#
              and bitand(m.property, 1) != 1 and a.proxy# is null
              and a.user# <> 0
UNION
select 'NOAUDIT '||m.name||decode(u1.name,'PUBLIC',' ',' BY '||u1.name)||
       ' ON BEHALF OF '|| decode(u2.name,'SYS','ANY',u2.name)||
       decode(nvl(a.success,0)  + (10 * nvl(a.failure,0)),
       1,' WHENEVER SUCCESSFUL ',
       2,' WHENEVER SUCCESSFUL ',
       10,' WHENEVER NOT SUCCESSFUL ',
       11,' ',   -- default
       20, ' WHENEVER NOT SUCCESSFUL ',
       22, ' ',' /* not possible */ ')||';'
 "AUDIT STATEMENT"
     FROM sys.audit$ a, sys.user$ u1, sys.user$ u2, sys.stmt_audit_option_map m
     WHERE a.user# = u2.user# AND a.option# = m.option# and a.proxy# = u1.user#
              and bitand(m.property, 1) != 1  and a.proxy# is not null 
        UNION
select 'NOAUDIT '||p.name||decode(u.name,'PUBLIC',' ',' BY '||u.name)||
       decode(nvl(a.success,0)  + (10 * nvl(a.failure,0)),
       1,' WHENEVER SUCCESSFUL ',
       2,' WHENEVER SUCCESSFUL ',
       10,' WHENEVER NOT SUCCESSFUL ',
       11,' ',   -- default
       20, ' WHENEVER NOT SUCCESSFUL ',
       22, ' ',' /* not possible */ ')||' ;'
 "NOAUDIT STATEMENT"
        FROM sys.audit$ a, sys.user$ u, sys.system_privilege_map p
        WHERE a.user# = u.user# AND a.option# = -p.privilege
              and bitand(p.property, 1) != 1  and a.proxy# is null
              and a.user# <> 0
UNION
select 'NOAUDIT '||p.name||decode(u1.name,'PUBLIC',' ',' BY '||u1.name)||
       ' ON BEHALF OF '|| decode(u2.name,'SYS','ANY',u2.name)||
       decode(nvl(a.success,0)  + (10 * nvl(a.failure,0)),
       1,' WHENEVER SUCCESSFUL ',
       2,' WHENEVER SUCCESSFUL ',
       10,' WHENEVER NOT SUCCESSFUL ',
       11,' ',   -- default
       20, ' WHENEVER NOT SUCCESSFUL ',
       22, ' ',' /* not possible */ ')||';'
 "AUDIT STATEMENT"
   FROM sys.audit$ a, sys.user$ u1, sys.user$ u2, sys.system_privilege_map p
   WHERE a.user# = u2.user# AND a.option# = -p.privilege and a.proxy# = u1.user#
              and bitand(p.property, 1) != 1 and a.proxy# is not null;

select unique 
 '-- Please correct the problem described in note 455565.1:'
 ||chr(13)||chr(10)||
 'delete from sys.audit$ where user#=0 and proxy# is null;'
 ||chr(13)||chr(10)||'commit;'
 from sys.audit$  where user#=0 and proxy# is null;

select '-- Please correct the problem described in bug 6636804:'
  ||chr(13)||chr(10)||
  'update sys.STMT_AUDIT_OPTION_MAP set option#=234'
  ||chr(13)||chr(10)||' where name =''ON COMMIT REFRESH'';'
  ||chr(13)||chr(10)||'commit;'
  from  sys.STMT_AUDIT_OPTION_MAP where option#=229 and name ='ON COMMIT REFRESH';

select
 '-- Please correct the problem described in bug 6124447:'
 ||chr(13)||chr(10)||
 'noaudit truncate;'
 from sys.audit$ where option#=155;

spool off

set heading on
set feedback on

