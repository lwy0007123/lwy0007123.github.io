---
title: 墙内加速 git pip conda npm docker
date: 2017-08-06 12:49:00
tags: 
- git
- pip
- npm
- docker
- conda
---

你是否感觉  pip， npm, git， docker 之类的工具下载安装奇慢？
因为它们的默认服务器都在国外，那么需要必要的设置才能发挥咱百兆光纤的作用。下面介绍方法:

<!--more-->

<details>

<summary>如果你用的是 linux，别折腾了挂代理解决一切问题</summary>

简单配置下全局代理，也可以将下面这句加入 profile 中

```sh
# 假如你的代理地址是 http://127.0.0.1:1080
export proxy=http://127.0.0.1:1080; export http_proxy=$proxy https_proxy=$proxy no_proxy="localhost, 127.0.0.0/8, ::1"
```

用 `privoxy` 稍微折腾下见[这篇文章](http://www.findshank.com/2018/04/15/Linux%E4%B8%8B%E4%BD%BF%E7%94%A8SS%E6%9C%AC%E5%9C%B0%E4%BB%A3%E7%90%86/)

</details>

## pip 的配置

解决方式：使用国内的pypi镜像加速，以阿里源为例。

### 方法1 修改配置

* Linux

```sh
mkdir ~/.pip && echo "[global]
trusted-host =  mirrors.aliyun.com
index-url = http://mirrors.aliyun.com/pypi/simple" > ~/.pip/pip.conf
```

> 欲使用其他源，自行搜索替换。更多配置参数见[官方文档](http://www.pip-installer.org/en/latest/configuration.html)。

* Windows

打开powershell(不是cmd!)，粘贴下面命令。

```sh
mkdir ~/pip/
echo "[global]
trusted-host =  mirrors.aliyun.com
index-url = http://mirrors.aliyun.com/pypi/simple
" | out-file -encoding ascii ~/pip/pip.ini
```

解释：在用户目录(C:\Users\Username)下新建名为pip的目录，目录下新建文件pip.ini，写入阿里的镜像源配置。

> P.S 因为默认输出编码为utf16会导致pip出错，必须指定编码。

### 方法2 临时使用

以安装numpy为例。

```shell
pip install numpy -i http://mirrors.aliyun.com/pypi/simple/
```

## conda 的配置

### 方法1 配置代理

```sh
conda config --set proxy_servers.http http://id:pw@address:port
conda config --set proxy_servers.https https://id:pw@address:port
```

> ref: [Running conda with proxy](https://stackoverflow.com/a/48416007)

### 方法2 配置国内镜像

```sh
# 添加 Anaconda 的清华镜像
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
# 搜索时显示通道地址
conda config --set show_channel_urls yes
```

> ref: [Managing channels](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-channels.html)

## git 的配置

这个就要代理了。

### 方法1 设置git全局变量

~~我曾经使用的lantern~~，它提供两种代理端口： Http(s) 和 Socks5。使用下面命令配置git代理：

```sh
git config --global http.proxy http://127.0.0.1:50219
git config --global https.proxy https://127.0.0.1:50219
```

或者

```sh
git config --global http.proxy socks5://127.0.0.1:50221
git config --global https.proxy socks5://127.0.0.1:50221
```

根据你的代理配置，修改对应部分即可。

### 方法2 设置临时变量

`git clone` 时可以这么写:

```sh
ALL_PROXY=http://127.0.0.1:1080 git clone https://github.com/some/one.git
```

## docker

解决方法：使用国内的加速地址。获取途径很多。我使用的是阿里云的容器镜像服务里的专属加速地址。

> `PCODE` 是阿里云帐户的加速前缀，后文中请自行替换。可以在[这里](https://cr.console.aliyun.com/#/accelerator)获取

* Linux

修改`/etc/docker/daemon.json`

```sh 
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://PCODE.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

> P.S Docker版本需大于1.10.0

* Windows

> 我的系统是Window10，官方推荐使用 `Docker for Windows` ，此处不介绍 `Docker Toolbox`

在系统右下角托盘图标内右键菜单选择 Settings，打开配置窗口后左侧导航菜单选择 Docker Daemon。编辑窗口内的JSON串，填写加速器地址，如下所示：

```sh
{
  "registry-mirrors": ["https://PCODE.mirror.aliyuncs.com"]
}
```

编辑完成，点击 Apply 保存按钮，等待Docker重启并应用配置的镜像加速器。

> `Docker for Windows` 和 `Docker Toolbox`是不兼容的。

## npm 的配置

### 挂代理是最好的解决办法

```sh
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080
```

<details>

<summary> update: 之前的方式均不推荐！ </summary>

~~解决方式：也是替换国内的源，以淘宝源为例。~~

### ~~方法1 修改默认库配置(不推荐！会有莫名其妙的问题)~~

```sh
npm config set registry https://registry.npm.taobao.org
```

### ~~方法2 使用cnpm~~

使用cnpm命令替代npm命令。

```sh
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

### ~~方法3 临时替换下载源~~

以安装Express为例。

```sh
npm --registry=https://registry.npm.taobao.org install express
```

</details>

## 后记

~~能省一秒是一秒对吧，毕竟不是所有人都有+1s的能力~~
