---
title: 重装Ubuntu的配置及折腾rEFInd
date: 2017-01-17 14:52:14
categories: Linux
tags: 
- EFI
- Linux
- Ubuntu
- rEFInd
---

为什么突然会折腾这个？因为我格盘重装了系统，因为强迫症发作，以前装得win10竟然不是EFI+GPT……虽然装固态上，启动速度没有区别，但我就是要折腾……既然折腾完了，全部过程记录下，不愿看这么多，也可以直接跳到[rEFInd的配置](#refind)。

### 先安装win10

用[官方工具](https://www.microsoft.com/zh-cn/software-download/windows10)做一个安装盘，bios选择中启动方式**EFI Only**，并开启**Secure Boot** 。（_对，网上那些辣鸡教程都TM教你关掉，但是不告诉你原因，听我的，不用关，装ubuntu也不用关，因为ubuntu申请了EFI安全证书的！_）

接着开机插入U盘，按提示安装就好，记得把分区方式改成**GPT**。（_若你之前是MBR，要么把原来分区全删掉，要么按网上教程做个EFI+MBR，反正我是强迫症，我就要格盘！_）

如何辨别是不是EFI启动呢？

win + R ，输入 msinfo32 ，回车，引导方式那行是 EFI 就对了。

### 再安装ubuntu16.04

这个更简单，把官方iso镜像文件，直接解压到**FAT32**格式U盘的根目录，开机，进U盘，安装。到那个然要现在win下切好未分配空间，这次我切了40G。小本子有8G内存，swap分区完全不用分的。在之前我试过所有未分配空间都挂到根目录，一样用着好好的，只有一点问题，只能挂起，不能休眠。

那么这次的分区方案是8G的swap，剩下全挂 / 根目录。 启动器挂在ubuntu所在硬盘，我是在第二快硬盘 /dev/sdb 上。

### ubuntu配置记录

**先要感谢[plum的博客](https://plumz.me/)，看他的博客让我解决的不少问题**

既然用了一段时间的ubuntu，解决了不少问题，这里的配置与上一篇有点不同，重新记录如下：

* 修改本地文件夹名称为英文

_如果你安装系统时选择了中文，那么用户目录就默认是中文，带你cd目录的时候就知道多蛋疼！_

```shell
export LANG=en_US
xdg-user-dirs-gtk-update
export LANG=zh_CN
reboot 
```

* 关闭鼠标加速

_Ubuntu16.04默认开启了鼠标加速，用触控板到感觉不到，用鼠标这么飘就不能忍了！_
```markdown
在Dashboard里搜索:
gnome-session-properties
点击添加：
名称：setmouse
命令：xset m 0 或者 xset m default
重启。
```

* 安装 lantern 

_接下来要安装软件了，我希望网络要没有阻碍，梯子是必须先装的！_
```shell
cd ~/Downloads/
wget https://raw.githubusercontent.com/getlantern/lantern-binaries/master/lantern-installer-beta-64-bit.deb
sudo dpkg -i lantern-installer-beta-64-bit.deb 
```
打开lantern，进入设置，查看两个端口号，我的是：
```markdown
HTTP(S) proxy: 127.0.0.1:44045
SOCKS proxy: 127.0.0.1:43355
```
然后终端输入下面两句来全局代理
```shell
export all_proxy=socks://127.0.0.1:43355
export ALL_PROXY=socks://127.0.0.1:43355
```
如果想取消掉的话：
```shell
unset all_proxy
unset ALL_PROXY
```
接着配置 lantern 的开机无界面启动
```markdown
在Dashboard里搜索:
gnome-session-properties
点击添加：
名称：lantern
命令：/usr/bin/lantern -headless
```
* 安装 git

```shell
sudo apt install git -y
# 设置 git 代理（http & https 代理）
git config --global http.proxy socks5://127.0.0.1:43355
git config --global https.proxy socks5://127.0.0.1:43355
```

* 安装功耗控制 TLP

```shell
sudo apt-get install tlp tlp-rdw -y
sudo apt-get install tp-smapi-dkms acpi-call-dkms -y
sudo apt-get install thermald -y
sudo apt-get install powertop -y
# 配置 TLP
sudo vim /etc/default/tlp
# 启动 TLP
sudo tlp start
```

* 消除 Ubuntu LightDM 登陆界面背景白点

_不能忍，影响我看锁屏壁纸！_
```shell
gsettings set com.canonical.unity-greeter draw-grid false
sudo xhost +SI:localuser:lightdm
sudo su lightdm -s /bin/bash
gsettings set com.canonical.unity-greeter draw-grid false
exit
```

* 安装 arc-flatabulous 主题

_[Arc-Flatabulous Theme](https://github.com/andreisergiu98/arc-flatabulous-theme)_

```shell
# 安装依赖
sudo apt install autoconf automake libgtk-3-dev -y
# 安装 unity-tweek-tool
sudo apt install unity-tweak-tool -y
# 官方安装方式
sudo rm -rf /usr/share/themes/{Arc-Flatabulous,Arc-Flatabulous-Darker,Arc-Flatabulous-Dark}
rm -rf ~/.local/share/themes/{Arc-Flatabulous,Arc-Flatabulous-Darker,Arc-Flatabulous-Dark}
rm -rf ~/.themes/{Arc-Flatabulous,Arc-Flatabulous-Darker,Arc-Flatabulous-Dark}
git clone https://github.com/andreisergiu98/arc-flatabulous-theme && cd arc-flatabulous-theme
# 编译安装，不想见透明效果，编译时加参数 --disable-transparency
./autogen.sh --prefix=/usr && sudo make install
```

* 安装 papirus 图标主题

_[papirus-icon-theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)_

```shell
sudo apt install wget git libqt4-svg -y 
wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install-papirus-root.sh | sh
```

* 安装 Hardcode-Tray 图标修复

_对右上角那些图标风格不统一，可以试试，但是只支持部分图标修复，这个软件蛮鸡肋的……_
```shell
sudo add-apt-repository ppa:andreas-angerer89/sni-qt-patched
sudo apt update
sudo apt install sni-qt sni-qt:i386 hardcode-tray -y
# 使用 Hardcode-Tray
hardcode-tray --apply
# 如果出现 FileNotFoundError: [Errno 2] ，建一个软链接
ln -s  /usr/share/icons/ ~/.local/share/icons
hardcode-tray --apply
```

* 更改鼠标指针样式

```markdown
下载 Breeze-Hacked 并解压
cp -a Breeze-Hacked/ /usr/share/icons/
在 unity-tweek-tool 里更换
```

* 使用terminator及ZSH

_普通用户_
```shell
sudo apt-get install terminator zsh -y
chsh -s /bin/zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
vim ~/.zshrc # 添加以下内容
# ZSH_THEME="agnoster"
# DEFAULT_USER="shank"
# COMPLETION_WAITING_DOTS="true"
```
_root用户_
```shell
sudo su
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
vim ~/.zshrc # 添加以下内容
# ZSH_THEME="agnoster"
# DEFAULT_USER="root"
# COMPLETION_WAITING_DOTS="true"
exit
```
_安装PowerLine字体_
```shell
cd ~/Downloads
git clone https://github.com/powerline/fonts
cd fonts
./install.sh
```
* 常规更新

```shell
sudo apt update
sudo apt upgrade
```
* 安装 Deluge 

_下载工具，带有BT和磁链下载_

```shell
sudo apt install deluge -y
```
* 安装 caffeine

_用于暂时取消屏保和睡眠模式，用linux看视频时记得把它设为Active_

```shell
sudo apt install caffeine -y
# 在 gnome-session-properties 开机启动中添加或修改Caffeine的命令为下面这句
# /usr/bin/caffeine-indicator 
```
* 安装 mpv

_简介而强大的播放器，不用VLC因为它对字幕支持不好！_

```shell
sudo apt-get install mpv -y
```
* 安装 flash 支持

_B站的Html5播放器总是没速度，所以flash还是必需的！_

```shell
#先在设置中允许 Canonical Partners 打包的应用
sudo apt install adobe-flashplugin -y
```

* 解决待机后重启会自动断线的 Bug

```shell
sudo systemctl enable NetworkManager.service
```
* 使用 Canonical Livepatch Service

_[Canonical Livepatch Service](https://www.ubuntu.com/server/livepatch) 免重新开机做核心_

```shell
sudo snap install canonical-livepatch
sudo canonical-livepatch enable XXX #XXX从官方获取
```
* 安装指纹识别支持

_这个可以用，但是会觉得的有点烦，因为这个软件有个bug，刷指纹一定要刷两下，验证成功，还要再刷一下指纹灯才会灭，所以我已经不用了……_
```shell
sudo add-apt-repository ppa:fingerprint/fprint -y && sudo apt-get update
sudo apt-get install libfprint0 fprint-demo libpam-fprintd gksu -y
```
* Fcitx 输入法换回原生 indicator，不用那个 qim

```shell
sudo apt remove fcitx-ui-qimpanel -y
```
* 安装 android studio

_[官方链接](https://developer.android.com/studio/index.html)下载zip安装包_
```shell
# 安装 jdk
sudo apt install openjdk-8-jdk -y
# 安装依赖
sudo apt-get install lib32z1 lib32ncurses5 lib32stdc++6 -y
# 解决无 pixmap 问题
sudo apt-get install gtk2-engines-pixbuf -y
# 解决无 adwaita 问题
sudo apt-get install gnome-themes-standard gnome-themes-standard-data -y
# 安装a.s.，我习惯把a.s.装到 /opt 目录
sudo unzip -q ~/Downloads/android-studio……… -d /opt # 省略号部分自己按TAB替换
cd /opt/android-studio/bin/
./studio.sh
```

* Firefox 字体问题 （不用改了，新版本好像解决了这个问题）

```markdown
地址栏输入 about:config
找到 gfx.font_rendering.fontconfig.fontlist.enabled
设置为 false
```

* 安装 typola ,本人最喜欢的 markdown 编辑器

_[typola官方链接](https://typora.io/)_

```shell
# optional, but recommended
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA300B7755AFCFAE
# add Typora's repository
sudo add-apt-repository 'deb https://typora.io ./linux/' -y
sudo apt-get update
# install typora
sudo apt-get install typora -y
```

### rEFInd

_[rEFInd官方链接](http://www.rodsbooks.com/refind/configfile.html)_

```shell
sudo apt-add-repository ppa:rodsmith/refind -y 
sudo apt-get update
sudo apt-get install refind -y
sudo cd /boot/eft/EFI/refind
sudo su
mkdir themes
cd themes
# 下载新主题
git clone https://github.com/EvanPurkhiser/rEFInd-minimal.git
cd ..
cp refind.conf refind.conf.bak
gedit refind.conf
```
添加设置到文件结尾，具体看配置文件或者Google
```shell
resolution 1920 1080
scan_all_linux_kernels false
default_selection Microsoft
# 导入主题配置：
include themes/rEFInd-minimal/theme.conf 
```
这个时候重启是使用不了rEFInd的，因为开了Secure Boot的缘故。那么要解决允许Secure Boot的问题，就要给他授权。官方提供的方案有 Shim 和 PreLoader，外文博客基本介绍的也是Shim。都比较麻烦，不愿看也不愿做（—。—），偶然发现了 boot-repair 。这个软件是傻瓜化修复启动引导用的，它解决安全引导的同时也会装 Shim，正好省得我动手。
先装 boot-repair
```shell
sudo add-apt-repository ppa:yannubuntu/boot-repair
sudo apt-get update
sudo apt-get install -y boot-repair && boot-repair
```
选择推荐方案(Recommended repair)，接着都是“yes”
引导修复后，可以apt重装下refind，应该同时会申请 *.cer 文件
然后重启，和官方 Slim授权的方式一样，Select key选第一个，
给EFI/refind/key目录下的**refind.cer**和**refind_local.cer**文件授权，然后选择重启。

授权后的一些调整

```shell
sudo su
# 删除一个多余启动文件
rm -f /boot/efi/EFI/Boot/bkpbootx64.efi
# 想要refind选择ubuntu就直接进系统，不用再显示grub2菜单
vim /etc/default/grub # 修改 GRUB_TIMEOUT=0
rm -f /etc/grub.d/30_os-prober # grub不记录win10引导
# 更新gurb
update-grub
```