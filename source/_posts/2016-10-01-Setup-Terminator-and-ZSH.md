---
title: 配置使用 Terminator & ZSH
date: 2016-10-01 21:11:38
tags: 
- Linux
- Terminator
- ZSH
---

 在别人博客里看到 Terminator 挺好用的，特别是和zsh搭配真是漂亮，这里总结下怎么弄吧。

<!--more-->

## 安装 Terminator

```sh
sudo apt-get install terminator
```

* _利用 Debian 的重新配置命令选择默认终端：_

```sh
sudo update-alternatives --config x-terminal-emulator
```

* _非ubuntu系统设置terminator快捷键_

Setting -> Keyboard -> Shortcuts -> Custom Shortcuts -> add(+)
Name : Terminal
Command : /usr/bin/terminator
Apply
Click "Disable"
press Ctrl + Alt + T

## 更换主题

```sh
/* 打开Terminator ，进行如下操作 */
Preferenvces -> General
Disable ‘Show titlebar’
Preferenvces -> Profiles -> Colors -> Foreground and Background -> Build-in schemes
Choose ‘Solarized dark’
```

## 安装zsh

```sh
sudo apt-get install zsh
```

* _设置当前用户使用zsh_

```sh
chsh -s /bin/zsh
```

## 安装 on my zsh

* _自动安装：(推荐)_

```sh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
```

* _手动安装：_

```sh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
```

## 安装powerline字体

```sh
git clone https://github.com/powerline/fonts
cd fonts
./install.sh
```

然后在终端中使用powerline字体

## 编辑： ~/.zshrc

* _增加自己的用户名：_

```sh
DEFAULT_USER="Shank"
```

> PS：上面 Shank 替换成你当前的用户名，用whoami查看你的用户名

* _修改主题：_

```sh
ZSH_THEME="agnoster"
```

* _启用几个功能：_

```sh
COMPLETION_WAITING_DOTS="true"
```

### 或者用以下简单粗暴的方式屏蔽zsh中的用户名

```sh
cd ~/.oh-my-zsh/themes
sudo vim 当前主题名称
```

找到最下面对`build_prompt`的定义，把`prompt_context`用`#`注释掉即可

> 来自2018/10/29：“以前的自己 Markdown 写得这么烂还敢贴出来。”
