#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

# this only works as long as the cursor# stays the same for a SQL

my $cursorID = 140304068176776;
my $sqlFragment = q{SELECT DISTINCT (QID), ROUTEREASON FROM};

my ($searchForFetch,$gettingBinds,$exeFound,$sqlFound) = (0,0,0,0);

my $prevLine='';
my $line='';
my %hBinds=();
my $parseTime=0;
my $dummy;

my $debug=0;

while (<>) {

	chomp;

	$prevLine=$line;
	$line = $_;

	#print $line;

	# skip until our SQL found
	if ( ! $sqlFound ) {
		if ( $line =~ /^\Q$sqlFragment/ ) { $sqlFound = 1 }
		next;
	}

	# look for ^BINDS #140304068176776:
	if ( ! $gettingBinds ) {
		if ( $line =~ /^BINDS #${cursorID}/ ) {
			$gettingBinds = 1;
			# get the tim form the previous line, which should be a PARSE
			my @a=split(/,/,$prevLine);
			($dummy,$parseTime) = split(/=/,$a[10]);
			print "Parse Time: $parseTime\n" if $debug;

			next;
		}
	} else {
		if ( $line =~ /^\s+Bind#/ ) { print "$line : " if $debug}
		if ( $line =~ /^\s+value=/ ) { 
			my ($dummy,$value)=split(/=/,$line); 
			print "$value \n" if $debug;

			push @{$hBinds{$parseTime}->{BINDS}},$value;
		}
	}

	if ( $line =~ /^EXEC #${cursorID}/ ) {
		$gettingBinds = 0;
		$searchForFetch = 1;
		next;
	}

	if ($searchForFetch) {

		if ( $line =~ /^FETCH #${cursorID}/ ) {
			print "$line\n" if $debug;
			$hBinds{$parseTime}->{FETCH} = $line;	
			$searchForFetch = 0;
			next;
		}

	}

#print $line;
	
}

#print Dumper(\%hBinds);

my @optGoals = qw( ALL_ROWS FIRST_ROWS RULE CHOOSE );

foreach my $tim ( sort {$b <=> $a} keys %hBinds ) {

	# sample FETCH
	# FETCH #140304068176776:c=269959,e=725736,p=59,cr=40022,cu=0,mis=0,r=0,dep=0,og=1,plh=1619557942,tim=1510368246997484

	my @a=split(/,/,$hBinds{$tim}->{FETCH});

	my $cpuTime = sprintf("%7.6f", (split(/=/,$a[0]))[1] / 10**6 );
	my $elapsedTime = sprintf("%7.6f", (split(/=/,$a[1]))[1] / 10**6);;
	my $physReads = (split(/=/,$a[2]))[1];
	my $consistentGets = (split(/=/,$a[3]))[1];
	my $currentGets = (split(/=/,$a[4]))[1];
	my $rowCount = (split(/=/,$a[6]))[1];

	my $logicalIOs = $currentGets + $consistentGets;

	my $optGoalNum = (split(/=/,$a[8]))[1];

	my $optGoal='UNKNOWN';


	print qq {

====== tim: $tim =========

Execution Statistics

			row count: $rowCount
	 optimizer goal: $optGoals[$optGoalNum-1]
		elapsed time: $elapsedTime
			 cpu time: $cpuTime
	 physical reads: $physReads
	consistent gets: $consistentGets
		current gets: $currentGets
 total logical IOs: $logicalIOs


};

	print "Bind Values\n";

	my $bc=0;
	my @b = map { 'BIND#' . $bc++ . '=' . $_ } @{$hBinds{$tim}->{BINDS}};
	print join("\n",@b), "\n";

	print "FETCH: $hBinds{$tim}->{FETCH}\n";

}
