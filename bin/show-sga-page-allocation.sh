
#!/usr/bin/env bash

# match to ipcs -m
# flush this out so that it can be easily seen if an SGA is not 100% mapped in hugepages

notice () {

	local msg="$@"
	echo "##############################################"
	echo "## $msg"
	echo "##############################################"
}

while read  pid pmon
do
	lastLine=$(grep -n ^VmFlags /proc/$pid/smaps| head -1| cut -f1 -d:)
	(( lastLine-- ))
	#echo lastLine: $lastLine
	notice pid: $pid   pmon: $pmon ": grep -A${lastLine} SYSV /proc/$pid/smaps"
	grep -A${lastLine} SYSV /proc/$pid/smaps 
done < <(ps -e -o pid,cmd | grep ora_[p]mon)

