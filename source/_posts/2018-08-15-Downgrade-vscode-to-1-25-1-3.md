---
title: Downgrade vscode to 1.25.1-3
date: 2018-08-15 22:07:06
categories: Linux
tags:
- VS Code
- Linux
---

# Sunny day

Happy to update vscode to 1.26.0-2 this morning.

<!--more-->

> How to update?

Just type

```sh
sudo pacman -S visual-studio-code-bin
```

# Awful user experience

This new [feature](https://code.visualstudio.com/updates/v1_26#_custom-title-bar-and-menus-for-windowslinux) driven me upgrade to this version.

But I would say it's a bad idea.

1. Title bar is more wide on linux. (ugly)
1. Title text not align center on top. (too ugly)

The feature on UI I can choose to ignore it. Because it's disabled in default settings.

**BUT** I can't tolerate the new bug. If I try to `Open Folder...[Ctrl+K Ctrl+O]`, the editor will crash.(OS: Arch Linux x86_64, Kernel: 4.17.14-arch1-1-ARCH, WM: i3)

so I need to downgrade.

# How to downgrade

I installed vscode via `yaourt`, but it's not support downgrade option. So I google this problem.

Someone said `Old packages are normally kept in: /var/cache/pacman/pkg/`

So check the directoy by `ls -l /var/cache/pacman/pkg/visual-studio-code-*`, I got this

```sh
-rw-r--r-- 1 root root 47360116 Jul 13 18:20 /var/cache/pacman/pkg/visual-studio-code-bin-1.25.1-1-x86_64.pkg.tar.xz
-rw-r--r-- 1 root root 47352676 Aug  5 02:39 /var/cache/pacman/pkg/visual-studio-code-bin-1.25.1-3-x86_64.pkg.tar.xz
-rw-r--r-- 1 root root 56026160 Aug 14 18:36 /var/cache/pacman/pkg/visual-studio-code-bin-1.26.0-2-x86_64.pkg.tar.xz
```

Soooo lucky!

Just use pacman to reinstall the pkg

```sh
sudo pacman -U /var/cache/pacman/pkg/visual-studio-code-bin-1.25.1-3-x86_64.pkg.tar.xz
```

_Awsome `pacman`, save my life!_

# Refs

[how to downgrade via yaourt](https://bbs.archlinux.org/viewtopic.php?id=95959)