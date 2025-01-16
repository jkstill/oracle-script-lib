#!/usr/bin/env bash


USER=${1?-Please provide a username}

totalMem=0

for pid in $(ps -u$USER -o pid)
do
	memUsed=$(./memsz.sh $pid)
	echo PID $pid: $memUsed
	echo "    cmd: " $(ps -p $pid -o args)
	(( totalMem += memUsed ))
done 

echo
echo Total Private Memory allocated for User: $USER $totalMem Bytes
echo

