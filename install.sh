#!/bin/bash

echo "This script will install arch linux."

# Set the keyboard layout
keyboard_layout=us
echo "Setting keyboard to: $keyboard_layout"
loadkeys $keyboard_layout

# Update the system clock
timedatectl set-ntp true
timedatectl status

# Verify the boot mode
if [[ -d /sys/firmware/efi/efivars ]]; then
  echo "Boot mode UEFI"
else
  echo "Boot mode BIOS"
fi

# Partition the disks
fdisk -l
read -p "Type sdx > " DISK
echo "arch will be installed in $DISK"
