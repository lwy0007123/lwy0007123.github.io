---
title: Linux下使用SS本地代理
date: 2018-04-15 12:19:55
categories: Linux
tags:
- Linux
- Shadowsocks
- Privoxy
---

# 前言

凡是要Coding，免不了上Google，不得不说SS的Windows版体验更好。

Linux版我总是挂全局代理，国外IP不能看B站正版番就很难受。

因为懒一直没折腾，这次为了更好的体验，我决定花点时间。

<!--more-->

# 安装ss客户端

本来 python 版的 shadowsocks 带有 sslocal 可以做本地代理的，但是我用图形界面，觉得 qt 版体验要好些。

```sh
sudo apt install shadowsocks-qt5
```

安装完成后，打开配置好你的 ss 服务，本地地址：`127.0.0.1`，端口：`1080`，本地服务器类型：`HTTP(S)`。

## 验证本地代理

```sh
# 设置临时全局代理
export proxy=http://127.0.0.1:1080; export http_proxy=$proxy https_proxy=$proxy no_proxy="localhost, 127.0.0.0/8, ::1"
# 然后访问下Google，有返回html就成了。
curl -skL www.google.com
```

# 安装privoxy

```sh
sudo apt install privoxy
```

## 配置gfwlist

全局代理体验不佳，这里要利用 gfwlist ，配置 privoxy

```sh
# 先获取一段格式转换脚本
curl -skL https://raw.github.com/sko00o/gfwlist2privoxy/master/gfwlist2privoxy -o gfwlist2privoxy
# 生成 gfwlist.action 文件
bash gfwlist2privoxy '127.0.0.1:1080'
# 拷贝至 privoxy 配置目录
sudo cp -af gfwlist.action /etc/privoxy/
# 加载 gfwlist.action 文件
sudo echo 'actionsfile gfwlist.action' >> /etc/privoxy/config
# 启动 privoxy.service 服务
sudo systemctl start privoxy.service
```

## 验证代理切换

```sh
# 设置临时变量，privoxy 默认监听端口为 8118
export proxy=http://127.0.0.1:8118; export http_proxy=$proxy https_proxy=$proxy no_proxy="localhost, 127.0.0.0/8, ::1"
# 可以看到返回值，说明代理成功
curl -skL www.google.com
# 查看当前IP，若是墙内IP说明gfwlist配置成功
curl -4skL http://ip.chinaz.com/getip.aspx
```

# 设置环境变量

可以将环境变量加入 `.profile` 或 `.bashrc` 或其他配置文件中

```sh
# vim ~/.profile 或者 sudo vim /etc/profile
# 设置临时变量，privoxy 默认监听端口为 8118
proxy=http://127.0.0.1:8118
export http_proxy=$proxy
export https_proxy=$proxy
export no_proxy="localhost, 127.0.0.0/8, ::1"
```

# 参考

[ss-local + privoxy 代理](https://www.zfl9.com/ss-local.html)
[原脚本地址](https://github.com/zfl9/gfwlist2privoxy/)
[Proivoxy用户手册](https://www.privoxy.org/user-manual/actions-file.html)