---
title: 私网 git 仓库 go mod 实践
date: 2019-08-07 10:30:05
tags:
- go
- git
---

使用 gogs 搭建私网 git 服务器，搭建十分便捷，参考[官方文档](https://gogs.io/docs/installation)

本文旨在探究私网 git 服务对 `go get` 支持的问题。

<!--more-->

## 写在前面

使用 go mod 获取依赖，实际也是调用 go get，但是 go mod 中获取依赖必须要 vcs 服务开启 https，如何启用 https 见[之前的文章](https://www.findshank.com/2019/06/26/enable-https-for-private-network/)，本文简单起见使用 go get 的方式获取依赖。

结论：

gogs 中要配置好 `DOMAIN` 及 `ROOT_URL` 。

## ~~初次尝试~~

<details>

<summary>展开</summary>

### 准备实验环境

本地机器 host 里添加一条记录。

> git 服务的实际局域网 IP 为 `192.168.20.44`。

```text
192.168.20.44 vcs.private.org
```

配置 git 服务的域名，在 gogs 配置文件中修改如下行：

```ini
DOMAIN = vcs.private.org
```

重启 gogs 服务。

使用 `sko00o` 用户新建一个仓库，名叫 `demo` 。

上传一个由 go mod 管理的项目。

```sh
mkdir demo && cd demo
go mod init vcs.private.org/sko00o/demo
touch main.go
echo package main > main.go
git init
git add .
git commit -m "initial commit"
git remote add origin gogs@vcs.private.org:sko00o/demo.git
git push -u origin master
```

### clone 测试

直接使用 git clone vcs.private.org/sko00o/demo 仓库拉取成功。

### go get 测试

尝试 go get 拉取 sko00o/demo 仓库。

> 服务未配置 https ，故添上 `-insecure` 参数。

```sh
go get -v -insecure vcs.private.org/sko00o/demo
```

拉取失败，错误提示：

```sh
Parsing meta tags from https://vcs.private.org?go-get=1 (status code 502)
go get vcs.private.org/sko00o/demo: unrecognized import path "vcs.private.org/sko00o/demo" (parse https://vcs.private.org/sko00o/demo?go-get=1: no go-import meta tags
```

再次尝试：

```sh
go get -v -insecure vcs.private.org/sko00o/demo.git
```

拉取失败，错误提示：

```sh
go: vcs.private.org/sko00o/demo.git@v0.0.0-20190624043337-f2473e290d4d: parsing go.mod: unexpected module path "vcs.private.org/sko00o/demo"
```

将 demo 仓库中的 go.mod 改为 `module vcs.private.org/sko00o/demo.git`

再次尝试：

```sh
go get -v -insecure vcs.private.org/sko00o/demo.git
```

成功。

</details>

## 更合理的办法

因为要修改 module 名字，以上处理方式显然不合理。

参考官方文档后， 得知 go 要求版本管理系统的服务端实现 go-get=1 的请求，恰好 gogs 是支持这个请求的。

尝试直接访问这个 API。

`curl "http://vcs.private.org/sko00o/demo?go-get=1"`

返回内容如下

```html
<!doctype html>
<html>
        <head>
                <meta name="go-import" content="192.168.20.44/sko00o/demo git http://192.168.20.44/sko00o/demo.git">
                <meta name="go-source" content="192.168.20.44/sko00o/demo _ http://192.168.20.44/sko00o/demo/src/master{/dir} http://192.168.20.44/sko00o/demo/src/master{/dir}/{file}#L{line}">
        </head>
        <body>
                go get --insecure 192.168.20.44/sko00o/demo
        </body>
</html>
```

问题应该出在这里，说明 gogs 服务端的配置还存在问题，接着修改：

```ini
ROOT_URL = http://vcs.private.org
```

重启 gogs 。 `service gogos restart`

再次请求，返回内容符合要求

```html
<!doctype html>
<html>
        <head>
                <meta name="go-import" content="vcs.private.org/sko00o/demo git http://vcs.private.org/sko00o/demo.git">
                <meta name="go-source" content="vcs.private.org/sko00o/demo _ http://vcs.private.org/sko00o/demo/src/master{/dir} http://vcs.private.org/sko00o/demo/src/master{/dir}/{file}#L{line}">
        </head>
        <body>
                go get --insecure vcs.private.org/sko00o/demo
        </body>
</html>
```

仓库回滚到没有修改 go.mod module 的版本，并强制提交。

```sh
git reset --hard <SHA1> # must replace SHA1
git push --force
```

再次 `go get -v -insecure vcs.private.org/sko00o/demo`

成功。

## 还可能遇到的问题

如果你设置了环境变量 `http_proxy`， 你可能遇到下面的问题。

```sh
Fetching https://vcs.private.org/sko00o/demo?go-get=1
https fetch failed: Get https://vcs.private.org/sko00o/demo?go-get=1: EOF
Fetching http://vcs.private.org/sko00o/demo?go-get=1
Parsing meta tags from http://vcs.private.org/sko00o/demo?go-get=1 (status code 500)
Fetching https://vcs.private.org/lowan?go-get=1
https fetch failed: Get https://vcs.private.org/lowan?go-get=1: EOF
Fetching http://vcs.private.org/lowan?go-get=1
Parsing meta tags from http://vcs.private.org/lowan?go-get=1 (status code 500)
Fetching https://vcs.private.org?go-get=1
https fetch failed: Get https://vcs.private.org?go-get=1: EOF
Fetching http://vcs.private.org?go-get=1
Parsing meta tags from http://vcs.private.org?go-get=1 (status code 500)
go get vcs.private.org/sko00o/demo: unrecognized import path "vcs.private.org/sko00o/demo" (parse http://vcs.private.org/sko00o/demo?go-get=1: no go-import meta tags ())
```

解决办法：取消代理配置 `export http_proxy=` 。

如果你设置了 git 代理，你可能遇到下面的问题。

```sh
Fetching https://vcs.private.org/sko00o/demo?go-get=1
https fetch failed: Get https://vcs.private.org/sko00o/demo?go-get=1: EOF
Fetching http://vcs.private.org/sko00o/demo?go-get=1
Parsing meta tags from http://vcs.private.org/sko00o/demo?go-get=1 (status code 200)
get "vcs.private.org/sko00o/demo": found meta tag get.metaImport{Prefix:"vcs.private.org/sko00o/demo", VCS:"git", RepoRoot:"http://vcs.private.org/sko00o/demo.git"} at http://vcs.private.org/sko00o/demo?go-get=1
Fetching https://vcs.private.org/lowan?go-get=1
https fetch failed: Get https://vcs.private.org/lowan?go-get=1: EOF
Fetching http://vcs.private.org/lowan?go-get=1
Parsing meta tags from http://vcs.private.org/lowan?go-get=1 (status code 200)
Fetching https://vcs.private.org?go-get=1
https fetch failed: Get https://vcs.private.org?go-get=1: EOF
Fetching http://vcs.private.org?go-get=1
Parsing meta tags from http://vcs.private.org?go-get=1 (status code 404)
go get vcs.private.org/sko00o/demo: git ls-remote -q http://vcs.private.org/sko00o/demo.git in /mnt/d/GoDev/pkg/mod/cache/vcs/3172f8a70a0665ea75a1e7fb868f761ef269470c22b6a85cbe78b19c5608fbee: exit status 128:
        fatal: unable to access 'http://vcs.private.org/sko00o/demo.git/': The requested URL returned error: 500
```

解决办法：取消 git 中的 http 代理 `git config --global --unset http.proxy` 。

## 参考

- [Download and install packages and dependencies](https://golang.org/cmd/go/#hdr-Download_and_install_packages_and_dependencies)

- [Remote import paths](https://golang.org/cmd/go/#hdr-Remote_import_paths)
