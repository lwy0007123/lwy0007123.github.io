---
title: Install Arch Linux again
date: 2019-03-31 17:29:08
tags:
- Arch
- Linux
---

# What

Got a new 256G nvme ssd hard drive.

Install Arch Linux again.

<!--more-->

# Prepare

Download latest ISO file [here](https://www.archlinux.org/download/).

Check md5 with tools. e.g. `md5sum`  on linux.

Write ISO file in your usb driver.
> select `GPT` for EFI only

Plug in you usb drive and reboot into it.

# partition

```sh
# list all disks and partitions
fdisk -l

# my new ssd is `nvme0n1`
# make partition table with `cfdisk`
cfisk /dev/nvme0n1

# 512M EFI file system --> nvme0n1p1
# 218G Linux file system --> nvme0n1p2
# 20G swap space --> nvme0n1p3

# write then quit

# format new partitions
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkswap /dev/nvme0n1p3
swapon /dev/nvme0n1p3

# mount to /mnt
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

# Install

If your network special as China, I recommended you change pacman mirror first.

```sh
cd /etc/pacman.d
mv ./mirrorlist ./mirrorlist.bak
echo 'Server = http://mirrors.163.com/archlinux/$repo/os/$arch' > ./mirrorlist
```

Then follow the pase.

```sh
# Update you pacman database
pacman -Syy
# Install base and dev-base
pacstrap -i /mnt base base-devel
# Type enter enter enter ...

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Change root
arch-chroot /mnt

# set timezone, I live in China, so I use this timezone.
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# set localtime instead of UTC time, I want my windows have same time set.
hwclock --systohc -l

# Install vim first
pacman -S vim

# Localization
vim /etc/locale.gen
# uncommit follow lines and save
#en_US.UTF-8 UTF-8
#zh_CN.GBK GBK
#zh_CN.UTF-8 UTF-8
#zh_CN.GB2312
locale-gen
# set default locale
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Network
echo HOSTNAME > /etc/hostname
echo '127.0.0.1	localhost' >> /etc/hosts
echo '::1		localhost' >> /etc/hosts
echo '127.0.1.1	HOSTNAME.localdomain	HOSTNAME'  >>/etc/hosts

# dhcpcd enable
systemctl enable dhcpcd

# Initramfs
mkinitcpio -p linux

# set root password
passwd

# Boot loader install intel mocro-code
pacman -S intel-ucode

# use grub for boot manage
pacman -S grub efibootmgr os-prober
grub-install --efi-directory=/boot --bootloader-id=ArchLinux --recheck

# If your windows boot loader in other EFI partition, you can mount the partition,
# and copy `Boot` and `Microsoft` to your /boot/EFI/, otherwise, grub can not
# find your windows boot loader.

# set default boot on last saved one
vim /etc/default/grub
# GRUB_DEFAULT=saved
# GRUB_SAVEDEFAULT="true"

# generate grub.cfg
grub-mkconfig -o /boot/grub/grub.cfg

# install more apps
pacman -S iw wpa_supplicant dialog # wifi support
pacman -S ttf-dejavu wqy-microhei wqy-zenhei # font support
pacman -S alsa-utils # sound
pacman -S dosfstools # support NTFS usb driver
pacman -S zsh openssh

# exit, unmount and reboot
exit
umount -R /mnt
reboot
```

# After Install

## check network

```sh
# check if your network interfaces
ip link
# if state is DOWN, maybe you dhcpcd not run
systemctl start dhcpcd && systemctl enable dhcpcd
```

## new sudo user

```sh
# then add a new user, my username is shank
useradd -m -g users -s /bin/zsh shank
# new passord for new user
passwd shank
# set new user in sudo
echo 'shank ALL=(ALL) ALL' > /etc/sudoers.d/shank
```

## dual video card driver

```sh
# check you video card
lspci | grep VGA
# found my NVIDIA GTX 1060 here
# install driver for video card
pacman -S xf86-video-intel
pacman -S nvidia
pacman -S nvidia-libgl
pacman -S xorg-xrandr
nvidia-xconfig
```

## desktop environment

```sh
# Install an desktop manager
sudo pacman -S sddm

# Install an desktop environment
sudo pacman -S gnome

# enable the desktop manager
sudo systemctl enable sddm

# Install NetworkManager
sudo pacman -S networkmanager

# enable the NetworkManager
sudo systemctl enable NetworkManager

# then reboot
sudo reboot
```

## install yay

```sh
sudo pacman -S git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## more apps

```sh
sudo pacman -S \
ibus ibus-qt ibus-rime \
ttf-inconsolata noto-fonts-cjk \
powerline-fonts ttf-font-awesome \
net-tools dnsutils inetutils iproute2 \
zsh terminator thunar \
vlc alsa-utils deadbeef cmus telegram-desktop \
goldendict mplayer \
go git wget openssh unzip unrar \
ntfs-3g deluge shadowsocks-qt5 \
gnome gnome-tweaks \
numix-gtk-theme

yay -S numix-circle-icon-theme-git \
capitaine-cursors \
google-chrome \
visual-studio-code-bin \
foxitreader \
anaconda
```

# Ref

* [Installation guide](https://wiki.archlinux.org/index.php/EFI_system_partition)
