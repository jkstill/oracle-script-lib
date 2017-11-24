#!/usr/bin/env perl

use warnings;
use strict;

my $debug=0;

my $device = $ARGV[0];

die "please tell me which block device to check for Oracle ASM\n" unless $device;

=head1 asm-disk-chk.pl

 Used to determine if a disk is being used as an Oracle ASM disk.

 This is useful for use with hypervisors such as VirtualBox.

 Consider the following case:

 iSCSI blocks are being served by FreeNAS server oranas

 VirtualBox server vbox is running several Linux based Oracle RAC servers.

 Shared storage is being allocated as iSCSI devices configured within VirtualBox.

 There is no clear path to identify which iSCSI devices are being used as Oracle ASM devices on RAC nodes.

 This is not a complete solution, but it helps.

 See also VBoxManager showvminfo, as it it will show the devices per VM

 # VBoxManage showvminfo ora12c102rac02 | grep SATA
  Storage Controller Name (1):            SATA
  SATA (0, 0): /u01/vbox/machines/ora12c102rac02/Snapshots/{7ff048e3-f787-4e60-b402-cc1725b07709}.vdi (UUID: 7ff048e3-f787-4e60-b402-cc1725b07709)
  SATA (10, 0): oranas|iqn.2005-10.org.oranas.ctl:iscsi-01 (UUID: 982c8e68-58f6-497d-8ae7-f779e4ba0dbc)
  SATA (11, 0): oranas|iqn.2005-10.org.oranas.ctl:iscsi-02 (UUID: 6de4be1e-0a73-4a9a-b45e-00707ddd5c99)
  SATA (12, 0): oranas|iqn.2005-10.org.oranas.ctl:iscsi-03 (UUID: 2e604b95-d04c-4367-8fcf-775b4ea9121b)
  SATA (13, 0): oranas|iqn.2005-10.org.oranas.ctl:iscsi-04 (UUID: bea31190-293d-47c5-b119-788c4fb7bbd5)
  SATA (14, 0): oranas|iqn.2005-10.org.oranas.ctl:iscsi-05 (UUID: 4f359266-e91d-4cb5-aef5-d6529a85e552)
  SATA (15, 0): oranas|iqn.2005-10.org.oranas.ctl:iscsi-06 (UUID: 233a0e21-78da-4b18-ba68-67f4b12299ce)
  SATA (16, 0): oranas|iqn.2005-10.org.oranas.ctl:iscsi-07 (UUID: a5feb2bb-9f82-445b-9a6a-7fb89b740a9e)
  SATA (17, 0): oranas|iqn.2005-10.org.oranas.ctl:iscsi-08 (UUID: b0e1c3c9-c42c-4ceb-a2b3-de6e4c3c678e)
  SATA (18, 0): oranas|iqn.2005-10.org.oranas.ctl:iscsi-09 (UUID: b0a7476e-bf42-4803-b9d5-744296b2aa5e)

=cut

=head1 first sector

[root@jap iSCSI]# (dd if=/dev/sdk1 count=1 bs=512 2>/dev/null) | hexdump -C
00000000  01 82 01 02 00 00 00 00  02 00 00 80 43 de 2d 2c  |............C.-,|
00000010  f7 ab 17 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000020  4f 52 43 4c 44 49 53 4b  00 00 00 00 00 00 00 00  |ORCLDISK........|
00000030  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000040  00 00 10 0c 02 00 02 03  44 49 53 4b 31 35 00 00  |........DISK15..|
00000050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000060  00 00 00 00 00 00 00 00  44 41 54 41 00 00 00 00  |........DATA....|
00000070  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000080  00 00 00 00 00 00 00 00  46 47 41 00 00 00 00 00  |........FGA.....|
00000090  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|

=cut

die "$device must be a block device\n" unless -b $device;

open my $PART , '<', qq{$device};

die "cannot set binmode - $!\n" unless binmode $PART;

my ($asmTag,$diskName,$diskGroup,$failGroup);


$asmTag=readDisk($PART,32,30);
sanitize(\$asmTag);

print "ASM Tag: $asmTag\n" if $debug;

# if an oracle ASM Disk, get the disk name and failgroup

if ($asmTag eq 'ORCLDISK' ) {

	print "ASM Tag: $asmTag\n";

	$diskName=readDisk($PART,72,30);
	sanitize(\$diskName);
	print "Disk Name: $diskName\n";

	$diskGroup=readDisk($PART,104,30);
	sanitize(\$diskGroup);
	print "Disk Group: $diskGroup\n";

	$failGroup=readDisk($PART,136,30);
	sanitize(\$failGroup);
	print "Fail Group: $failGroup\n";

	if ( $failGroup eq $diskName ) {
		print "This disk is its own failgroup\n";
	}
} else {
	print "$device is not an Oracle ASM Disk\n";
}



close $PART;

sub sanitize {
	my $ref = shift;

	# was using this, but Oracle may change characters near the end of the 
	# 30 character name field to something other than 0x00
	#${$ref} =~ s/\000//g;

	# remove non-readable characters
	${$ref} =~ s/[^[:alnum:]]//g;
	
	print "sanitize ref: ${$ref}\n" if $debug;

	return $ref;
}


# always assumes whence is 0
# filehandle, seek, length
sub readDisk {
	my ($fh,$pos,$len) = @_;

	my $diskData;

	seek($fh,$pos,0);
	my $bytesRead = read ($fh,$diskData,$len,0);
	die "Failed to Read - $!\n" unless $bytesRead;
	#print("Bytes Read: $bytesRead\n");

	return $diskData;

}

