---
title: 简单 IRC 服务的搭建
date: 2017-01-09 0:36:28
tags:  
- IRC
- Linux
---

Windows 已经删了，最近都在 Ubuntu 上，不小心接触了IRC这个古老的东西，研究了一晚上，给破站加点新玩意。

<!--more-->

 博客迁移后，聊天室已不存在。

> IRC（Internet Relay Chat的缩写，“因特网中继聊天”）是一种通过网络的即时聊天方式。

[见Wiki](https://zh.wikipedia.org/wiki/IRC)

## 讲故事

* 背景

  准备好好适应使用linux来编程，趁着假期，打算完全不去碰windows，重新安装了双系统，这次仗着内存8G够用，swap分区就不要了，全部40G都挂到 / 目录上。

* 问题

  觉得跟外界联系还是挺重要的，虽然QQ可以挂在手机上，但是用着linux要分享个链接什么的麻烦的要死，没法好好聊天啊。

* Telegram

  看别人用着Telegram好好的，可是到我想用时，GFW就让它失联了。而且为了找人聊天让别人在装个软件也麻烦。

* IRC

  第一次见IRC还是上次整越狱的老iTouch时，搜资料偶然发现了Kiwi IRC。正好是开源的，这次拿来练手。

## 说正事

其实安装过程官方给的太详细了，没什么好说的 (-_-|||

Kiwi的安装过程参考官方教程：

[传送门](https://kiwiirc.com/docs/installing)

务必先装好 openssl 和 openssl-dev | openssl-devel

参考另一款老牌IRC （UnrealIRCd）的安装，就可以理解配置文件的设置，下面推荐两个博客

[博客1](https://www.dadclab.com/archives/6007.jiecao) [博客2](http://soft.dog/2016/03/25/unrealircd-basic/)

## 讲废话

为什么我不用 UnrealIRCd 呢？因为只有一个服务端，客户端还要自己另外找。

Kiwi IRC 的易用在于，它把服务端和客户端整合了，在云主机上装好后，直接从端口进入客户端，直接连接另一端口的服务端。

~~去看看本站的聊天室吧： [Chatting Room](#missing)~~

> 来自2018/10/29：“ 放弃 Windows... Steam on linux... 真香~ ”
