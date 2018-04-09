---
title: Windows下zip安装MySQL总结
date: 2018-04-01 22:28:03
tags:
- MySQL
- Windows
---

# 前言

安装MySQL不想用官方安装工具，因为它会添加开机计划任务，自动启动不说还会时不时更新，就很烦。我希望随用随启动，所以要选择zip安装，这样方便可控。
由于记性不好，每次这么装都要查资料，看到网上各种拙劣的教程就很无语，所以决定抽空自己总结下。

# 下载&解压

* [官网](https://dev.mysql.com/downloads/mysql/)下载zip安装包，我选择的是MySQL Community Server。
> zip安装包在`Other Downloads`中，我下载的是mysql-5.7.18-win32.zip
* 解压到任意目录
> 以下以解压到`D:\mysql-5.7.18-win32`为例。

# 环境变量

* 添加系统变量

```text
变量名： MYSQL_HOME
变量值： D:\mysql-5.7.18-win32
```

* Path中添加 `%MYSQL_HOME%\bin`

# 配置文件

MySQL目录下添加`my.ini`文件，内容如下：

```ini
[client]
# 默认编码
default-character-set=utf8
[mysqld]
# 默认编码
character-set-server=utf8
# 设置mysql的安装目录
basedir=D:\mysql-5.7.18-win32
# 设置mysql数据库的数据的存放目录
datadir=D:\mysql-5.7.18-win32\data
# 默认存储引擎
default-storage-engine=InnoDB
```

# 安装

1. 若MySQL目录下有data目录，先清空该目录。
1. 管理员模式启动cmd，切换到MySQL目录下的bin目录中。
1. 运行初始化命令

    ```sh
    mysqld --initialize-insecure
    ```

    稍等一会，没有输出就成功了。

    > 若遇到缺少MSVCP120.dll的问题，前往[这里](https://www.microsoft.com/en-us/download/details.aspx?id=40784)下载安装VC++支持

1. 运行安装命令

    ```sh
    mysqld --install
    ```

    输出`service successfully installed`表明安装成功。

1. 开启服务

    ```sh
    net start mysql
    ```

1. 登录MySQL

    ```sh
    mysql -u root -p
    ```

    > 首次登录没有密码，直接按回车

1. 更改root密码

    ```sh
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('newpass');
    ```

    > `newpass`为新的密码

# 验证编码

root登录MySQL，然后输入以下查询语句：

```sql
show variables like 'character%';
```

你会的到以下结果：

```sql
+--------------------------+-------------------------------------------+
| Variable_name            | Value                                     |
+--------------------------+-------------------------------------------+
| character_set_client     | utf8                                      |
| character_set_connection | utf8                                      |
| character_set_database   | utf8                                      |
| character_set_filesystem | binary                                    |
| character_set_results    | utf8                                      |
| character_set_server     | utf8                                      |
| character_set_system     | utf8                                      |
| character_sets_dir       | D:\mysql-5.7.18-win32\share\charsets\     |
+--------------------------+-------------------------------------------+
```

至此，安装完成。

# 补充

```sh
# 停止MySQL服务
net stop mysql

# 删除MySQL服务
sc delete mysql

# 解除安装
mysqld remove
```