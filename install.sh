#!/bin/bash

echo "This script will install arch linux."
sleep 3

# Set the keyboard layout
keyboard_layout=us
echo "Setting keyboard to: $keyboard_layout"
loadkeys $keyboard_layout
sleep 3

# Update the system clock
timedatectl set-ntp true
timedatectl status
sleep 3

# Partition the disks
fdisk -l
read -p "Type sdx > " DISK
echo "arch will be installed in $DISK"
sleep 3

# Verify the boot mode
if [[ -d /sys/firmware/efi/efivars ]]; then
  echo "Boot mode UEFI"
else
  echo "Boot mode BIOS"
fi
