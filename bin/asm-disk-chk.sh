#!/bin/bash

# on a virtual box server using iSCSI for RAC storage
# show which disks are used for ASM

banner='####################'

for device in /dev/sd?[1-4]
do

	echo "$banner $device $banner"	
	./asm-disk-chk.pl $device
done
