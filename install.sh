#!/bin/bash

echo "This script will install arch linux."
sleep 1

# Set the keyboard layout
KEYBOARD_LAYOUT=us
echo "Setting keyboard to: $KEYBOARD_LAYOUT"
loadkeys $KEYBOARD_LAYOUT
sleep 1

# Update the system clock
timedatectl set-ntp true
timedatectl status
sleep 1

# Partition the disks
SWAP_SIZE=1G
fdisk -l
read -p "Type sdx > " DISK
echo "arch will be installed in $DISK"
sleep 1

# Verify the boot mode
if [[ -d /sys/firmware/efi/efivars ]]; then
  echo "Boot mode UEFI"
else
  echo "Boot mode BIOS"
  (
  echo o # Create a new empty DOS partition table
  echo n # Add a new partition
  echo   # Primary partition
  echo   # Partition number
  echo   # First sector (Accept default: 1)
  echo   # Last sector (Accept default: varies)
  echo a # Flag as boot
  echo w # Write changes
) | fdisk /dev/$DISK
fi

# Format the partitions
echo "Formating partitions"
#mkswap /dev/${DISK}1
#swapon /dev/${DISK}1

mkfs.ext4 /dev/${DISK}1
fdisk -l
sleep 1

# Mount the file systems
echo "Mounting file systems."
mount /dev/${DISK}1 /mnt
sleep 2

# Install essential packages
echo "Instaling essential packages."
pacstrap /mnt base linux linux-firmware

# Generate an fstab file
echo "Generating fstab file."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 1

# Change root into the new system:
echo "Change root into the new system."
arch-chroot /mnt
