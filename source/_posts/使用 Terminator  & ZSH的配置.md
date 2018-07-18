---
title: 使用 Terminator & ZSH的配置
date: 2016-10-01 21:11:38
categories: Linux
tags: 
- Linux
- terminator
- zsh
---

## 在别人博客里看到 Terminator 挺好用的，特别是和zsh搭配真是漂亮，这里总结下怎么弄吧

### 安装 Terminator 

<pre class="lang:sh decode:true " >sudo apt-get install terminator</pre> 

* _利用 Debian 的重新配置命令选择默认终端：_

<pre class="lang:sh decode:true " >sudo update-alternatives --config x-terminal-emulator</pre> 


* _非ubuntu系统设置terminator快捷键_

<pre class="lang:default decode:true " >Setting -> Keyboard -> Shortcuts -> Custom Shortcuts -> add(+)
Name : Terminal
Command : /usr/bin/terminator
Apply
Click "Disable"
press Ctrl + Alt + T</pre> 


### 更换主题 
<pre class="lang:default decode:true " >
/* 打开Terminator ，进行如下操作 */
Preferenvces -> General
Disable ‘Show titlebar’
Preferenvces -> Profiles -> Colors -> Foreground and Background -> Build-in schemes
Choose ‘Solarized dark’
</pre>


### 安装zsh 

<pre class="lang:sh decode:true " >sudo apt-get install zsh</pre> 

* _设置当前用户使用zsh_

<pre class="lang:sh decode:true " >chsh -s /bin/zsh</pre> 

### 安装on my zsh 
* _自动安装：(推荐)_

<pre class="lang:sh decode:true " >wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh</pre> 

* _手动安装：_

<pre class="lang:sh decode:true " >git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc</pre> 


### 安装powerline字体 

<pre class="lang:sh decode:true " >git clone https://github.com/powerline/fonts
cd fonts
./install.sh</pre> 

_然后在终端中使用powerline字体_


### 编辑： ~/.zshrc 
* _增加自己的用户名：_

<pre class="lang:sh decode:true " >DEFAULT_USER="Shank"</pre> 

_PS：上面 Shank 替换成你当前的用户名，用whoami查看你的用户名_


* _修改主题：_

<pre class="lang:sh decode:true " >ZSH_THEME="agnoster"</pre> 

* _启用几个功能：_

<pre class="lang:sh decode:true " >COMPLETION_WAITING_DOTS="true"</pre> 


### 或者用以下简单粗暴的方式屏蔽zsh中的用户名：

<pre class="lang:sh decode:true " >cd ~/.oh-my-zsh/themes
sudo vim 当前主题名称</pre> 

_看到最下面对build_prompt的定义，把prompt_context用#注释掉即可_