---
title: Record apps I have installed on Arch
date: 2018-06-18 00:55:14
tags:
- Linux
- Arch
---

# pacman

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
ntfs-3g deluge shadowsocks shadowsocks-qt5 \
gnome gnome-tweaks \
numix-gtk-theme
```

<!--more-->

# yay

```sh
sudo pacman -S git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay -S numix-circle-icon-theme-git \
capitaine-cursors \
google-chrome \
visual-studio-code-bin \
foxitreader \
anaconda
```

**To be contine ...**