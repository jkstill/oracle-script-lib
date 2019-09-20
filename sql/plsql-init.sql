
-- setup plscope

alter session set plscope_settings='IDENTIFIERS:ALL';

alter session set plsql_warnings = 'ENABLE:SEVERE';
--alter session set plsql_warnings = 'ENABLE:ALL';

-- may not currently be using debug
alter session set plsql_ccflags = 'debug:true, develop:true';

