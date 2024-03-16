#!/opt/oracle/product/23c/dbhomeFree//perl/bin/perl

use warnings;
use strict;
use FileHandle;
use DBI;
use Getopt::Long;
use Data::Dumper;

my %optctl = ();

my($db, $username, $password);
my ($help, $sysdba, $connectionMode, $localSysdba, $sysOper) = (0,0,0,0,0);
my ($sqlidFile,$minSeconds);

Getopt::Long::GetOptions(
	\%optctl,
	"database=s"	=> \$db,
	"username=s"	=> \$username,
	"password=s"	=> \$password,
	"sqlid-file=s"	=> \$sqlidFile,
	"min-seconds=s"	=> \$minSeconds,
	"sysdba!"		=> \$sysdba,
	"local-sysdba!"=> \$localSysdba,
	"sysoper!"		=> \$sysOper,
	"z|h|help"		=> \$help
);

$minSeconds ||= 60;

die usage() unless defined($sqlidFile);

die "cannot open $sqlidFile\n" unless -r $sqlidFile;

if (! $localSysdba) {

	$connectionMode = 0;
	if ( $sysOper ) { $connectionMode = 4 }
	if ( $sysdba ) { $connectionMode = 2 }

	usage(1) unless ($db and $username and $password);
}

open SQLID, '<' , $sqlidFile or die;

my @sqlids = <SQLID>;
close SQLID;
chomp @sqlids;

#print qq{
#
#USERNAME: $username
#DATABASE: $db
#PASSWORD: $password
    #MODE: $connectionMode
 #RPT LVL: @rptLevels
#};
#exit;


$SIG{INT}=\&dbCleanup;
$SIG{QUIT}=\&dbCleanup;
$SIG{TERM}=\&dbCleanup;


$|=1; # flush output immediately

my $dbh ;

if ($localSysdba) {
	$dbh = DBI->connect(
		'dbi:Oracle:',undef,undef,
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


my $sql=q{with data as (
	select sql_id, sql_exec_id, sql_exec_start,
		min(sample_time) start_time,
		max(sample_time) end_time,
		max(sample_time - sql_exec_start) duration
	from dba_hist_active_sess_history
	where sql_id = ?
	group by sql_id, sql_exec_id, sql_exec_start
	order by sql_exec_start, sql_id, sql_exec_id
),
rptdata as (
	select sql_id
		, sql_exec_id
		, to_char(sql_exec_start,'yyyy-mm-dd hh24:mi:ss') sql_exec_start
		, to_char(start_time,'yyyy-mm-dd hh24:mi:ss') start_time
		, to_char(end_time,'yyyy-mm-dd hh24:mi:ss') end_time
		, (extract(hour from duration) * 3600 )
			+ (extract(second from duration) * 60 )
			+ extract(second from duration) seconds
		, duration
	from data
)
select
	sql_id
	, sql_exec_id
	, sql_exec_start
	, start_time
	, end_time
	, duration
	, seconds
from rptdata
where seconds >= ?
order by 1,3};


my $sth = $dbh->prepare($sql,{ora_check_sql => 0});

my ($sqlID, $sqlExecID, $sqlExecStart, $startTime, $endTime, $duration);

foreach my $sqlid ( @sqlids ) {
	$sth->execute($sqlid, $minSeconds);
	($sqlID, $sqlExecID, $sqlExecStart, $startTime, $endTime, $duration) = ('','','','','','');
	while (  ($sqlID, $sqlExecID, $sqlExecStart, $startTime, $endTime, $duration) = $sth->fetchrow_array ) {
		next unless (  $sqlExecID && $sqlExecStart && $duration );
		write;
	#while (my @ary =  $sth->fetchrow_array) {
		#print join(' : ', @ary) . "\n'";
	}
	$sth->finish;
	$- = 0; # force new page by setting remaining lines available to zero
	#last;
}


$dbh->disconnect;

sub usage {
	my $exitVal = shift;
	$exitVal = 0 unless defined $exitVal;
	use File::Basename;
	my $basename = basename($0);
	print qq[


Get execution times per SQLID

usage: $basename

  --database      target instance
  --username      target instance account name
  --password      target instance account password
  --sysdba        logon as sysdba
  --sysoper       logon as sysoper
  --sqlid-file    file containing SQL_ID values
  --min-seconds   minimum seconds that SQL executed - default is 60
  --local-sysdba  logon to local instance as sysdba. ORACLE_SID must be set
                  the following options will be ignored:
                   --database
                   --username
                   --password

  example:


  run and save output to a log file:

  mkdir -p logs

  $basename --database orcl --username scott --password tiger --sqlid-file sqlids.txt > logs/sql-exe-times-awr-rpt_$(date +%Y-%m-%d_%H-%M-%S).log

  $basename --local-sysdba ...


  search a log for SQL that required 1+ hours to complete

  grep --color=never -E '[[:space:]][[:digit:]]{1}[1-9]{1}:[[:digit:]]{2}:[[:digit:]]{2}.[[:digit:]]{3}$' logs/sql-exe-times-awr-rpt_2024-03-14_20-26-41.log

  search a log for SQL that required 5+ minutes to complete

  grep --color=never -E '[[:space:]][[:digit:]]{2}:[[:digit:]]{1}[5-9]{1}:[[:digit:]]{2}.[[:digit:]]{3}$' logs/sql-exe-times-awr-rpt_2024-03-14_20-26-41.log

];
   exit $exitVal;
};

sub dbCleanup {
	$sth->finish;
	$dbh->disconnect;
	die "killed session\n";
}

format STDOUT_TOP =

SQL_ID        SQL_EXEC_ID  SQL_EXEC_START         START_TIME        END_TIME          DURATION
-----------------------------------------------------------------------------------------------------------------------

.

# fuyz8hr1trvxy : 2024-02-27 03:47:56 : 16777219 : 2024-02-27 03:48:02 : 2024-02-27 05:07:24 : +000000000 01:19:28.752

format STDOUT =
@<<<<<<<<<<<< @########### @<<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$sqlID, $sqlExecID, $sqlExecStart, $startTime, $endTime, $duration
.




