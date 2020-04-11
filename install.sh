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
  exit 1
else
  echo "Boot mode BIOS"
  (
  echo o # Create a new empty DOS partition table
  echo n # Add a new partition
  echo   # Primary partition
  echo 2 # Partition number
  echo   # First sector (Accept default: 1)
  echo +$SWAP_SIZE # Last sector (Accept default: varies)
  echo t # Changing partition type
  echo 82 # Set type to swap
  echo n # Add a new partition
  echo   # Primary partition
  echo 1 # Partition number
  echo   # First sector (Accept default: 1)
  echo   # Last sector (Accept default: varies)
  echo a # Flag as boot
  echo 1 # Partition number to flag as boot
  echo w # Write changes
) | fdisk /dev/$DISK
fi

# Format the partitions
echo "Formating partitions"
mkswap /dev/${DISK}2
swapon /dev/${DISK}2

mkfs.ext4 /dev/${DISK}1

fdisk -l
sleep 4

# Mount the file systems
echo "Mounting file systems. /dev/${DISK}1 /mnt"
mount /dev/${DISK}1 /mnt
sleep 2

# Install essential packages
echo "Instaling essential packages."
pacstrap /mnt base linux linux-firmware git vim man-db man-pages texinfo networkmanager

# Generate an fstab file
echo "Generating fstab file."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 1

# Change root into the new system:
echo "Change root into the new system."
arch-chroot /mnt

# Set the time zone
echo "Setting timezone."
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sleep 2

# Localization
echo "Setting localization"
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
cat KEYMAP=$KEYBOARD_LAYOUT >> /etc/vconsole.conf
sleep 2

# Network configuration
echo "Configuring network"
echo arch >> /etc/hostname

echo 127.0.0.1	localhost >> /etc/hosts 
echo ::1		localhost >> /etc/hosts
echo 127.0.1.1	arch.localdomain	arch >> /etc/hosts
sleep 2

# Creating a new initramfs
echo "Creating a new initramfs."
mkinitcpio -P
sleep 2

# Setting root password
read -p "Type root passwd > " rootpwd
passwd $rootpwd
sleep 2

# Creating a user
read -p "Type user name > " username
read -p "Type user passwd > " userpwd
useradd -m -g users -G wheel $username
passwd $userpwd
echo $username ALL=(ALL) ALL >> /etc/sudoers
echo %wheel    ALL=(ALL) ALL >> /etc/sudoers
sleep 2

# Instaling and configuring GRUB
pacman -S grub
grub-install -–target=i386-pc -–recheck /dev/$DISK
grub-mkconfig -o /boot/grub/grub.cfg
sleep 2

# Finishing 
echo "We are done."
exit
