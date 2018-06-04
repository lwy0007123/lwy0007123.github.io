---
title: ArchLinux安装记录
date: 2018-06-03 13:25:05
tags:
- Linux
- Arch
---

> 本教程在EFI启动的Windows10台式机上完成。

## 准备工作

1. Arch Linux 2018.06.01 iso，[官网下载](https://www.archlinux.org/download/)
1. USB Driver > 1G
1. Etcher [官网下载](https://etcher.io/)

## 系统安装

### 预留空间

使用 Windows 的磁盘管理工具压缩分区卷，不要格式化。(我预留的空间为60G。)

### U盘启动

1. 使用Etcher将Arch安装盘写入U盘
1. 重启电脑启动到U盘系统
1. 你将看到 `root@archiso ~ #`

### 分区

查看分区表。

```sh
fdisk -l
```

记录以下分区标识。

1. `EFI System` 分区，此处以 `/dev/sda1` 为例。
1. 将要安装 Arch Linux 的硬盘，此处以 `/dev/sdb` 为例。
1. 找到之前预留的空间，此处以 `/dev/sdb2` 为例。

使用新手分区工具 `cfdisk`。

```sh
cfdisk /dev/sdb
```

上下移动选择到 `Free Space`，左右移动选择到 `New`，分配与内存等大小的Swap分区，此处输入 `8G`，然后回车确认。再选择 `Type`，分区类型求改为 `Linux swap`。（当然也可以不分交换分区）

再次选择剩余的 `Free Space`，分出 `/`和`/home`。（因人而异，为了方便，我剩下的只分一个区，类型为 `Linux filesystem`）

最后选择 `Write`，输入 `yes`，再选择 `Quit`，退出分区工具。

再次 `fdisk -l` 查看新的分区表，记录新创建的分区标识。

此处以 8G的 `/dev/sdb2` 和 52G的 `/dev/sdb4` 为例。

也可以使用下面命令将新分区格式化。

```sh
mkfs.ext4 /dev/sdb4
mkswap /dev/sdb2
```

## 安装系统

### 挂载分区

```sh
# Linux filesystem
mount /dev/sdb4 /mnt
# EFI system
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
# Linux swap
swapon /dev/sdb2
```

### 配置镜像源

```sh
cd /etc/pacman.d
mv ./mirrorlist ./mirrorlist.bak
touch mirrorlist
echo 'Server = http://mirrors.163.com/archlinux/$repo/os/$arch' > ./mirrorlist
```

### 联网

有线连接可跳过这步，无线连接使用以下命令找到Ｗi-Fi，找到并输入密码即可。

```sh
wifi-menu
```

### 开始安装配置

```sh
# 设置系统时间
timedatectl set-ntp true
# 刷新本地数据库
pacman -Syy
# 安装基础系统
pacstrap -i /mnt base base-devel

# 回车两次然后输入y之后等一会……

# 生成 fstab 文件
genfstab -U /mnt >> /mnt/etc/fstab
# 切换到已安装的ArchLinux
arch-chroot /mnt
# 设置时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 时钟设置 使用UTC会导致双系统时间不同 此处用可以用localtime
hwclock --systohc -l

# 网络
pacman -S iw wpa_supplicant dialog
# 字体
pacman -S ttf-dejavu wqy-microhei wqy-zenhei
# 音频
pacman -S alsa-utils
# vim & ssh
pacman -S vim openssh
# 引导工具
pacman -S dosfstools grub efibootmgr os-prober
grub-install --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck
grub-mkconfig -o /boot/grub/grub.cfg
# P.S忽略执行 grub-mkconfig 下方的错误，前几行包含 Found XXX.img 就行
```

### 本地化

```sh
vim /etc/locale.gen
```

删除下面四句前面的`#`

```sh
#en_US.UTF-8 UTF-8
#zh_CN.GBK GBK
#zh_CN.UTF-8 UTF-8
#zh_CN.GB2312
```

然后生成更新

```sh
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
```

### 设置主机名

> 自行替换下面的 `HOSTNAME`

```sh
echo HOSTNAME > /etc/hostname
echo '127.0.0.1   localhost.localdomain   localhost' >> /etc/hosts
echo '::1         localhost.localdomain   localhost' >> /etc/hosts
echo '127.0.1.1   HOSTNAME.localdomain    HOSTNAME'  >>/etc/hosts
```

### 重启

```sh
exit
umount -R /mnt
reboot
```

### 用户设置

重启进入ArchLinux，输入`root`，回车即可登录。

```sh
# 为root设置密码
passwd root
# 添加普通用户,以shank为例。
useradd -m -g users -s /bin/bash shank
# 设置新用户密码
passwd shank
# 设置sudo权限
vim /etc/sudoers
# 在root ALL=(ALL) ALL 下一行添加 shank ALL=(ALL) ALL
# 去掉 #%wheel ALL=(ALL) ALL 前面的‘#’号
```

## 桌面环境

### 安装显卡驱动

运行下面的命令，先确定显卡型号，记下 `BusID`，类似 `00:02.0 VGA ...`

```sh
lspci | grep VGA
```

双显卡会有些麻烦，参考官方文档[NVIDIA_Optimus](https://wiki.archlinux.org/index.php/NVIDIA_Optimus)

依次运行以下命令。

```sh
# 如果没有联网，你需要先联网
wifi-menu
# intel显卡
pacman -S xf86-video-intel
# nvidia显卡
pacman -S nvidia nvidia-libgl
# 显示输出
pacman -S xorg-xrandr
# 生成配置，将位于 /etc/X11/xorg.conf
nvidia-xconfig
```

### 双显卡的配置

先配置xorg.conf

```sh
vim /etc/X11/xorg.conf
```

参照下面内容配置N卡，`BusID`那里N卡一般是`PCI:1:0:0`,之前查到的BusID为`00:02.0`则这里填`PCI:0:2:0`。

```conf
Section "Module"
    Load "modesetting"
EndSection

Section "Device"
    Identifier "nvidia"
    Driver "nvidia"
    BusID "PCI:1:0:0"
    Option "AllowEmptyInitialConfiguration"
EndSection
```

保存后，在编辑Intel.conf

```sh
vim /etc/X11/xorg.conf.d/20-intel.conf
```

找下面内容修改，注意BusID按实际填写。

```sh
Section "Device"
    Identifier "intel"
    Driver "modesetting"
    BusID "PCI:0:2:0"
EndSection
```

### 安装KDE桌面环境

```sh
pacman -S plasma kdebase kde-l10n-zh_cn
pacman -S xf86-input-synaptics
```

修改 [Display Manager](https://wiki.archlinux.org/index.php/NVIDIA_Optimus#Display_Managers)

```sh
echo 'xrandr --setprovideroutputsource modesetting NVIDIA-0' >> /usr/share/sddm/scripts/Xsetup
echo 'xrandr --auto' >> /usr/share/sddm/scripts/Xsetup
```

测试是否可以进入桌面

```sh
systemctl start sddm
```

### 桌面正常启动后

```sh
# 设置桌面自启动
sudo systemctl enable sddm
# 开启桌面ＷiFi配置
sudo systemctl enable NetworkManager
# 启动菜单添加缺失的windows启动项（可选）
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 配置梯子

### 安装工具

```sh
sudo pacman -S shadowsocks privoxy
```

### ss配置文件

编辑配置文件。

```sh
vim ~/ss-local.json
```

格式如下:

```json
{
    "server": "0.0.0.0",
    "server_port": 0000,
    "password": "0000",
    "method": "aes-256-cfb",
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "fast_open": false,
    "workers": 2
}
```

移动到 `/etc`。

```sh
sudo mv ~/ss-local.json /etc/ss-local.json
```

### 测试ss连接

```sh
# 启动sslocal
sudo su
nohup sslocal -c /etc/ss-local.json < /dev/null &>> /var/log/ss-local.log &
# 设置临时全局代理
export http_proxy="socks5://127.0.0.1:1080";export https_proxy=$http_proxy
# 然后访问下Google，有返回html就成了。
curl -skL www.google.com
```

### 使用gfwlist选择代理

```sh
# 获取 gfwlist2privoxy 脚本
curl -skL https://raw.github.com/zfl9/gfwlist2privoxy/master/gfwlist2privoxy -o gfwlist2privoxy
# 生成 gfwlist.action 文件
bash gfwlist2privoxy '127.0.0.1:1080'
# 拷贝至 privoxy 配置目录
cp -af gfwlist.action /etc/privoxy/
# 加载 gfwlist.action 文件
sudo su
echo 'actionsfile gfwlist.action' >> /etc/privoxy/config
# 启动 privoxy.service 服务
systemctl start privoxy.service
```

### 验证代理切换

```sh
unset http_proxy https_proxy no_proxy
# 设置临时变量，privoxy 默认监听端口为 8118
export proxy=http://127.0.0.1:8118; export http_proxy=$proxy https_proxy=$proxy no_proxy="localhost, 127.0.0.1, ::1"
# 可以看到返回值，说明代理成功
curl -skL www.google.com
# 查看当前IP，若是墙内IP说明gfwlist配置成功
curl -4skL http://ip.chinaz.com/getip.aspx
```

### shell脚本的方式

```sh
# 新建文件
touch ss-privoxy
# 赋予执行权限
sudo chmod +x ss-privoxy
# 移到PATH路径
mv -af ss-privoxy /usr/local/bin/
# 编辑
sudo vim /usr/local/bin/ss-privoxy
```

脚本内容如下：

```sh
#!/bin/bash
case $1 in
start)
    nohup sslocal -c /etc/ss-local.json < /dev/null &>> /var/log/ss-local.log &
    systemctl start privoxy
    proxy="http://127.0.0.1:8118"
    export http_proxy=$proxy
    export https_proxy=$proxy
    export no_proxy="localhost, 127.0.0.1, ::1"
    ;;
stop)
    unset http_proxy https_proxy no_proxy
    systemctl stop privoxy
    pkill sslocal
    ;;
reload)
    pkill sslocal
    nohup sslocal -c /etc/ss-local.json < /dev/null &>> /var/log/ss-local.log &
    ;;
set)
    proxy="http://127.0.0.1:8118"
    export http_proxy=$proxy
    export https_proxy=$proxy
    export no_proxy="localhost, 127.0.0.1, ::1"
    ;;
unset)
    unset http_proxy https_proxy no_proxy
    ;;
*)
    echo "usage: source $0 start|stop|reload|set|unset"
    exit 1
    ;;
esac
```

配置命令别名： `sudo vim /etc/profile.d/ss-privoxy.sh`

```sh
alias ss.start='. ss-privoxy start'
alias ss.stop='. ss-privoxy stop'
alias ss.reload='. ss-privoxy reload'
alias ss.set='. ss-privoxy set'
alias ss.unset='. ss-privoxy unset'
```

使用说明：

* ss.start：启动 ss-local+privoxy 代理
* ss.stop：停用 ss-local+privoxy 代理
* ss.reload：重载 ss-local.json 配置文件
* ss.set：设置 shell_proxy 环境变量
* ss.unset：删除 shell_proxy 环境变量

## 软件安装

### 分发仓库里可以找到的

安装前先查找软件包是否存在，以`ibus`为例：

```sh
# 查找与ibus相关的包
pacman -Ss ibus
# 这里支持正则匹配的，还可以这么写，更多查看 man pacman
pacman -Ss '^ibus-*'
```

这里我选择安装ibus-rime输入法

```sh
sudo pacman -S ibus-rime
```

### [AUR](https://aur.archlinux.org/)中可以找到的

以安装VScode为例，该package描述页在[这里](https://aur.archlinux.org/packages/visual-studio-code-bin/)

你可以复制`Git Clone URL`，然后按下面步骤安装。

```sh
# 先安装Git
sudo pacman -S git
# 将仓库clone下来
git clone https://aur.archlinux.org/visual-studio-code-bin.git
# 进入git目录
cd visual-studio-code-bin
# 编译压缩成安装包
makepkg -si
# pacman安装 (P.S XXXXXX 为版本号)
sudo pacman -U visual-studio-code-bin-XXXXXX.pkg.tar.xz
```

## 参考资料

* [Installation guide](https://wiki.archlinux.org/index.php/Installation_guide)
* [笔记本双显卡 EFI 启动安装 ArchLinux](https://blog.csdn.net/maxsky/article/details/56839855)
* [ss-local + privoxy 代理](https://www.zfl9.com/ss-local.html)
* [IBus](https://wiki.archlinux.org/index.php/IBus)
