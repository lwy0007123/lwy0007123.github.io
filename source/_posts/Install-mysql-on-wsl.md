---
title: Install mysql on wsl
date: 2018-09-15 13:30:28
categories: WSL
tags:
- WSL
- MySQL
---

# How

1. Install a distro in windows store.

    > I got ubuntu18.04LTS here.

1. Change sources.list

    backup first.

    <!--more-->

    ```sh
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo vi /etc/apt/sources.list
    ```

    run these commands in vi to replace url.

    ```sh
    :%s/archive.ubuntu.com/mirrors.163.com
    :%s/security.ubuntu.com/mirrors.163.com
    ```

1. Install mysql

    > meet some problem when install mariadb, so I change to mysql.
    ```sh
    sudo apt install mysql-server
    sudo service mysql start
    sudo mysql_secure_installation
    ```

1. Adjusting User Authentication and Privileges

    ```sh
    sudo mysql
    # after enter mysql, check which authentication method each of your MySQL user accounts use with the following command
    # SELECT user,authentication_string,plugin,host FROM mysql.user;
    ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'YourPassword';
    FLUSH PRIVILEGES;
    ```

## Ref

[How To Install MySQL on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-18-04)
