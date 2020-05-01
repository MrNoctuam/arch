#! /bin/bash


set -euo pipefail


username="owl"
hostname="ironmk3"
timezone="Europe/Kaliningrad"


if [[ -e /var/lib/pacman/db.lck ]]
then
	echo "pacman lockfile detected, exit"
	exit 1
fi

if [[ -d /sys/firmware/efi/efivars/ ]]
then
	bootmode="uefi"
else
	bootmode="bios"
fi

grep -qi amd   /proc/cpuinfo && proctype="amd"
grep -qi intel /proc/cpuinfo && proctype="intel"

if [[ -z ${1-} ]]
then

	echo "computer booted in $bootmode mode"
	echo "press any key to continue..."
	read; clear

	timedatectl set-ntp true

	mountpoint -q "/mnt"	  && umount -l /mnt
	mountpoint -q "/mnt/boot" && umount -l /mnt/boot
	mountpoint -q "/mnt/home" && umount -l /mnt/home

	swapon -s &> /dev/null && swapoff --all
	# dd if=/dev/zero of=/dev/sda bs=512 count=1 status=none

	# /dev/sda1    /boot    512MiB
	# /dev/sda2    /root    40GiB
	# /dev/sda3    /swap    16GiB
	# /dev/sda4    /home    40GiB
	
	# if [[ $bootmode == "bios" ]]
	# then
	# 	parted -s /dev/sda -- mklabel msdos
	# 	parted -s /dev/sda -- mkpart primary       ext4	    1MiB   513MiB
	# 	parted -s /dev/sda -- mkpart primary       ext4   513MiB 41473MiB
	# 	parted -s /dev/sda -- mkpart primary linux-swap 41473MiB 57857MiB
	# 	parted -s /dev/sda -- mkpart primary       ext4	57857MiB 98817MiB
	# 	parted -s /dev/sda -- set 1 boot on

	# 	mkfs.ext4 -F /dev/sda1
	# fi

	# if [[ $bootmode == "uefi" ]]
	# then
	# 	parted -s /dev/sda -- mklabel gpt
	# 	parted -s /dev/sda -- mkpart     ESP      fat32     1MiB   513MiB
	# 	parted -s /dev/sda -- mkpart primary       ext4   513MiB 41473MiB
	# 	parted -s /dev/sda -- mkpart primary linux-swap 41473MiB 57857MiB
	# 	parted -s /dev/sda -- mkpart primary       ext4 57857MiB 98817MiB
	# 	parted -s /dev/sda -- set 1 boot on

	# 	parted -s /dev/sda -- name 1 "boot"
	# 	parted -s /dev/sda -- name 2 "root"
	# 	parted -s /dev/sda -- name 3 "swap"
	# 	parted -s /dev/sda -- name 4 "home"

	# 	mkfs.fat -F32 -I /dev/sda1
	# fi

	mkfs.ext4 -F /dev/sda1
	mkfs.ext4 -F /dev/sda2

	# mkswap /dev/sda3
	# swapon /dev/sda3

	mount /dev/sda1 /mnt
	# mkdir /mnt/boot && mount /dev/sda1 /mnt/boot
	mkdir /mnt/home && mount /dev/sda2 /mnt/home

	pacstrap /mnt base base-devel
	genfstab -U /mnt >> /mnt/etc/fstab

	cp $BASH_SOURCE /mnt/root
	chmod -x /root/$(basename $BASH_SOURCE) 
	arch-chroot /mnt /bin/bash -c "/root/$(basename $BASH_SOURCE) continue"

else

	set +e
	wireless=$(ls /sys/class/net | grep iw)
	ethernet=$(ls /sys/class/net | grep en)
	set -e

	ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
	hwclock --systohc --utc
	
	echo "LANG=en_US.UTF-8" > /etc/locale.conf
	sed -i "s/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g" /etc/locale.gen
	sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
	locale-gen
	
	echo "127.0.0.1    localhost"  > /etc/hosts
	echo "::1          localhost" >> /etc/hosts
	echo "127.0.0.1    $hostname" >> /etc/hosts
	echo "$hostname" > /etc/hostname

	sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

	if [[ -z $(id -u $username &> /dev/null) ]]
	then
		useradd -m -g users -G wheel,storage,power -s /bin/bash $username
	fi

	passwd $username
	passwd root
	
	sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
	pacman -Sy

	if [[ -e /mnt/boot/vmlinuz-linux ]]
	then
		rm -f /mnt/boot/vmlinuz-linux
	fi

	if [[ $proctype = "intel" ]]
	then
		pacman -S --noconfirm intel-ucode
	fi

	if [[ $bootmode = "bios" ]]
	then
		pacman -S --noconfirm grub
		grub-install --target=i386-pc /dev/sda
		grub-mkconfig -o /boot/grub/grub.cfg
	fi

	if [[ $bootmode = "uefi" ]]
	then
		bootctl install
		partuuid=$(blkid -s PARTUUID -o value /dev/sda2)

		echo "default    arch" > /boot/loader/loader.conf
		echo "timeout    3"   >> /boot/loader/loader.conf

		echo "title      archlinux" > /boot/loader/entries/arch.conf
		echo "linux      /vmlinuz-linux" >> /boot/loader/entries/arch.conf
		if [[ $proctype = "intel" ]]
		then
			echo "initrd     /intel-ucode.img" >> /boot/loader/entries/arch.conf
		fi		
		echo "initrd     /initramfs-linux.img" >> /boot/loader/entries/arch.conf
		echo "options    root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda2) rootfstype=ext4 add_efi_memmap" >> /boot/loader/entries/arch.conf
	fi

#	if [[ ! -z "$wireless" ]]
#	then
#
#	fi

	# if [[ ! -z "$ethernet" ]]
	# then
	# 	systemctl enable dhcpcd@$ethernet.service
	# fi

	pacman -Syu --noconfirm xorg xorg-xinit alsa-lib alsa-utils ntfs-3g wget tree neovim

#	if lspci | grep -qi radeon
#	then
#
#	fi

	if lspci | grep -qi nvidia
	then
		pacman -S --noconfirm nvidia-390xx nvidia-390xx-utils
	fi

fi
