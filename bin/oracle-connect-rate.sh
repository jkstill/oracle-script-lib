#!/bin/bash

# get connection rate from oracle listener log

function exeCmd {
	declare cmd2run=$*

	if [[ $dryrun -eq 0 ]]; then
		eval $cmd2run
	else 
		echo CMD: $cmd2run
	fi
}

function usage {
	cat <<-EOF

     $0

     -f listener log file
     -S service 
     -s summarize by second
     -m summarize by minute
     -h summarize by hour
     -d dryrun - do not execute commands
     -? help

	EOF
}

logFile=''
searchTerm=''
connectionTerm='* establish *'
service=''
dryrun=0

summaryType=''

while getopts ?dsmhf:S: arg
do
	case $arg in
		d) dryrun=1;;
		f) logFile=$OPTARG;;
		S) service=$OPTARG;;
		s) summaryType='second';;
		m) summaryType='minute';;
		h) summaryType='hour';;
		?) usage;exit;;
		*) usage; exit 1;;
	esac
done

[[ -r $logFile ]] || {
	echo
	echo "Cannot read file $logFile"
	usage
	exit 3
}

searchTerm="${service}.*${connectionTerm}"

if [[ $summaryType == 'second' ]]; then
	timeStrLen=8
	timePadStr=''
elif [[ $summaryType == 'minute' ]]; then
	timeStrLen=5
	timePadStr=':00'
elif [[ $summaryType == 'hour' ]]; then
	timeStrLen=2
	timePadStr=':00:00'
else
	# error
	usage
	exit 2
fi

CMD="grep -h \"$searchTerm\" $logFile | awk -v timeStrLen=$timeStrLen '{ print \$1, substr(\$2,0,timeStrLen) }'  | uniq -c | awk -v timePadStr='$timePadStr' '{ print \$2,\$3 timePadStr\",\" \$1 }'"

#echo CMD: $CMD

exeCmd "$CMD"


