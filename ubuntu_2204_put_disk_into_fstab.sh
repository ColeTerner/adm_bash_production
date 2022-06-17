#!/bin/bash

#1)Checking physical disk...
echo "1.Checking plugged hard disks..."
sudo fdisk -l

echo "Are you seeing your disk up there?(y/n)"
read answer

#2)Extracting the UUID for that disk
echo "2.Extracting theid UUID..."

if [ $answer == "y" ]; then
	sudo blkid
	echo "Copy his UUID!!!"
fi

#3)Put an signature into the /etc/fstab
echo "3.Putting new signature to the end of file /etc/fstab..."

echo "Past UUID of the disk here"
read uuid
echo "Which mount point will be used to join the hard disk?(/mnt/jar...)"
read mount
echo "Which file system will be used?"
read file_system

sudo mkdir -p $mount
#signature to the file
echo "UUID=$uuid $mount        $file_system             defaults        0      2" | tee -a /etc/fstab

