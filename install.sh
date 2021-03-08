#!/bin/bash

echo "This script will install arch linux."
sleep 1

# Set the keyboard layout
read -p "Keyboard layout (uk/us/br-abnt2) > " KEYBOARD_LAYOUT
echo "Setting keyboard to: $KEYBOARD_LAYOUT"
loadkeys $KEYBOARD_LAYOUT
sleep 1

# Update the system clock
timedatectl set-ntp true
timedatectl status
sleep 1

# Partition the disks
read -p "Swap partition size in G > " SWAP_SIZE
echo $SWAP_SIZE GB swap
fdisk -l
read -p "Type sdx > " DISK
echo "arch will be installed in $DISK"
sleep 1

# Verify the boot mode
if [[ -d /sys/firmware/efi/efivars ]]; then
  echo "Boot mode UEFI"
  BOOT=uefi
  (
  echo g # Create a new empty GPT partition table
  echo n # Add a new partition
  echo 1 # Partition number
  echo   # First sector (Accept default: 1)
  echo +512M # Last sector (Accept default: varies)
  echo t # Changing partition type
  echo 1 # Set type to EFI
  echo n # Add a new partition
  echo 2 # Partition number
  echo   # First sector (Accept default: 1)
  echo +"$SWAP_SIZE"G # Last sector (Accept default: varies)
  echo t # Changing partition type
  echo 2 # Choosing partition
  echo 19 # Set type to swap
  echo n # Add a new partition
  echo 3 # Partition number
  echo   # First sector (Accept default: 1)
  echo   # Last sector (Accept default: varies)
  echo w # Write changes
) | fdisk /dev/$DISK
  
  # Format the partitions
  echo "Formating partitions"
  mkfs.fat -F32 /dev/${DISK}1
  
  mkswap /dev/${DISK}2
  swapon /dev/${DISK}2

  mkfs.ext4 /dev/${DISK}3

  fdisk -l
  sleep 4

  # Mount the file systems
  echo "Mounting file systems."
  mount /dev/${DISK}3 /mnt
  mkdir /mnt/boot
  mkdir /mnt/boot/efi
  mount /dev/${DISK}1 /mnt/boot/efi
  
  sleep 2
else
  BOOT=bios
  echo "Boot mode BIOS"
  (
  echo o # Create a new empty DOS partition table
  echo n # Add a new partition
  echo   # Primary partition
  echo 2 # Partition number
  echo   # First sector (Accept default: 1)
  echo +"$SWAP_SIZE"G # Last sector (Accept default: varies)
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
  
  # Format the partitions
  echo "Formating partitions"
  mkswap /dev/${DISK}2
  swapon /dev/${DISK}2

  mkfs.ext4 /dev/${DISK}1

  fdisk -l
  sleep 4

  # Mount the file systems
  echo "Mounting file systems."
  mount /dev/${DISK}1 /mnt
  sleep 2
fi

echo "Mount home in another disk?"
select se in yes no; do
	case $se in
	
		yes)
		fdisk -l
		read -p "Type sdx > " DISKH
		(
		echo g # Create a new empty GPT partition table
		echo n # Add a new partition
		echo 1 # Partition number
		echo   # Primary partition
		echo   # First sector (Accept default: 1)
		echo   # Last sector (Accept default: varies)
		echo w # Write changes
		) | fdisk /dev/$DISKH

		mkfs.ext4 /dev/${DISKH}1
		mount /dev/${DISKH}1 /home
		break
		;;

		no)
		break
		;;

		*)
		echo "Invalid entry."
		;;
	esac
done

# Install essential packages
pacman -S reflector
reflector --sort rate -c 'Brazil' -f 10 --save /etc/pacman.d/mirrorlist
echo "Instaling essential packages."
pacstrap /mnt base linux linux-firmware git nano man-db man-pages texinfo networkmanager sudo curl

# Generate an fstab file
echo "Generating fstab file."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 1

# Change root into the new system:
echo "Change root into the new system."
echo -e "#!/bin/bash" >> install2.sh
echo -e "DISK=$DISK BOOT=$BOOT KEYBOARD_LAYOUT=$KEYBOARD_LAYOUT" >> install2.sh
cat post_chroot >> install2.sh
cp install2.sh /mnt
chmod +x /mnt/install2.sh
arch-chroot /mnt ./install2.sh
