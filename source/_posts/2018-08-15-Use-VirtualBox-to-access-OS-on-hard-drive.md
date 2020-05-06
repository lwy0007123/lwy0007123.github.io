---
title: 使用 VirtualBox 启动物理磁盘上的系统
date: 2018-08-15 23:00:43
tags:
- VirtualBox
---

# What

虽然已经主要在用 Arch 了，但是最近有朋友让我帮他改改 MFC 代码。
那么问题来了，我不想重启电脑切换系统，还要用windows给他调代码，怎么办？
用虚拟机吧，一般流程：新建一个虚拟机->装系统->搭开发环境->调代码(->删除虚拟机)。**麻烦**

<!--more-->

# How

既然虚拟机也要用虚拟硬盘文件装系统，何不挂载装有系统的硬盘直接用呢？ Google一下，这是可以的。

> 注意：运行虚拟机的硬盘最好与虚拟机挂载系统的硬盘分开，防止未知错误；重要数据最好备份下。

下面主要按照我的实际情况讲，我电脑里双系统分在两块硬盘上，win 在 /dev/sda，linux 在 /dev/sdb，这是最理想的，互不干扰。

1. root 权限下运行 VirtualBox

1. 新建一个windows虚拟机，添加虚拟硬盘时选择`Do not add a virtual hard drive`(不添加虚拟硬盘)，其他配置照常，然后保存。

1. 输入以下命令创建映射真实硬盘的虚拟硬盘文件：
    ```sh
    sudo VBoxManage internalcommands createrawvmdk -filename "</path/to/file>.vmdk" -rawdisk /dev/sda
    ```

    > `</path/to/file>.vmdk`换成你要保存虚拟硬盘的文件位置，例如 `~/vbox/win.vmdk`。
    > `/dev/sda`是我win的安装盘，你可以用`sudo fdisk -l`查看你的系统所在位置。
    > 以上命令是可以指定只映射某几个分区的，具体命令自己Google。

1. 设置windows虚拟机的存储设备（Settings->Storage->Add Hard Disk->Choose existing disk），找到上一步生成的vmdk文件添加即可。

1. 因为我的windows启动方式是EFI，所以在Settings->System中勾上`Enable EFI(special OSes only)`。

至此，可以启动了。

![result](result.gif)

> 顺便使用下Linux下的gif制作器 `peek`

# Refs

[Using a Physical Hard Drive with a VirtualBox VM]https://www.serverwatch.com/server-tutorials/using-a-physical-hard-drive-with-a-virtualbox-vm.html