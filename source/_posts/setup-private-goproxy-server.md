---
title: 部署 goproxy 服务
date: 2019-06-26 17:17:25
tags:
- Go
- GOPROXY
---

上一篇已经实践了在私网环境中配置自签名的证书，并开启 https。

这一切都是为了能在私网中搭建一个方便可用的 Go 集成环境。

Go 在 1.11 版本添加了 Go Module 特性，成为官方推荐的包管理方式。
[详情见官方 wiki](https://github.com/golang/go/wiki/Modules)

与 go mod 同时到来的还有 goproxy ，允许使用代理的方式拉取依赖包。

<!--more-->

## 介绍

goproxy 解决了几个长期存在的问题：

1. 国内网络环境下从 github 拉去依赖包速度很慢
2. 如果开源作者删除了仓库，对应依赖包就无法找到

goproxy 代理服务会缓存依赖包版本，不需要重复下载，也不需要担心原库被删除。

有许多开放的代理服务，比如我常用的是 <https://goproxy.io>

只需要设置环境变量 `GOPROXY=https://goproxy.io` 就能享受代理的快捷。

但是公开的 goproxy 服务仅可以访问公开的仓库，对于私有项目或者
私网环境，咱们还得自己建。

## 选型

有几款不错的 goproxy 项目

* [gomods/athens](https://github.com/gomods/athens)

* [goproxyio/goproxy](https://github.com/goproxyio/goproxy)

* [goproxy/goproxy.cn](https://github.com/goproxy/goproxy.cn)

虽然 `athens` star 数最多，配置文件很灵活可配项很多，但是我觉得它很长一段时间都会是 beta 状态，我自己部署也不需要太多定制化。

我最后选择了 `goproxyio` 的项目，代码不多，也很稳定。

## 编译

goproxyio 发布了 docker 镜像，可以很方便地使用 docker 部署 goproxy。

这里我们讲一下源码编译。其实也是相当简单，按照 README 文档，一条命令搞定。

```sh
make
```

> 当然你先要装好 `go` 和 `make`

linux 下编译完成后就出现了 goproxy 执行文件。

## 部署

上传 goproxy 执行文件到 linux 主机上，放在任意目录下。

直接 `./goproxy` 运行，会在 `8081` 端口上开启代理服务，然后本地开发环境，配置 GOPROXY 环境变量。

> 假设内网 linux 主机 ip 地址是 10.0.0.1，请自行替换 ip 地址。

```sh
export GOPROXY=http://10.0.0.1:8081
```

再任意 go mod 管理地项目下执行 go get ，你就能看到 goproxy 服务代你请求了目标地址。

如果你配置了 GOPATH 环境变量， goproxy 服务就会缓存到 `$GOPATH/pkg/mod` 下。

如果你不愿意设置 GOPATH 环境变量，也可以使用 `-cacheDir` 参数指定缓存目录。

如果你不想使用 `8081` 端口，可以使用 `-listen` 参数指定新的端口。

更多使用说明见 `./goproxy -h`。

## 进程管理

仅仅 nohup 的方式启动 goproxy 服务太 low 了，咱们使用 systemd 管理。

~~编写一个 `goproxy.service` 文件~~ 
项目源码目录下 scripts 下有 service 配置文件，可以直接使用。

<details>
<summary>放到 `/etc/systemd/system/` 目录下</summary>

> 假设程序在 `/root/goproxy/goproxy`， 请自行替换启动文件路径。

```ini
[Unit]
Description=private goproxy server
After=network.target

[Service]
Type=simple
PIDFile=/run/goproxy.pid
ExecStart=/root/goproxy/goproxy -cacheDir=/root/go
ExecStartPre=/usr/bin/rm -f /run/goproxy.pid
Restart=always

[Install]
WantedBy=multi-user.target
```

</details>

关于如何编写 service 文件，我推荐一篇不错地[教程](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)

最后启动服务

```sh
# 启动服务
sudo systemctl start goproxy

# （可选）开启自启
sudo systemctl enable goproxy

# 查看状态
sudo systemctl status goproxy
```

## 参考

* [goproxy.io](https://github.com/goproxyio/goproxy)

* [How To Use Systemctl to Manage Systemd Services and Units](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
