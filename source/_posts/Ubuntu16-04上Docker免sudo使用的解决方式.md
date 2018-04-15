---
title: Ubuntu16.04上Docker免sudo使用的解决方式
date: 2018-04-15 17:23:29
tags:
-Ubuntu
-Docker
---

## 前言

在Ubuntu16.04上安装Docker-ce后，发现`docker run`不需要在`sudo`下运行，这就导致了一个问题VScode和PyCharm都连不上Docker，都是因为去访问权限的问题，因为不建议用root权限，所以就要找解决办法。

## 解决

1. 修改服务文件

    修改 `/lib/systemd/system/docker.service`

    ```sh
    sudo vim /lib/systemd/system/docker.service
    ```

    找到这一行`ExecStart=/usr/bin/dockerd fd://`，替换为

    ```sh
    ## 大概是开启了docker的tcp访问和unix访问
    ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
    ```

    接着修改 `/etc/init.d/docker`

    ```sh
    sudo vim /etc/init.d/docker
    ```

    找到这一行 `DOCKER_OPTS=`，做类似的修改

    ```sh
    DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"
    ```

1. 添加用户到docker组

    ```sh
    sudo usermod -aG docker $USER
    ```

1. 最后重启你的系统

    ```sh
    sudo reboot
    ```

## 参考

[cannot-connect-to-the-docker-daemon-is-the-docker-daemon-running-on-this-host](https://forums.docker.com/t/cannot-connect-to-the-docker-daemon-is-the-docker-daemon-running-on-this-host/8925/15)
