#!/usr/bin/env bash

PID=${1?-Please provide a PID}

# default is nonVerbose
: ${MSZ_VERBOSE:-N}

nonVerbose () {
	[[ $MSZ_VERBOSE == 'Y' ]] && { return; }
	local outstr="$@"
	echo "$outstr"
	return
}

verbose () {
	[[ $MSZ_VERBOSE != 'Y' ]] && { return; }
	local outstr="$@"
	echo "$outstr"
	return
}

: << 'COMMENT'

  /proc/PID/maps

  When $5 is 0, the memory is private

  As this memory may be from a shared lib (.so file), it also appears as private

  This is why an inode of 0 is searched for

  The permissions of rw-p exclude the libraries

  This shows the mapped memory regions for the process, which is not the same as RAM that is currently in use.

  map proc: see RSS, smaps
  map pmap: see -X
  

COMMENT

totalMem=0

while read subtrahend minuend
do
	difference=$(( 16#$minuend - 16#$subtrahend ))
	verbose "$minuend - $subtrahend =  $difference"
	(( totalMem += $difference ))
done < <( awk '{ if ($5 == 0 && $2 ~ /rw-p/)  {print $1}}' /proc/$PID/maps | awk -F- '{ print $1,$2 }')

verbose ""
verbose Total Memory allocated for $PID: $totalMem Bytes
verbose ""
nonVerbose $totalMem


