#!/bin/bash

export NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS'


# Determine if STDIN is from pipe or terminal

: << 'COMMENT'


 Enter the command on the command line:


 rman-chk-syntax.sh "restore database from tag='RMAN_2018-09_14:30' validate header"
 rman-chk-syntax.sh restore database from tag=\'RMAN_2018-09_14:30\' validate header

 Get commands from a file:

 rman-chk-syntax.sh < some-rman-commands.rman

 How this works:

 Using the 'checksyntax' mode of RMAN

 Determining if input from the terminal or a pipe, and acting accordingly

 Done with -t 0 
 This is test on STDIN to check if it is opened on a terminal

 terminal:
 script.sh some stuff on the commandline
 script.sh <(echo some stuff)
 script.sh cat - <(echo some stuff)

 pipe:
 echo some somestuf | script.sh
 script.sh < somefile.txt

 stdinSource
 T: Terminal
 P: Pipe

COMMENT

stdinSource=''

if [[ -t 0 ]]; then
	#echo STDIN is from a terminal
	stdinSource='T'
else
	#echo STDIN is from a pipe
	stdinSource='P'
fi

# echo stdinSource: $stdinSource

[ -n "$stdinSource" ] || {
	echo
	echo Something has gone wrong
	echo $0 cannot determine the source of STDIN
	echo
	exit 1
}

# save stderr
exec 4>&2

# redirect stderr
exec 2>/dev/null

if [[ $stdinSource == 'T' ]]; then

	rmanCmd="$*"

	echo RMAN CMD: $rmanCmd


	$( which rman  ) checksyntax <<-EOF

		$rmanCmd;

	EOF

	rc=$?

else

	cat - | $( which rman  ) checksyntax 

	rc=$?

fi

# restore stderr
exec 2>&4

if [[ $rc -ne 0 ]]; then
	echo
	echo Failed to run the 'rman' command
	echo Please check your Oracle environment
	echo
	exit 1
fi



