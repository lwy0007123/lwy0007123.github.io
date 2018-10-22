---
title: Install yay (or yaourt) on Arch Linux
date: 2018-06-18 00:48:48
categories: Linux
tags:
- Linux
- Arch
---
# How to install [yay](https://github.com/Jguer/yay) (another great AUR helper)

> Update on 2018/10/16

## **[Recommended]** Use `yay` to replace `yaourt`

If you already got `yaourt` just type:

```sh
yaourt -S yay
```

<!--more-->

Otherwise, you can also install by `makepkg`

```sh
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## **[Deprecated]**~~Install `yaourt`~~

```sh
sudo vim /etc/pacman.conf
```

Then, add following lines to the end.

```sh
[archlinuxcn]
Server = http://repo.archlinuxcn.org/$arch
```

Install the GPG key.

```sh
sudo pacman -S archlinuxcn-keyring
```

Finally, update and install yaourt.

```sh
sudo pacman -Sy yaourt
```

Done!

[reference](https://www.archlinuxcn.org/archlinux-cn-repo-and-mirror/)