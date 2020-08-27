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


: << 'SOFT-LINKS'

cat > a
this is file a
^D

ln -s a b
ln -s b c
ln -s c d

find the original file, a

=== demo code ===

declare myFile=$1

# declare and assignment from a function cannot be done on 
# a single line if the exit code from the function is to be preserved
# otherwise the exit code seen is from 'declare'
declare fileLinkStatus
fileLinkStatus=$(isSoftLink $myFile)
declare rc=$?

if [[ $rc -ne 0 ]]; then
	echo
	echo rc: $rc
	echo err getting link status for $myFile
	echo 
	exit $rc
fi

if [[ $fileLinkStatus == 'Y' ]]; then
	echo -n 'source file: '
	getLinkSource $myFile
else
	echo not a link: $myFile
fi



SOFT-LINKS

isSoftLink () {

	local file2chk=$1

	[[ -z $file2chk ]] && {
		echo 
		echo isSoftLink: no file passed
		echo
		return 1
	}

	[[ -r $file2chk ]] || { 
		echo 
		echo 
		echo isSoftLink: file not found - $file2chk
		echo
		return 1
	}

	local deref=$(stat -c '%N' $file2chk)

	if [ "'$file2chk'" == "$deref" ]; then
		echo 'N'
	else
		echo 'Y'
	fi

	return 0

}

# find original file from softlink

getLinkSource () {

	local file2chk=$1

	[[ -z $file2chk ]] && {
		echo 
		echo getLinkSource: no file passed
		echo
		return 1
	}

	#echo file2chk: $file2chk

	local parentFile

	while :
	do
		parentFile=$(readlink $file2chk 2>/dev/null)
		[[ -z $parentFile ]] && { echo $file2chk; break; }
		file2chk=$parentFile
	done

	return 0
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

