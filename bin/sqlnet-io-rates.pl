#!/usr/bin/env perl

# Jared Still 2021
# jkstill@gmail.com


=head1 sqlnet-io-rates.pl

 Capture SQLNet IO rates per user

 Every interval-seconds, capture the current SQLNet IO data from v$sesstat

 Compare the data to the previous snapshot of the data to derive the amount per session.

 This cannot be completely accurate, as sessions may disconnect between intervals.

  When a session logs off between intervals, we do not know if there was any IO performed, as there is no current data for that session.

  When a session logs on during the interval, we can assume the current data for the session is the amount of IO

  When a session is logged on during both the begin interval time (T1) and the end interval time (T2), then
  the amount of IO is the T2 data - T1 data.

  USER  SID  T1 LoggedOn T2 LoggedOn T1 Bytes to Client   T2 Bytes to Client  Interval Bytes to Client 
 =====  ===  =========== =========== ==================   =================   ========================
  SOE    11     Y          N              100                                      Unknown
  SOE    12     Y          Y              100                 200                      100
  SOE    13     N          Y                                  100                      100
    

  Data is lost when a session disconnects between T1 and T2.

  example:

    ./sqlnet-io-rates.pl  -database oraserver/orcl.jks.com -username scott -password tiger -interval-seconds 60 -iterations 7200

=cut

use warnings;
use strict;
use FileHandle;
use DBI;
use Getopt::Long;
use Data::Dumper;
$Data::Dumper::Purity=1;
$Data::Dumper::Deepcopy=1;

use POSIX qw(strftime);
use Time::HiRes( qw{tv_interval gettimeofday});
use sigtrap qw(handler trapCtlC INT QUIT);

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
my $DEBUG=0;
my $help=0;

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
	"debug!"  => \$DEBUG,
	"local-sysdba!" => \$localSysdba,
	"sysoper!",
	"z|h|help" => \$help );


usage(0) if $help;

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

# this SQL always returns values for each metric name, even if 0
$sql = q{select
   sess.username, sess.sid, sess.serial#,
   name.name name,
   stat.value value,
	to_char(sess.logon_time, 'yyyy-mm-dd_hh24-mi-ss') logon_time
from gv$sesstat stat, v$statname name, gv$session sess
where
   stat.sid = sess.sid
   and sess.username is not null
   and stat.statistic# = name.statistic#
	and sess.inst_id = stat.inst_id
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

($startExeTime) = [gettimeofday];
$sth->execute;
($endExeTime) = [gettimeofday];
$exeTime = tv_interval($startExeTime, $endExeTime);
warn sprintf("Exe Time: %$secondsFormat\n",$exeTime) if $showExeTime;

my ($elapsed,$timestamp,$startTime,$endTime);
($startTime) = [gettimeofday];

my %dataPrev=(); my %dataCurr=();

# get the first dataset outside the loop
while(my @ary = $sth->fetchrow_array) {
	#print join(',',@ary) . "\n";
	# first hash key: username
	# second hash key: session_id + serial#
	push @{$dataPrev{$ary[0]}->{"$ary[1]:$ary[2]"}}, $ary[4]; # sid:serial, value
}

# get data in a loop, up to max iterations
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
	debug( "-->> Timestamp: $timestamp\n");

	while(my @ary = $sth->fetchrow_array) {
		#print join(',',@ary) . "\n";
		#push @{$dataCurr{$ary[0]}->{"$ary[1]:$ary[2]:$ary[5]"}}, $ary[4]; # sid:serial:logon_time, value
		push @{$dataCurr{$ary[0]}->{"$ary[1]:$ary[2]"}}, $ary[4]; # sid:serial, value
	}

	debug( "************************************************************\n");
	my %dataDiff=();

	debug( '****>> %dataCurr: ' . Dumper(\%dataCurr) . "\n");

	foreach my $schema ( keys %dataCurr ) {

		# compare SID:SERIAL keys
		my @currKeys = map { $_ } keys %{$dataCurr{$schema}};
		#print "schema: $schema: " . '@currKeys: ' . Dumper(\@currKeys);
		debug( "schema: $schema: " . '@currKeys: ' . Dumper(\@currKeys));
		debug( "schema: $schema \%{dataPrev{$schema}} before: " . Dumper(\%{$dataPrev{$schema}}) . "\n");

		my $prevSetsAdded=0;
		# create a set of zero value metrics  for sessions that started after the previous interval time
		# this way, the full value of sqlnet io bytes will be counted for the interval, for this session
		foreach my $key (@currKeys) {
			if (! exists $dataPrev{$schema}{$key}) {
				debug( "==>> Adding empty set to \$dataPrev{$schema}->{$key}\n");
				$dataPrev{$schema}->{$key} = \@emptyMetrics;
				$prevSetsAdded++;
			}
		}

		if ( $prevSetsAdded ) {
			debug( "schema: $schema - empty sets added to prev metrics: $prevSetsAdded\n");
			debug( "schema: $schema \%{dataPrev{$schema}}  after " . Dumper(\%{$dataPrev{$schema}}) . "\n");
		}

		# remove metrics from the previous data set, when they do not appear in the current set
		# As the session statistics disappeared before we could get the current values, there is no way
		# to record any metrics from them
		# this amounts to lost data
		my @prevKeys = map { $_ } keys %{$dataPrev{$schema}};
		debug( "schema: $schema: " . '@prevKeys: ' . Dumper(\@prevKeys));
		debug( "schema: $schema \%{dataCurr{$schema}} before: " . Dumper(\%{$dataCurr{$schema}}) . "\n");

		my $prevSetsRemoved=0;
		foreach my $key (@prevKeys) {
			if (! exists $dataCurr{$schema}{$key}) {
				debug( "==>> Removing set from \$dataCurr{$schema}->{$key}\n");
				delete $dataPrev{$schema}->{$key};
				$prevSetsRemoved++;
			}
		}

		if ( $prevSetsRemoved ) {
			debug( "schema: $schema - sets removed from prev metrics: $prevSetsRemoved\n");
			debug( "schema: $schema \%{dataPrev{$schema}}  after: " . Dumper(\%{$dataPrev{$schema}}) . "\n");
		}

		debug( "==== calling parseMetrics() with \@prevMetrics schema: $schema \n");
		my @prevMetrics=parseMetrics(\%{$dataPrev{$schema}});
		debug( '=== returned @prevMetrics FULL: ' . Dumper(\@prevMetrics));
		
		debug( "==== calling parseMetrics() with \@currMetrics schema: $schema \n");
		my @currMetrics=parseMetrics(\%{$dataCurr{$schema}});
		debug( '=== returned @currMetrics FULL ' . Dumper(\@currMetrics));
		
	}

	# splice in timestamp and elapsed
	foreach my $schema (keys %dataCurr) {
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

# pass hash
# convert rows to columns
sub parseMetrics {
	my ($metricsHash) = @_;
	#print '$metricsHash: ' . Dumper($metricsHash);

	my @keysToUse = keys %{$metricsHash};

	my @prevMetrics=();

	debug( "======== parseMetrics() =============\n");
	debug( '-->> $metricsHash: ' . Dumper($metricsHash) . "\n");
	debug( '-->> @keysToUse ' . Dumper(\@keysToUse) . "\n");

	foreach my $sidSerial ( @keysToUse ) {
		#print "sidSerial: $sidSerial\n";
		my @workMetrics= ();
		eval { @workMetrics = @{$metricsHash->{"$sidSerial"}}; };

		# there was a bug that caused a completely empty set of values
		# to be created when a session began after the previous interval and before the current one
		# this trap is still here in the event the bug is not truly eradicated
		# 
		if ($@) {

			debug( "error in parseMetrics()\n");
			debug( 'SID-SERIAL: ' . "$sidSerial\n");
			debug( '$metricsHash: ' . Dumper($metricsHash));
			debug( '@keysToUse ' . Dumper(@keysToUse));

			#die;

		}
		foreach my $el ( 0 .. $#workMetrics ) {
			$prevMetrics[$el] += $workMetrics[$el];
		}
	}
	debug( '-->> @prevMetrics: ' . Dumper(\@prevMetrics));
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

  --database          target instance
  --username          target instance account name
  --password          target instance account password
  --sysdba				 logon as sysdba
  --sysoper				 logon as sysoper
  --iterations			 number of iterations
  --interval-seconds	 seconds per iteration
  --connection-test	 test the connection and exit
  --local-sysdba		 logon to local instance as sysdba. ORACLE_SID must be set
							 the following options will be ignored:
								-database
								-username
								-password
  -debug           print debug messages to STDERR
  example:


  $basename  -database oraserver\/orcl.abc.com -username scott -password tiger -interval-seconds 60 -iterations 7200

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

sub trapCtlC {

	$dbh->disconnect;
	die;

}

sub debug {
	return unless $DEBUG;
	my $msg = join(' ', @_);

	warn $msg . "\n";
	return;
}

