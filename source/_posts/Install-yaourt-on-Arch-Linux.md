---
title: Install yaourt on Arch Linux
date: 2018-06-18 00:48:48
categories: Linux
tags:
- Linux
- Arch
---

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