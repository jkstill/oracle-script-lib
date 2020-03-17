#!/usr/bin/env bash

# is is assumed the oracle environment is already set


# edit as needed
declare oraConnectString='/ as sysdba'

declare sqlplusCMD='sqlplus'

which $sqlplusCMD
declare rc=$?

[[ $rc -ne 0 ]] && {

  echo 
  echo CMD: $sqlplusCMD not found
  echo 
  echo did you set the Oracle environment?
  echo

  exit 1

}

declare sqlScript=/tmp/getparms-${$}.sql

cat <<-EOF > $sqlScript
  whenever sqlerror exit 128
  connect $oraConnectString

  whenever sqlerror exit 127

  set pause off
  set timing off
  set echo off verify off

  clear col
  clear break
  clear computes

  btitle ''
  ttitle ''

  btitle off
  ttitle off

  set newpage 1

  col u_db new_value u_db
  select name u_db from v\$database;

  col u_host new_value u_host
  select host_name u_host from v\$instance;

  col u_logfile new_value u_logfile
  select 'parms-&u_host-&u_db..csv' u_logfile from dual;


  set term off feed off head off
  set pagesize 0 
  set linesize 300 trimspool on

  set echo off 

  spool &u_logfile

  prompt name,description,value,isdefault,isses_modifiable,issys_modifiable,ismodified,isadjusted
  -- con_id and inst_id do not seem to be as expected here

  select
    '''' || a.KSPPINM
    || '''' || ',' || '''' || a.KSPPDESC -- DESCRIPTION
    || '''' || ',' || '''' || b.KSPFTCTXVL -- VALUE
    || '''' || ',' || '''' || decode(b.KSPFTCTXDF,'TRUE','Y','N') -- ISDEFAULT
    || '''' || ',' || '''' || decode(bitand(ksppiflg/256,1),1,'Y' ,'N') -- ISSES_MODIFIABLE
    || '''' || ',' || '''' || decode(bitand(ksppiflg/65536,3),1,'I',2,'D', 3,'I','N') -- ISSYS_MODIFIABLE
    || '''' || ',' || '''' || decode(bitand(KSPFTCTXVF,7),1,'M',4,'S','N') -- ISMODIFIED
    || '''' || ',' || '''' || decode(bitand(KSPFTCTXVF,2),2,'Y','N') -- ISADJUSTED 
    || ''''
  from X\$KSPPI a, x\$ksppcv2 b
  where b.kspftctxpn = a.indx+1
    --and  b.inst_id = a.inst_id
    --and b.con_id = a.con_id
  order by 1;

  spool off

  set term on 
  prompt
  prompt output file: &u_logfile
  prompt

  exit

EOF


$sqlplusCMD /nolog @${sqlScript}

rm -f ${sqlScript}



