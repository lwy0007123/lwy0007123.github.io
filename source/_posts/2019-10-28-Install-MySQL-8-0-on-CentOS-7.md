---
title: CentOS 7 安装 MySQL 8.0
date: 2019-10-28 13:43:10
tags:
- CentOS
- MySQL
---

记录下在 CentOS 7 上安装 MySQL 8.0 ，并启用兼容性的密码验证。

<!--more-->

## 安装记录

查看当前 linux 版本，执行 `uname -a`，结果如下：

```output
Linux localhost.localdomain 3.10.0-1062.el7.x86_64 #1 SMP Wed Aug 7 18:08:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```

访问官网获取 linux 7 版本的仓库安装包。

```sh
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
```

MD5 校验

```sh
md5sum mysql80-community-release-el7-3.noarch.rpm
```

对照输出

```output
893b55d5d885df5c4d4cf7c4f2f6c153  mysql80-community-release-el7-3.noarch.rpm
```

添加官方仓库

```sh
sudo rpm -ivh mysql80-community-release-el7-3.noarch.rpm
```

替换阿里云镜像加速下载（可选）

```sh
sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```

安装 MySQL 

```sh
sudo yum -y install mysql-server
```

添加并启动守护进程

```sh
sudo systemctl enable mysqld
sudo systemctl start mysqld
```

检查运行状态

```sh
systemctl status mysqld
```

查找临时 root 密码

```sh
sudo grep 'temporary password' /var/log/mysqld.log
```

密码在行末

```output
2019-10-29T06:28:08.128300Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: Z-_%r1L3PRuJ
```

配置 MySQL

```sh
sudo mysql_secure_installation
```

按提示，输入刚才找到的密码，然后变更为新密码（要求足够复杂，包含大小写字母数字及特殊字符）。

登录数据库

```sh
mysql -u root -p
```

新建用户

```sh
use mysql;
CREATE USER 'appuser'@'%' IDENTIFIED BY 'P@ssw0rd';
FLUSH PRIVILEGES; 
ALTER USER 'appuser'@'%' IDENTIFIED WITH mysql_native_password BY 'P@ssw0rd';
```

启用密码验证插件与旧版兼容

```sh
sudo vim /etc/my.cnf

# 末尾添加一行
default-authentication-plugin=mysql_native_password
```

重启 MySQL

```sh
sudo systemctl restart mysqld
```

防火墙设置（可选）

CentOS 默认启用防火墙进程（firewalld）

为 MySQL 开放全 IP 端口

```sh
sudo firewall-cmd --zone=public --add-service=mysql --permanent
sudo firewall-cmd --reload
```

## 参考

- [How To Install MySQL on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7)
- [How to Allow MySQL Traffic using firewalld on CentOS 7](https://wiki.mikejung.biz/Firewalld)
