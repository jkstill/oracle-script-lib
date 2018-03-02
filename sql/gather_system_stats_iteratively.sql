
/*

A script to drive this

-----------------------------
#!/bin/bash

# gather_system_stats_iteratively.sh

# assume Oracle environment already set
# fail if not

[[ -z $ORACLE_SID ]] && {
   echo
   echo Oracle Environment is not set
   echo 
   exit 1
}


sqlplus /nolog <<-EOF
   connect / as sysdba
   @gather_system_stats_iteratively
   exit
EOF
----------------------

nohup ./gather_system_stats_iteratively.sh &


*/

-- see os_stats_avg.sql

define stats_owner='AVAIL'
define stats_table='OS_STATS'

declare

	v_statid varchar2(30);

begin

	-- run for 24 hrs
	-- 10 minutes at at time

	for i in 1 .. 144
	loop
	
		v_statid := 'OS' || to_char(sysdate,'yymmddhh24mi');

		avail.gather_system_stats (
			v_statid_in		=> v_statid,
			n_interval_in	=> 10,
			v_statowner_in => '&stats_owner',
			v_stattab_in	=> '&stats_table'
		);

	end loop;
end;
/


