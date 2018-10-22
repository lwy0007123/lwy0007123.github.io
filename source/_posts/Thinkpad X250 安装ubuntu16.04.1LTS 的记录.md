---
title: Thinkpad X250 安装ubuntu16.04.1LTS 的记录
date: 2016-10-01 21:11:38
categories: Linux
tags: 
- Linux
- Terminator
- ZSH
---

X250 上有两块硬盘，sda有win10，sdb一直坐为数据盘，打算安装一个ubuntu16.04.01LTS。
因为轻度使用所以sdb上切20G的分区给ubuntu，压缩卷后不需要新建分区。
U盘制作ubuntu安装盘，开机启动到U盘。

<!--more-->

安装时，对空闲20G手动分区 ：

| 分区类型 | 挂载点   | 大小     | 位置   |
| :--- | :---- | :----- | :--- |
| 主分区  | /boot | 400M   | 起始   |
| 逻辑区  | /     | 15000M | 起始   |
| 逻辑区  | swap  | 512M   | 末尾   |
| 逻辑区  | /home | 剩余所有   | 起始   |

因为我不希望ubuntu覆盖我的windows引导，所以启动选择器 sdb
（因为内存有8G，交换空间就不分那么多了。启动选择在第二快盘，就不会覆盖win的引导，倒时开机bios改下硬盘启动顺序就行了。
我可能随时会把ubuntu的分区格掉，毕竟ssd空间有限，到时候不至于用easybcd或者PE重做引导）
安装完成后，重启。

**安装burg，美化开机选择界面：**

```shell
sudo add-apt-repository ppa:n-muench/burg && sudo apt-get update
sudo apt-get install burg burg-themes burg-emu
```

安装过程可以一路回车，注意在Configuring burg-pc时选择sdb。
更换burg themes ，下载Lightness BURG Theme by SWOriginal
解压后cp到/boot/burg/themes里。

```shell
sudo update-burg
gedit /boot/burg/burg.cfg
```

删除一个recoverymode引导，提前win引导项
sudo burg-emu -> F2 -> 选择Lightness
(每次grub更新后都要重置burg sudo burg-install /dev/sdx )



**安装指纹识别fingerprint：**

```shell
sudo add-apt-repository ppa:fingerprint/fprint && sudo apt-get update
sudo apt-get install libfprint0 fprint-demo libpam-fprintd gksu
```

在 “系统设置” -> “用户账户” 里会多一个 “指纹登录”，照着提示进行设置就可以了。

**关闭鼠标加速：**
在Dashboard里搜索:
gnome-session-properties
点击添加：
名称：setmouse
命令：xset m 0 或者 xset m default
重启。

**安装TLP电源管理：**

```shell
sudo apt-get install tlp tlp-rdw
sudo apt-get install tp-smapi-dkms acpi-call-dkms
sudo apt-get install thermald
sudo apt-get install powertop
```

配置 TLP

```shell
sudo vim /etc/default/tlp
sudo tlp start
```


**使用 terminator [替换默认终端以及使用zsh](/2016/10/01/使用%20Terminator%20%20&%20ZSH的配置/)** (另外写一篇介绍这个)

**安装Arc GTK主题：**

```shell
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list"
wget http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key
sudo apt-key add - < Release.key
sudo apt update
sudo apt install arc-theme
```

安装Unity Tweak Tool管理主题：

```shell
sudo apt install unity-tweak-tool
```



个人觉得Arc-darker 好看，更换之。

**安装Deadbeef，播放更多音频：**

```shell
sudo add-apt-repository ppa:starws-box/deadbeef-player
sudo apt-get update
sudo apt-get install deadbeef
```




**安装MPV播放器：**

```shell
sudo apt-get install mpv
```




**安装cherrytree笔记本：**

```shell
sudo apt-get install cherrytree
```




**安装lantern翻墙：**
[传送门](https://github.com/getlantern/forum/issues/833)