#!/usr/bin/env bash

source /home/oracle/sql-driver/functions.sh

#showInstances

declare sqlScript="$@"

[[ -z $sqlScript ]] && {
	echo
	echo Please include SQL Script and parameters
	echo
	exit 1
}

for instance in ${!instances[@]}
do
	echo "####	${sids[$instance]} ####"
	runSQL ${sids[$instance]} ${instances[$instance]} "$sqlScript"
done

cleanup


