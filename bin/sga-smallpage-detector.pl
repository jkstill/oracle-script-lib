#!/usr/bin/env perl

=head1 sga-smallpage-detector.pl

 This script will detect Oracle SGA segments that are not using HugePages on Linux servers

 It works by getting the pid and sid of all the ora_pmon_<SID> processes

 Then the memory segment maps are captured from /proc/PID/smaps

 If the segment is over a few megabytes in size, and the KernelPageSize for the segment is < 2M, then a warning is printed

 sample output:

 ##############################
 PID: 161290 SID: cdb01
 shmid: 1272971277
   segment size: 20971520
   kernelPageSize: 2097152
 shmid: 1273233429
    skipping due to small segment size
 shmid: 1273167891
   segment size: 115343360
   kernelPageSize: 2097152
 shmid: 1273069584
   segment size: 48184164352
   kernelPageSize: 2097152
 ##############################
 PID: 161729 SID: cdb02
 shmid: 1273561128
   segment size: 20971520
   kernelPageSize: 2097152
 shmid: 1273823280
   segment size: 67108864
   kernelPageSize: 2097152
 shmid: 1274052663
    skipping due to small segment size
 shmid: 1274019894
   segment size: 48234496
   kernelPageSize: 2097152
 shmid: 1273921587
   segment size: 21340618752
   kernelPageSize: 4096
 !!! sid: cdb02 pid: 161729 shmid: 1273921587 is not using HugePages !!!

=cut

=head1 Author

 Jared Still 2021
 jkstill@gmail.com

=cut

use strict;
use warnings;
use Data::Dumper;
use IO::File;

my @sgaIPCS = qx(ipcs -m | grep oracle );

chomp @sgaIPCS;

#print Dumper(\@sgaIPCS);

my %sgaSegments;

foreach my $ipcsLine (@sgaIPCS) {
	my ($shmid,$bytes) = (split(/\s+/,$ipcsLine))[1,4];
	$sgaSegments{$shmid}=$bytes;
}

#print Dumper(\%sgaSegments);

my %pmonPids;

#my @pmonPidStrings = qx(ps -e -o pid,cmd	| grep ora_[p]mon ); # | awk '{ print \$1 }' );
#chomp @pmonPidStrings;

foreach my $pidStr ( qx(ps -e -o pid,cmd	| grep ora_[p]mon ) ) {
	my($pid,$cmd) = split(/\s+/,$pidStr);	
	my $sid = (split(/_/,$cmd))[2];
	#print "pid: $pid: sid: $sid cmd: $cmd\n";
	$pmonPids{$pid} = $sid;
}

#print Dumper(\@pmonPidStrings);
 
#exit;

my $segmentMinSize = 4 * 2**20;

#print Dumper(\@pmonPids);

foreach my $pid (keys %pmonPids) {
	my $sid = $pmonPids{$pid};
	print "##############################\n";
	print "PID: $pid SID: $sid\n";
	my %sgaSegMaps=();

	# shared memory segments appear as /SYSV[0-9]+ (deleted)
	my $ph = IO::File->new;
	$ph->open("/proc/$pid/smaps",'r') || die "could not open /proc/$pid/smaps for reading - $!\n";
	my @smaps = <$ph>;
	chomp @smaps;

	#print Dumper(\@smaps);

	my $startFlag = 'SYSV';
	my $endFlag = 'VmFlags:';

	my $inRecord = 0;

	my $tmpRec=();

	my $shmid;
	foreach my $mapline (@smaps) {

		#print "line: $mapline\n";
		#print "in Record: $inRecord\n";

		if ( $inRecord ) {

			if ( $mapline =~ /$endFlag/ ) {
				$inRecord = 0;
				push @{$tmpRec}, $mapline;
				$sgaSegMaps{$shmid} = $tmpRec;
				#print Dumper(\@tmpRec);
				$tmpRec = ();
				next;
			} else {
				push @{$tmpRec}, $mapline;
			}

		} else {

			if ( $mapline =~ /$startFlag/ ) {
				#print "	in record\n";
				$inRecord = 1;
				$shmid = (split(/\s+/,$mapline))[4];
				#print "shmid: $shmid\n";
			} else {
				next;
			}

		}

	}
	
	#print Dumper(\%sgaSegMaps);

	foreach my $shmid ( keys %sgaSegMaps ) {
		print "shmid: $shmid\n";
		if ( ! exists $sgaSegments{$shmid} ) {
			warn "could not find $shmid in ipcs\n";
			next;
		}

		my ($segmentSizeStr) = grep(/^Size:/,@{$sgaSegMaps{$shmid}}) ;
		my $segmentSize = (split(/\s+/,$segmentSizeStr))[1] * 1024;

		if ($segmentSize < $segmentMinSize) {
			print "	 skipping due to small segment size\n";
			next;
		}

		#print "	min segment size: $segmentMinSize\n";
		print "	segment size: $segmentSize\n";

		my ($kernelPageSizeStr) = grep(/^KernelPageSize:/,@{$sgaSegMaps{$shmid}}) ;
		my $kernelPageSize = (split(/\s+/,$kernelPageSizeStr))[1] * 1024;

		print "	kernelPageSize: $kernelPageSize\n";

		if ($kernelPageSize < 2 * 2**20) {
			print "!!! sid: $sid pid: $pid shmid: $shmid is not using HugePages !!!\n";
		}

	}

}



