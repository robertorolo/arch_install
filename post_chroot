# Set the time zone
echo "Setting timezone."
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sleep 2

# Localization
echo "Setting localization"
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
echo -e "KEYMAP=$KEYBOARD_LAYOUT" >> /etc/vconsole.conf
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
echo -e "$rootpwd\n$rootpwd" | passwd
sleep 2

# Creating a user
read -p "Type user name > " username
read -p "Type user passwd > " userpwd
useradd -m -g users -G wheel $username
echo -e "$userpwd\n$userpwd" | passwd $username
echo -e "$username ALL=(ALL) ALL" >> /etc/sudoers
echo -e "%wheel    ALL=(ALL) ALL" >> /etc/sudoers
echo -e "root    ALL=(ALL:ALL) ALL" >> /etc/sudoers
sleep 2

# Instaling and configuring GRUB
pacman -S grub
if [ "$BOOT" == "bios" ]; then 
  grub-install --target=i386-pc /dev/$DISK
else
  exit 1
fi
grub-mkconfig -o /boot/grub/grub.cfg
sleep 2

# Finishing 
echo "We are done."
rm /mnt/install2.sh
