---
title: Go 私网开发服务搭建记录
date: 2019-10-29 09:50:58
tags:
- Go
- Gogs
- goproxy
- Jenkins
---

本文记录了私网 Go 开发所需的所有相关服务，包括版本管理，模块代理，持续集成。

涉及服务如下：

- Gogs
- goproxy
- Jenkins

<!--more-->

系统配置：

- CentOS 7

## 版本管理

### 目的

搭建版本管理系统（VCS）的目的：一方面是为私有项目提供版本管理，一方面是托管修改过的开源项目。

### 选型

私网环境开发，项目源码可以托管于任何版本管理系统，但是 Go 对 Git 的支持更好，优先考虑搭建 Git 服务作为版本管理。

Go 要求版本管理系统实现 `go-get` 接口。我们选择了 [Gogs](https://gogs.io/) 。它是由 Go 语言编写的开源 Git 服务，搭建十分便捷 。

### 部署

详见 [官方搭建指南](https://gogs.io/docs/installation) ，以下仅作记录。

> 如果使用 MySQL ，要求版本不低于 5.7 。参考这篇 [安装 MySQL 8.0](/2019/10/28/Install-MySQL-8-0-on-CentOS-7/)

#### 新建数据库

名称： gogs

编码： utf8mb4

数据库中通过以下脚本新建数据库：

```sql
CREATE DATABASE gogs CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 下载最新二进制程序包

下载[官网](https://gogs.io/docs/installation/install_from_binary.html)提供的二进制文件。

```sh
wget https://cdn.gogs.io/0.11.91/gogs_0.11.91_linux_amd64.tar.gz
```

#### 解压运行

```sh
tar xf gogs_0.11.91_linux_amd64.tar.gz
cd gogs
./gogs web
```

#### 按照提示进行配置

> 配置前确保 Git 已安装

<details>
<summary>安装 Git</summary>

```sh
sudo yum -y install git
```

</details>

浏览器访问当前主机的 3000 端口，开始配置。

有几个配置项需要注意：

- 域名：建议填域名，不然引用地址会很奇怪，即使没有真实域名也可以再客户端上做个 host 映射。例如："go.findshank.com"。

- HTTP 端口号：可以使用任意未占用的端口号，之后通过 nginx 映射到 80 端口。

- 应用 URL：建议先自签一个证书，然后启用 HTTPS，使用域名不指定端口。例如："https://go.findshank.com"。自签证书[参考这篇](https://www.findshank.com/2019/06/26/enable-https-for-private-network/)

- 禁止用户注册：建议勾选，之后统一由管理员分配账号。

#### 配置守护进程

修改 `./scripts/systemd/gogs.service`

```ini
[Unit]
Description=Gogs
After=syslog.target
After=network.target
After=mysqld.service

[Service]
LimitMEMLOCK=infinity
LimitNOFILE=65535
Type=simple
User=root
Group=root
WorkingDirectory=/home/shank/gogs
ExecStart=/home/shank/gogs/gogs web
Restart=always
Environment=USER=shank HOME=/home/shank

ProtectSystem=full
PrivateDevices=yes
PrivateTmp=yes
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

> 注意修改为实际的用户目录

复制到系统目录

```sh
sudo cp ./scripts/systemd/gogs.service /usr/lib/systemd/system/
```

####  启用守护进程

```sh
sudo systemctl enable gogs
sudo systemctl start gogs
```

## 模块代理

### 目的

Go 1.11 之后推荐使用 `go mod` 作为依赖管理，使用 `go mod` 可以通过配置模块代理服务加快依赖包的下载。这类代理服务通过环境变量 `GOPROXY` 进行指定，只要实现了模块代理协议（Module proxy protocol）的服务都称为模块代理服务。

因为公有网络的不确定性（比如开源作者删除了代码仓库或者网络被防火墙劫持），可以考虑自己维护一个代理服务，方便私网内构建时拉取常用第三方代码依赖。

### 选型

目前有许多开源项目实现了 goproxy 服务，我们选择了社区活跃且版本稳定的 [goproxyio/goproxy](https://github.com/goproxyio/goproxy)。

### 源码构建及部署

> Go 版本不低于 1.11

<details>
<summary>配置 Go 1.13.3 编译环境</summary>

```sh
wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.13.3.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile
source $HOME/.profile
```

</details>

<details>
<summary>安装 make</summary>

```sh
sudo yum -y install make
```

</details>

#### 下载一份稳定版版本的源码

```sh
wget https://github.com/goproxyio/goproxy/archive/v2.0.0.tar.gz
```

#### 解压 & 编译

```sh
tar xf v2.0.0.tar.gz
cd goproxy-2.0.0
make
```

#### 添加二进制文件到系统目录

```sh
sudo cp ./bin/goproxy /usr/local/bin
```

#### 配置守护进程

修改 `./scripts/goproxy.service`

```ini
[Unit]
Description=goproxy service
Documentation=https://goproxy.io
After=network-online.target

[Service]
User=root
Group=root
LimitNOFILE=65536
Environment=PATH=/usr/local/go/bin
ExecStart=/usr/local/bin/goproxy -listen=0.0.0.0:8081 -proxy=https://goproxy.io -exclude=go.findshank.com
KillMode=control-group
SuccessExitStatus=2
Restart=always

[Install]
WantedBy=multi-user.target
Alias=goproxy.service
```

参数说明

- `-listen`：服务监听地址。
- `-proxy`：上游代理模块，不配置则直接请求目的地址。
- `-exclude`：不走代理的域名，私网域名公网无法访问应直接请求。

复制到系统目录

```sh
sudo cp ./scripts/goproxy.service /usr/lib/systemd/system/
```

#### 启用守护进程

```sh
sudo systemctl enable goproxy
sudo systemctl start goproxy
```

## 持续集成（可选）

### 目的

开发者将代码提交到版本管理系统，之后的编译构建，自动化测试，打包，发布，部署等都是固定流程，应该由持续集成系统去完成。

使用持续集成，可以降低重复繁琐操作的出错率。

### 选型

有许多在线的持续集成服务，由于我们是私网部署，我们选择了 [Jenkins](https://jenkins.io) ,它是由 Java 语言编写的开源 CI&CD 服务，搭建十分便捷 。

### 部署

详见 [官方搭建指南](https://jenkins.io/zh/doc/book/installing/) ，以下仅作记录。

#### 安装 Java 1.8 运行环境

```sh
sudo yum -y install java-1.8.0-openjdk-devel
```

#### 启用 Jenkins 存储库

```sh
curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
```

#### 安装 Jenkins

```sh
sudo yum -y install jenkins
```

#### 启用守护程序

```sh
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

#### 按照提示进行配置

浏览器访问当前主机的 8080 端口，开始配置。

安装建议的插件，按需求以后添加插件。

## 其他

考虑使用 NGINX 做端口映射，此处不介绍。

> 但是建议 443 端口留给 Gogs 服务。 

## 可能遇到的问题

- 无法外部访问服务：检查 CentOS 的防火墙策略，放行特定端口。安全性要求不高甚至可以关闭防火墙。

## 参考

- [How to Stop and Disable Firewalld on CentOS 7](https://www.liquidweb.com/kb/how-to-stop-and-disable-firewalld-on-centos-7/)
- [部署 goproxy 服务](https://www.findshank.com/2019/06/26/setup-private-goproxy-server/)
- [How To Install Jenkins on CentOS 7](https://linuxize.com/post/how-to-install-jenkins-on-centos-7/)