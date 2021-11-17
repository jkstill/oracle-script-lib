#!/usr/bin/env perl

# Jared Still 2021
# jkstill@gmail.com

use warnings;
use strict;
use FileHandle;
use DBI;
use Getopt::Long;
use Data::Dumper;
use POSIX qw(strftime);
use Time::HiRes( qw{tv_interval gettimeofday});

my %optctl = ();

my($db, $username, $password, $connectionMode, $localSysdba);
my($adjustCols);
$adjustCols=0;
my $sysdba=0;
my $connectionTest=0;
my $iterations=0;
my $intervalSeconds=60;
my $showExeTime=0;
my $secondsFormat='04.6f';

Getopt::Long::GetOptions(
	\%optctl,
	"database=s" => \$db,
	"username=s" => \$username,
	"password=s" => \$password,
	"connection-test!" => \$connectionTest,
	"iterations=i" => \$iterations,
	"interval-seconds=i" => \$intervalSeconds,
	"show-exe-time!" => \$showExeTime,
	"sysdba!",
	"local-sysdba!",
	"sysoper!",
	"z","h","help");

$localSysdba=$optctl{'local-sysdba'};

if ($localSysdba) {
	$username=undef;
	$password=undef;
} else {
	$connectionMode = 0;
	if ( $optctl{sysoper} ) { $connectionMode = 4 }
	if ( $optctl{sysdba} ) { $connectionMode = 2 }

	usage(1) unless ($db and $username and $password);
}

$|=1; # flush output immediately

sub getOraVersion($$$);

my $dbh ;

if ($localSysdba) {
	$dbh = DBI->connect(
		'dbi:Oracle:',$username,$password,
		{
			RaiseError => 1,
			AutoCommit => 0,
			ora_session_mode => 2
		}
	);
} else {
	$dbh = DBI->connect(
		'dbi:Oracle:' . $db,
		$username, $password,
		{
			RaiseError => 1,
			AutoCommit => 0,
			ora_session_mode => $connectionMode
		}
	);
}

die "Connect to  $db failed \n" unless $dbh;
$dbh->{RowCacheSize} = 100;

# get the major and minor version of the instance
if ($connectionTest) {
	my ($majorOraVersion, $minorOraVersion);
	getOraVersion (
			\$dbh,
			\$majorOraVersion,
			\$minorOraVersion,
	);

	print "Major/Minor version $majorOraVersion/$minorOraVersion\n";
	my $dbVersion="${majorOraVersion}.${minorOraVersion}" * 1; # convert to number
	$dbh->disconnect;
	exit 0;
}


my $sql=q{select name from v$statname
where name in (
	'SQL*Net roundtrips to/from client'
	,'SQL*Net roundtrips to/from dblink'
	,'bytes received via SQL*Net from client'
	,'bytes received via SQL*Net from dblink'
	,'bytes sent via SQL*Net to client'
	,'bytes sent via SQL*Net to dblink'
)
order by name};

my $sth = $dbh->prepare($sql);
$sth->execute;

my @hdrColumns=qw{timestamp elapsed schema};

# use some shorter names for the columns
my %hdrSubs = (
	'SQL*Net roundtrips to/from client'			=> 'client-roundtrips',
	'SQL*Net roundtrips to/from dblink'			=> 'dblink-roundtrips',
	'bytes received via SQL*Net from client'	=> 'bytes-from-client',
	'bytes received via SQL*Net from dblink'	=> 'bytes-from-dblink',
	'bytes sent via SQL*Net to client'			=> 'bytes-to-client',
	'bytes sent via SQL*Net to dblink'			=> 'bytes-to-dblink',
);

my $maxMetricEl = scalar(keys %hdrSubs) -1;
my @emptyMetrics=();
foreach my $i ( 0 .. $maxMetricEl ) { push @emptyMetrics,0; }

while(my @ary = $sth->fetchrow_array) {
	push @hdrColumns,$hdrSubs{$ary[0]};
}

print join(',',@hdrColumns) . "\n";

$sql = q{select
   sess.username, sess.sid, sess.serial#,
   name.name name,
   stat.value value
from gv$sesstat stat, v$statname name, v$session sess
where
   stat.sid = sess.sid
   and sess.username is not null
   and stat.statistic# = name.statistic#
   and name in (
      'SQL*Net roundtrips to/from client'
      ,'SQL*Net roundtrips to/from dblink'
      ,'bytes received via SQL*Net from client'
      ,'bytes received via SQL*Net from dblink'
      ,'bytes sent via SQL*Net to client'
      ,'bytes sent via SQL*Net to dblink'
   )
order by sess.username, name.name};

$sth = $dbh->prepare($sql);

my ($startExeTime, $endExeTime, $exeTime);
# get the first execution outside the loop

($startExeTime) = [gettimeofday];
$sth->execute;
($endExeTime) = [gettimeofday];
$exeTime = tv_interval($startExeTime, $endExeTime);
warn sprintf("Exe Time: %$secondsFormat\n",$exeTime) if $showExeTime;

my %dataPrev=(); my %dataCurr=();
while(my @ary = $sth->fetchrow_array) {
	#print join(',',@ary) . "\n";
	push @{$dataPrev{$ary[0]}->{"$ary[1]:$ary[2]"}}, $ary[4]; # sid:serial, value
}

# get data in a loop, up to max iterations
my ($elapsed,$timestamp,$startTime,$endTime);
($startTime) = [gettimeofday];

for (my $i=0; $i<$iterations; $i++) {
	sleep $intervalSeconds;

	($startExeTime) = [gettimeofday];
	$sth->execute;
	($endExeTime) = [gettimeofday];
	$exeTime = tv_interval($startExeTime, $endExeTime);
	warn sprintf("Exe Time: %$secondsFormat\n",$exeTime) if $showExeTime;


	($endTime) = [gettimeofday];
	$elapsed = tv_interval($startTime, $endTime);

	$timestamp = getTimestamp();

	while(my @ary = $sth->fetchrow_array) {
		#print join(',',@ary) . "\n";
		push @{$dataCurr{$ary[0]}->{"$ary[1]:$ary[2]"}}, $ary[4]; # sid:serial, value
	}

	my %dataDiff=();
	foreach my $schema ( keys %dataCurr ) {
		next unless exists $dataPrev{$schema};

		# compare SID:SERIAL keys
		# when calculating diffs, only use those from prev that are still logged on
		# ie. sid:serial that are still in current data

		my @currKeys = map { $_ } keys %{$dataCurr{$schema}};
		#print "schema: $schema: " . '@currKeys: ' . Dumper(\@currKeys);

		# this map is not quite right - the loop works fine
		#my @prevKeys = map { $_ if exists $dataPrev{$schema}{$_}} keys %{$dataCurr{$schema}};
		my @prevKeys = ();
		foreach my $key (@currKeys) {
			if (exists $dataPrev{$schema}{$key}) {
				push @prevKeys, $key;
			}
		}
		#print "schema: $schema: " . '@prevKeys: ' . Dumper(\@prevKeys);

		my @prevMetrics=parseMetrics(\%{$dataPrev{$schema}}, \@prevKeys);
		#print '@prevMetrics: ' . Dumper(\@prevMetrics);
		
		my @currMetrics=parseMetrics(\%{$dataCurr{$schema}}, \@{currKeys});
		#print '@currMetrics ' . Dumper(\@currMetrics);
		
		foreach my $el ( 0 .. $maxMetricEl ) {
			#push @{$dataDiff{$schema}}, $metrics[$el] - @{$dataPrev{$schema}}[$el];
			# if prev not defined, then all sessions for the user logged on during the sleep
			# if curr is defined, then the final metric == curr
			#
			# if curr not defined, then all sessions for the user logged off during the sleep
			# if prev is defined, then the final metric negative - 0-prev
			my $prevMetric = defined $prevMetrics[$el] ? $prevMetrics[$el] : 0;
			my $currMetric = defined $currMetrics[$el] ? $currMetrics[$el] : 0;
			push @{$dataDiff{$schema}}, $currMetric - $prevMetric;
		}

		# if both prev and curr are empty, there is no data
		# not sure how this happens
		if (! defined $dataDiff{$schema} ) {
			$dataDiff{$schema} = @emptyMetrics;	
		}
	}

	# splice in timestamp and elapsed
	foreach my $schema (keys %dataPrev) {
		#print "SCHEMA: $schema\n";
		splice(@{$dataDiff{$schema}},0,0,($timestamp,$elapsed));
	}

	#print 'Diff: ' . Dumper(\%dataDiff);
	printData(%dataDiff);

	%dataPrev = %dataCurr;
	%dataCurr = ();
	($startTime) = [gettimeofday];

}

$dbh->disconnect;

# pass hash and keys to use
#
sub parseMetrics {
	my ($metricsHash, $keysToUse) = @_;
	#print '$metricsHash: ' . Dumper($metricsHash);

	my @prevMetrics=();
	foreach my $sidSerial ( @{$keysToUse} ) {
		#print "sidSerial: $sidSerial\n";
		my @workMetrics = @{$metricsHash->{"$sidSerial"}};
		foreach my $el ( 0 .. $#workMetrics ) {
			$prevMetrics[$el] += $workMetrics[$el];
		}
	}
	#print '@prevMetrics: ' . Dumper(\@prevMetrics);
	return @prevMetrics;
};

sub printData {
	my (%data) = @_;
	foreach my $key ( sort keys %data ) {
		my @data = @{$data{$key}};
		splice(@data,2,0,$key);
		print join(',',@data) . "\n";
	}
}

sub usage {
	my $exitVal = shift;
	$exitVal = 0 unless defined $exitVal;
	use File::Basename;
	my $basename = basename($0);
	print qq/

usage: $basename

  -database				 target instance
  -username				 target instance account name
  -password				 target instance account password
  -sysdba				 logon as sysdba
  -sysoper				 logon as sysoper
  -iterations			 number of iterations
  -interval-seconds	 seconds per iteration
  -connection-test	 test the connection and exit
  -local-sysdba		 logon to local instance as sysdba. ORACLE_SID must be set
							 the following options will be ignored:
								-database
								-username
								-password

  example:

  $basename -database dv07 -username scott -password tiger -sysdba

  $basename -local-sysdba

/;
	exit $exitVal;
};

sub getOraVersion($$$) {
	my ($dbh,$major,$minor) = @_;

	my $sql=q{select
	substr(version,1,instr(version,'.')-1) major_version
	, substr (
		substr(version,instr(version,'.')+1), -- following the first '.'
		1, -- start at the first character
		instr(substr(version,instr(version,'.')+1),'.')-1 -- everything before the first '.'
	) minor_version
	from v$instance};

	my $sth = $$dbh->prepare($sql,{ora_check_sql => 0});
	$sth->execute;
	($$major,$$minor) = $sth->fetchrow_array;
}

sub getTimestamp {
	return strftime "%Y-%m-%d %H:%M:%S", localtime;
}

