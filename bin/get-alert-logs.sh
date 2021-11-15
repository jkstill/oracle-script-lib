#!/usr/bin/env bash

# Jared Still
# jkstill@gmail.com

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
	# digit for RAC - checks up to 4 nodes

	for orainst in ' ' 1 2 3 4
	do
		testInst=$(ps -eo cmd | grep "[o]ra_pmon_${pinst}${orainst}$")
		if [[ -n $testInst ]]; then
			echo ${pinst}${orainst}
			return
		fi	
	done

	echo ''
	return
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

mkdir -p logs

for psid in $(grep -Ev '^\s*$|^#|^-MGM|^\+ASM' /etc/oratab| cut -f1 -d:)
do
	echo potential sid: $psid
	localInst=$(getInstance $psid)

	echo "   localInst: $localInst"

	declare alertLog='notfound'

	if [[ -n $localInst ]]; then
		alertLog=$(getAlertLog $psid $localInst)
		echo "   alert log: $alertLog"
	fi

	if [[ -r $alertLog ]]; then
		baseAlertLog=$(basename $alertLog)
		tail -20000 $alertLog > logs/$baseAlertLog
	else
		if [[ $alertLog != 'notfound' ]]; then
			echo
			echo "!!! $alertLog not found!!"
			echo
		else
			echo 
			echo "Alert log filename not set - is the instance up?"
			echo
		fi
	fi

done

