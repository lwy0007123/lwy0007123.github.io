---
title: 私网环境启用 https
date: 2019-06-26 13:24:00
tags:
- Linux
- https
- TLS
- CA
---

本文是搭建私网环境下的 go 自动集成环境的一部分。

go 项目使用 go mod 作依赖包管理，遇到一些问题。
对于依赖库是保存在内网仓库的情况，拉取代码会失败，原因是 go mod 获取
依赖包版本需要使用 https 请求，而自建的 git 服务没有启用 https 。

如果是传统的 gopath 依赖项目， 只需要 go get -insecure 即可绕过 https 限制，
但是这里我们选择用 go mod ，一方面这是 go 官方推荐的方式，也是未来的发展趋势，
另一方面是不希望依赖包放在 vendor 目录下一起提交到版本库造成源码目录过于庞大。

接下来讲一讲如何在私网中启用 https， 服务端系统以 CentOS7 为例。

<!-- more -->

## 环境准备

为了达到实验目的，先修改本地机器的 host 文件。

web 服务运行在 192.168.20.44 的局域网 IP 的主机上
添加一条虚拟的域名映射到这个 IP 。

```txt
192.168.20.44 vcs.private.org
```

## 创建 SSL 证书

### 创建目录

```sh
# 创建目录用于保存公共证书
sudo mkdir /etc/ssl/certs

# 创建目录用于保存私钥文件
sudo mkdir /etc/ssl/private

# 关键目录，设置访问权限
sudo chmod 700 /etc/ssl/private
```

### 创建自签名密钥证书对

```sh
sudo openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key \
    -out /etc/ssl/certs/selfsigned.crt
```

### 命令参数解释

`openssl` 用于创建和管理OpenSSL证书，密钥和其他文件的基本命令行工具。

`req -x509` 表示我们想要使用 X.509 证书签名请求（CSR，certificate signing request）生成签名证书。

`-nodes` 跳过用密码保护证书的选项。

`-days 365` 有效期 365 天。

`-newkey rsa:2048` 同时生成新证书和新密钥，生成 2048 位的 RSA 密钥。

`-keyout` 密钥输出目录。

`-out` 证书输出目录。

接下来会被要求填写一些证书的基本信息，需要注意的一点是
`CommonName` 要填写服务相关的域名或者公共 IP 地址。
此处咱们填写 `vcs.private.org`

<details>

<summary>还可以一条命令完成</summary>

```sh
sudo openssl req -x509 -nodes -days 365 \
    -subj "/C=CN/ST=ZJ/L=HZ/O=private.org/CN=vcs.private.org" \
    -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key \
    -out /etc/ssl/certs/selfsigned.crt
```

</details>

### 创建 Diffie-Hellman 组

据说用于与客户端协商 PFS ([Perfect Forward Secrecy](https://en.wikipedia.org/wiki/Forward_secrecy))，能在私钥受损的情况下保证会话密钥不受损害。

创建要几十秒，需要稍微等一下。

```sh
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

> 这个 DH 组到底有多强大呢，等我学习后再总结下…… Orz

## 配置 Nginx 使用 SSL

### 安装 Nginx

```sh
# 启用 EPEL 库
sudo yum install epel-release
# 安装
sudo yum install nginx
# 开启
sudo systemctl start nginx
# 检查状态
systemctl status nginx
```

### 防火墙配置（如果未开启了防火墙，可跳过）

* firewalld 相关

```sh
sudo firewall-cmd --add-service=http
sudo firewall-cmd --add-service=https
sudo firewall-cmd --runtime-to-permanent
```

* iptables 相关

```sh
sudo iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```

### 添加 TLS/SSL 服务配置块

`sudo vim /etc/nginx/conf.d/ssl.conf`

内容如下

```conf
server {
    listen 443 http2 ssl;
    listen [::]:443 http2 ssl;

    server_name vcs.private.org;

    ssl_certificate /etc/ssl/certs/selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/selfsigned.key;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;

    root /usr/share/nginx/html;

    location / {
    }

    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
```

> 参考[这篇文章](https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html)添加更多安全性配置

## 启用新配置

先检查配置文件是否有错误

```sh
sudo nginx -t
```

重载新配置

```sh
sudo service nginx reload
```

## 测试

```sh
curl https://vcs.private.org
```

你会看到报错

```sh
curl: (60) Peer's certificate issuer has been marked as not trusted by the user.
More details here: http://curl.haxx.se/docs/sslcerts.html
.....
```

## 更新客户端信任证书

服务端启用了 https，接下来让客户端接受这个自签署的证书。

* ArchLinux

签署好的 `selfsigned.crt` 文件复制到 `/etc/ca-certificates/trust-source/anchors` 目录下
运行 `sudo update-ca-trust`， 没有任何输出即更新成功。

* CentOS7

签署好的 `selfsigned.crt` 文件复制到 `/etc/pki/ca-trust/source/anchors` 目录下
运行 `sudo update-ca-trust extract`， 没有任何输出即更新成功。

* Windows10

添加比较麻烦参考[这篇文章](https://reactpaths.com/how-to-get-https-working-in-localhost-development-environment-f17de34af046)。
虽然添加完成后 chrome 依旧是不接受这个证书的（应该是浏览器策略的问题），但是
cmd 里 curl 验证可以通过。

客户端信任了证书之后，再次 curl 请求就能成功了。

## 参考

* [How To Create a Self-Signed SSL Certificate for Nginx on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-on-centos-7)

* [Strong SSL Security on nginx](https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html)

* [update-ca-trust](https://jlk.fjfi.cvut.cz/arch/manpages/man/update-ca-trust.8)

* [Adding trusted root certificates to the server](https://manuals.gfi.com/en/kerio/connect/content/server-configuration/ssl-certificates/adding-trusted-root-certificates-to-the-server-1605.html)

* [How to get HTTPS working in localhost development environment](https://reactpaths.com/how-to-get-https-working-in-localhost-development-environment-f17de34af046)
