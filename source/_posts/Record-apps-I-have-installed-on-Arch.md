---
title: Record apps I have installed on Arch
date: 2018-06-18 00:55:14
tags:
---

## pacman

```shell
sudo pacman -S \
ttf-inconsolata noto-fonts-cjk powerline-fonts ttf-font-awesome \
ibus ibus-qt ibus-rime \
net-tools dnsutils inetutils iproute2 \
zsh terminator thunar\
vlc alsa-utils deadbeef cmus mupdf telegram-desktop \
go git openssh unzip unrar \
gnome gnome-tweaks numix-gtk-theme numix-circle-icon-theme-git \
wget ntfs-3g shadowsocks-qt5
```

## yaourt

```sh
yaourt -S google-chrome \
visual-studio-code-bin \
netease-cloud-music \
anaconda
```

> add anaconda to PATH

```sh
echo "export PATH=/opt/anaconda/bin:\$PATH" >> ~/.zshrc
```

## To be contine ...