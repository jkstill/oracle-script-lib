declare oratabFile=/etc/oratab

# use to get RAC instances from db name
# will not work correctly if /etc/oratab has orcl, orcl-01, etc.

declare -a instances
declare -a sids
declare pmonFile=/dev/shm/pmons.$$

startup () {
	ps -eo cmd| grep [o]ra_pmon > $pmonFile
}

cleanup () {
	rm -f $pmonFile
}

getInstance () {

	local pinst=$1

	[ -z "$pinst" ] && {
		echo "getInstance: pinst arg is empty" 1>&2
		echo ''
		return
	}

	# return instance name if pmon exists
	# there are 3 nodes, so make it generic

	declare testIns

	# space if standalone
	# digit for RAC - checks up to 8 nodes

	for orainst in ' ' 1 2 3 4 5 6 7 8
	do
		#testInst=$(ps -eo cmd | grep "[o]ra_pmon_${pinst}${orainst}$")
		testInst=$(grep "[o]ra_pmon_${pinst}${orainst}$" $pmonFile )
		if [[ -n $testInst ]]; then
			echo ${pinst}${orainst}
			return
		fi
	done

	echo ''
	return
}

getAllInstances () {

	local i=0

	for psid in $(grep -Ev '^\s*$|^#|^-MGM|^\+ASM' $oratabFile | cut -f1 -d:)
	do
		localInst=$(getInstance $psid)

		#echo
		#echo "	database: $psid"
		#echo "	instance: $localInst"
		#echo

		instances[$i]=$localInst
		sids[$i]=$psid

		(( i++ ))

	done

}


runSQL () {

	local dbName=$1
	local instName=$2
	local script=$3

	. oraenv <<< $dbName > /dev/null
	export ORACLE_SID=$instName

	sqlplus -s -L / as sysdba <<-EOF
		@$script
		exit
EOF

}

getAlertLog () {
	local pinst=$1; shift
	local linst=$1

	. /usr/local/bin/oraenv <<< $pinst >/dev/null 2>&1
	export ORACLE_SID=$linst

	sqlplus -s -L / as sysdba <<-EOF

		set timing off
		set echo off term off heading off
		set pause off echo off
		set linesize 200 trimspool on
		set pagesize 0

		col alert_log format a120

		select d.value || '/alert_' || i.instance_name || '.log' alert_log
		from v\$diag_info d
		, v\$instance i
		where d.name = 'Diag Trace';


EOF

}


getTraceFile () {
	local pinst=$1; shift
	local linst=$1; shift
	local lgwrPid=$1

	. /usr/local/bin/oraenv <<< $pinst >/dev/null 2>&1
	export ORACLE_SID=$linst

	sqlplus -s -L / as sysdba <<-EOF

		set timing off
		set echo off term off heading off
		set pause off echo off
		set linesize 200 trimspool on
		set pagesize 0

		col tracefile format a120

		select d.value || '/' || i.instance_name || '_lgwr_' || $lgwrPid || '.trc'	 tracefile
		from v\$diag_info d
		, v\$instance i
		where d.name = 'Diag Trace';


EOF

}

# the instances and sids arrays must first be populated
# via getAllInstances

showInstances () {
	for i in ${!instances[@]}
	do
		echo "	  sid: ${sids[$i]}"
		echo "instance: ${instances[$i]}"
		echo
	done
}


trapcmds () {
	typeset SIGTEXT=${1:-'UNKNOWN'}
	typeset SIGNUM=${2:-1}

	cleanup
	exit $SIGNUM
}

catchINT () {
	trapcmds SIGINT 2
}


trap "catchINT" INT

startup
getAllInstances
cleanup

#showInstances

