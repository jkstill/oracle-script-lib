#!/usr/bin/env bash


banner () {
	echo
	echo '########################################################'
	echo "## $@"
	echo '########################################################'
	echo
}

for sqlid in $(grep -Eo '^[[:alnum:]]{13}' logs/sql-buffer-ratios-awr_2024-03-05_14-22-10.log)
do
	banner "SQL_ID: $sqlid"

	sqlplus -S -L scott/tiger@orcl <<-EOF
		

	EOF
done


	
