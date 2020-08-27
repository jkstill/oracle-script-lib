#!/usr/bin/env bash

# get oracle homes for running databases


while read opid ocmd
do
	echo $opid: $ocmd
	(cat /proc/${opid}/environ; echo) | tr '\000' '\n'| grep ORACLE_HOME
done < <( ps -e -o pid,comm | grep [o]ra_pmon )

