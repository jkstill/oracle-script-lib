#!/usr/bin/env perl

use warnings;
use strict;
use FileHandle;
use DBI;
use Getopt::Long;
use Data::Dumper;

my %optctl = ();

my($db, $username, $password);
my $help = 0;
my $sleepTime=0;

Getopt::Long::GetOptions(
	\%optctl,
	"database=s"	=> \$db,
	"username=s"	=> \$username,
	"password=s"	=> \$password,
	"sleeptime=i"	=> \$sleepTime,
	"z|h|help"		=> \$help
);


$|=1; # flush output immediately

my $dbh = DBI->connect(
	'dbi:Oracle:' . $db,
	$username, $password,
	{
		RaiseError => 1,
		AutoCommit => 0,
	}
);

die "Connect to  $db failed \n" unless $dbh;
$dbh->{RowCacheSize} = 100;


=head1

-- runs until told to die

set serveroutput on size unlimited
col idle_time_target new_value idle_time_target

select '&1' idle_time_target from dual;

declare
	v_control_command idle_user.idle_session_control.control_command%type;
begin

		while true
		loop
			select control_command into v_control_command from idle_user.idle_session_control;

			if v_control_command = 'DIE' then
				exit;
			elsif v_control_command = 'LIVE' then
				sys.dbms_lock.sleep(&idle_time_target);
			else
				dbms_output.put_line('something went wrong');
				exit;
			end if;
			
		end loop;

end;
/


=cut

my $sql=q{select control_command from idle_user.idle_session_control};
my $sth = $dbh->prepare($sql,{ora_check_sql => 0});

while (1) {
	$sth->execute;
	my ($ctlCmd) = $sth->fetchrow_array;
	$sth->finish;

	if ($ctlCmd eq 'DIE') {
		last;
	} elsif ($ctlCmd eq 'LIVE') {
		sleep $sleepTime;
	}

}

$dbh->disconnect;

sub usage {
	my $exitVal = shift;
	$exitVal = 0 unless defined $exitVal;
	use File::Basename;
	my $basename = basename($0);
	print qq/

usage: $basename

  -database      target instance
  -username      target instance account name
  -password      target instance account password
  -sysdba        logon as sysdba
  -sysoper       logon as sysoper
  -local-sysdba  logon to local instance as sysdba. ORACLE_SID must be set
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



