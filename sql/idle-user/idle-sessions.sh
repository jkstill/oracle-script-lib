#!/usr/bin/env bash

# bucket size, count
declare -A sleepTimes=( 
	[3]=5 
	[7]=3 
	[17]=2 
	[65]=2 
	[91]=3 
	[275]=1 
	[620]=1 
	[1325]=3
)


for sleepTime in ${!sleepTimes[@]}
do
	sessionCount=${sleepTimes[$sleepTime]}

	for sessionNum in $(seq 1 $sessionCount)
	do

		nohup ./idle-session.pl -username idle_user -password idle_user -database ora192rac-scan/pdb1.jks.com -sleeptime $sleepTime &

	done

done

