#!/usr/bin/env perl

use warnings;
no warnings 'portable';
use strict;
use IO::File;
use Math::BigInt;
use Fcntl qw(SEEK_SET SEEK_CUR SEEK_END);
use POSIX qw(sysconf _SC_PAGESIZE);
use Data::Dumper;
use Getopt::Long;

my @kflags;

my ($PID,$verbose,$showAllMem,$help,$includeHTB) = (0,0,0,0,0);

GetOptions (
	"pid=i" => \$PID,
	"verbose!" => \$verbose,
	"all-mem!" => \$showAllMem,
	"include-HTB!" => \$includeHTB,
	"h|help!" => \$help,
) or die usage(1);

usage() if $help;
usage(1) unless $PID;

=head1 procmem.pl

 Get the process memory by parsing the /proc/PID/pagemap file

 Skips pages where the PFN (Page Frame Number) is referenced more than once.

 The amount of memory in each frame is tallied up and the total displayed at the end

=cut


=head2 parsing pagemap - references
=over

 https://www.kernel.org/doc/Documentation/vm/pagemap.txt
 https://www.perlmonks.org/?node_id=1216644
 https://stackoverflow.com/questions/50861092/perl-how-to-parse-proc-pid-pagemap-entries
 https://github.com/dtrace4linux/linux/blob/master/tools/pagemap.pl

=back
=cut

=head2 Notes
=over

  The --include-HTB | --no-include-HTB option may not work as you expect.

  I find that some HugeTables in Linux 7, 4.14.35-1902.5.2.2.el7uek.x86_64, do not have the Flag set.

  Try this command - if any HugeTables appear, it would seem the HUGE flag is not set in /page/kpageflags

    procmem.pl --pid PID  --all-mem --no-include-HTB --verbose

  Or even possibly, it is a bug in this script.

  Reading the flags is working correctly though on many entries.

=back
=cut

=head2 ToDo
=over

 Done: Add in the flags from /proc/kpageflags
 This would allow elimating HugeTables when the --all-mem flag is used


=back
=cut

my $PAGESIZE=sysconf(_SC_PAGESIZE);
my $pagemapEntrySize=8;

my $mapsFH = IO::File->new;
my $pmFH = IO::File->new;
my $pgCountFH = IO::File->new;
my $pgFlagsFH = IO::File->new;

$mapsFH->open("/proc/$PID/maps",'r') or die "cannot open maps - $!\n";
$pmFH->open("/proc/$PID/pagemap",'r') or die "cannot open pagemap - $!\n";
$pgCountFH->open('/proc/kpagecount','r') or die "cannot open /proc/kpagecount - $!\n";
$pgFlagsFH->open('/proc/kpageflags','r') or die "cannot open /proc/kpageflags - $!\n";

binmode $pmFH;
binmode $pgCountFH;
binmode $pgFlagsFH;

my @memSegments=();

while (my $line=<$mapsFH>) {
	chomp $line;

	my @els = split(/\s+/,$line);

	my ($memSize,$data) = readPgMap($pmFH, $els[0]);  # first element is address range. eg: 0xFF00-0xFFFF
	next unless $data; # last line in maps will fail

	# page frame number

	my $pfn = $data & 0x7FFFFFFFFFFFFF;

	my $pgCount = pageCount($pgCountFH,$pfn);

	next unless $showAllMem || $pgCount == 1;

	my @flags = getFlags($pmFH,$pfn);
	if ( $showAllMem ) {
		if ( ! $includeHTB ) {
			if ( grep(/^HUGE$/,@flags) ) {
				next;
			}
		}
	}

	if ($verbose) {
		print "line: $line\n";
		printf("pfn: %08X\n",$pfn);
		print "memSize: ${memSize}K\n";
		printf("data:  %064b\n",$data);
		print "flags: " . join(' - ', sort @flags ) . "\n" if @flags;
		printf("pgCount: %08X\n",$pgCount);
	}

	push @memSegments, $memSize;  # in K-Bytes

	my $memCategory = memCategory($data);
	chomp $memCategory;

	if ($verbose) {
		print "$memCategory\n";
		print "=================\n";
	}

}

my $totalPrivateMem =0;
foreach my $memSeg ( @memSegments ) {
	$totalPrivateMem += $memSeg;
}

if ($verbose) { print "Mem Used: " ;}

print "${totalPrivateMem}K\n";

#print Dumper(\@memSegments);
#print "flags: " . join(" - " , @kflags). "\n";

sub pageCount {
	my ($fh,$pfn) = @_;

	my ($t,$count);

	if ( ! $fh->seek($pfn * 8,SEEK_SET) ) {
		die "seek failed in pagecount - $!\n";
	}

	if ( ! $fh->sysread($t,8) ) {
		die "sysread on pagecount failed - $!\n";
	}

	$count = unpack("q", $t);

	return $count;
}

sub getFlags {
	my ($fh,$pfn) = @_;

	my $t;

	if ( ! $fh->seek($pfn * 8, SEEK_SET) ) {
		die "seek failed in kpageflags - $!\n";
	}

	if ( ! $fh->sysread($t, 8) ) {
		die "sysread on kpageflags failed - $!\n";
	}

	my @flags;
	my $flags = unpack("q", $t);

	for (my $i = 0; $kflags[$i]; $i++) {
		if ($flags & (1 << $i)) {
			# kflags is global
			push @flags, $kflags[$i];
		}
	}

	return @flags;
}

sub memCategory {
	my $data = shift;

	my $category;

	if ( $data & (1<<63) ) {
		$category = "Memory Resident\n";
	} elsif ( $data & (1<<62) )  {
		$category = "Memory Swapped\n";
	} elsif ( $data & (1<<61) )  {
		$category = "Memory is file page or shared-anon\n";
	} elsif ( $data & (1<<56) )  {
		$category = "Exclusively Mapped\n";
	} elsif ( $data & (1<<55) )  {
		$category = "Page Table Entry: soft-dirty\n";
	} else {
		$category = "Memory type not yet categorized \n";
	}

	return $category;
}


sub readPgMap { # ($pmFH, $els[0]);  # first element is address range. eg: 0xFF00-0xFFFF
	my ($pmFH,$addressRange) = @_;

	my ($hexAddress1, $hexAddress2) = split(/-/, $addressRange);

	my $address1 = Math::BigInt->new("0x$hexAddress1");
	my $address2 = Math::BigInt->new("0x$hexAddress2");
	my $memSize = $address2 - $address1 >> 10; # k-bytes

	my $offset  = ($address1 / $PAGESIZE) * $pagemapEntrySize;

	# now seek in pagemaps to memory location and read 8 bytes
	$pmFH->seek($offset,SEEK_SET) or die "could not seek in pagemap\n";

	my $data;
	my $bytes; # read first 64 bits (8 bytes)

	if ( $pmFH->sysread($bytes,8) ) {
		$data = unpack('Q',$bytes);
	} else {
		# usually fails on final entry in maps
		$data='';	
	}

	return ($memSize, $data);
}

sub usage {

	my $exitVal = shift;
	use File::Basename;
	my $basename = basename($0);
	print qq{
$basename

usage: $basename - get memory usage for a PID

   $basename --file --pid 123 --verbose

--pid          The PID to use
--all-mem      Show all memory - default is private memory only
--include-HTB  Include HugeTable memory - default is to exclude HugeTables
--verbose      Be verbose

examples here:

   $basename --PID 123
};

	exit eval { defined($exitVal) ? $exitVal : 0 };
}


BEGIN {

# as per current https://www.kernel.org/doc/Documentation/vm/pagemap.txt

@kflags = qw (
	LOCKED
	ERROR
	REFERENCED
	UPTODATE
	DIRTY
	LRU
	ACTIVE
	SLAB
	WRITEBACK
	RECLAIM
	BUDDY
	MMAP
	ANON
	SWAPCACHE
	SWAPBACKED
	COMPOUND_HEAD
	COMPOUND_TAIL
	HUGE
	UNEVICTABLE
	HWPOISON
	NOPAGE
	KSM
	THP
	BALLOON
	ZERO_PAGE
	IDLE
);

}

