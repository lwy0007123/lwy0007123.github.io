---
title: Install vscode on Arch Linux
date: 2018-06-18 00:52:49
categories: Linux
tags:
- vscode
- Linux
- Arch
---

## Method 1: official binary version (recommend)

```sh
yaourt -S visual-studio-code-bin
```

## Method 2: open source build

first should modify open file limit on your device.

edit `/etc/security/limits.conf`

Add following lines to the end of file

```sh
*         hard    nofile      500000
*         soft    nofile      500000
root      hard    nofile      500000
root      soft    nofile      500000
```

Reboot (or log out and back in)

switch to root user `sudo su`

use `limit -n` to ensure the value is 500000

Then switch back to your user

Just like `su - shank`

Then run

```sh
sudo yaourt vscode
```

Then Type `4` to choose this one

```sh
4 aur/code 1.24.1-1 (143) (16.35)
    Microsoft Code -- The Open Source build of Visual Studio Code (vscode)
```

## reference

* [Increase “Open Files Limit”](https://easyengine.io/tutorials/linux/increase-open-files-limit/)