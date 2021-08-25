
#!/usr/bin/env bash

# match to ipcs -m
# prototype - see Perl script sga-smallpage-detector.pl

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

