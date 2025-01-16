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

		select d.value || '/' || i.instance_name || '_lgwr_' || $lgwrPid || '.trc'  tracefile
		from v\$diag_info d
		, v\$instance i
		where d.name = 'Diag Trace';


EOF

}

mkdir -p trace

for psid in $(grep -Ev '^\s*$|^#|^-MGM|^\+ASM' /etc/oratab| cut -f1 -d:)
do
	echo potential sid: $psid
	localInst=$(getInstance $psid)

	echo "   localInst: $localInst"

	declare traceFile='notfound'

	if [[ -n $localInst ]]; then
		declare pid=$(ps -eo pid,cmd | grep [o]ra_lgwr_${localInst} | awk '{print $1}')

		if [[ -n $pid ]]; then
			traceFile=$(getTraceFile $psid $localInst $pid)
			echo "   tracefile: $traceFile"
		else
			echo 
			echo "PID not found"
			echo
		fi
	fi

	if [[ -r $traceFile ]]; then
		cp $traceFile trace
	else
		if [[ $traceFile != 'notfound' ]]; then
			echo
			echo "!!! $traceFile not found!!"
			echo
		else
			echo
			echo "Tracefile not set - is the instance up?"
			echo
		fi
	fi

done

