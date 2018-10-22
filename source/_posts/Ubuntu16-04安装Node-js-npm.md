---
title: Ubuntu16.04安装Node.js&npm
date: 2018-04-15 11:28:53
categories: Linux
tags:
- Linux
- Nodejs
- npm
- Ubuntu
---

# 下载

Ubuntu16.04 官方仓库提供的Node.js版本是4.x，不推荐使用apt安装。

我们需要从[官网](https://nodejs.org/zh-cn/)获得更新的版本。

<!--more-->

这里直接wget获得

```sh
wget http://nodejs.org/dist/v8.1.1/node-v8.1.1-linux-x64.tar.gz
```

# 安装

找到下载的压缩文件，解压系统应用目录

```sh
sudo tar -C /usr/local --strip-components 1 -xzf node-v8.1.1-linux-x64.tar.gz
```

# 验证

查看是否安装到了正确的目录

```sh
ls -l /usr/local/bin/node
ls -l /usr/local/bin/npm
node -v
npm -v
```

# 参考资料

[Installing a tar.gz on linux](https://stackoverflow.com/questions/33033538/installing-a-tar-gz-on-linux?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa)

[我的另一篇文章，有关npm加速](http://www.findshank.com/2017/08/06/%E4%B8%80%E4%BA%9B%E8%8A%82%E7%BA%A6%E7%94%9F%E5%91%BD%E7%9A%84%E6%93%8D%E4%BD%9C/#more)