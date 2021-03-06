---
title: DST Server on Ubuntu16.04 (饥荒服务搭建指南)
date: 2018-05-29 22:37:32
tags:
- DST
- Linux
---

与朋友玩DST(饥荒)，开个5人局，卡到没法玩，所以想办法搭私服。

首先感谢[路叔的视频](https://www.bilibili.com/video/av12666273/)以及[这个帖子](https://tieba.baidu.com/p/4159392559)

* 复制粘贴以下脚本保存为 `install.sh`

> update `install.sh` at 2018-12-15

<!--more-->

```sh
#!/bin/bash

dividing="================================================================================"
commandPath="steamcmd"
commandFile="./steamcmd.sh"

gamesPath="Steam/steamapps/common/Don't Starve Together Dedicated Server/bin"
gamesFile="./dontstarve_dedicated_server_nullrenderer"

dataPath=$(pwd)/.klei

function FilesDelete()
{
    echo -e "\033[32m[info] Choose File To Delete [1-5]\033[0m"
    read input_filedelete

    if [ -d $dataPath ]; then
        cd $dataPath
        if [ -d "DoNotStarveServer_$input_filedelete" ]; then
            rm -r DoNotStarveServer_$input_filedelete/save
            echo -e "\033[33m[info] File DoNotStarveServer_$input_filedelete Is Deleted\033[0m"
        fi
        if [ -d "DoNotStarveCaves_$input_filedelete" ]; then
            rm -r DoNotStarveCaves_$input_filedelete/save
            echo -e "\033[33m[info] File DoNotStarveCaves_$input_filedelete Is Deleted\033[0m"
        fi
        cd "../"
    fi
}

function FilesBackup()
{
    echo -e "\033[32m[info] Choose File To Backup [1-5]\033[0m"
    read input_filebackup

    if [ -d $dataPath ]; then
        cd $dataPath
        if [ -d "DoNotStarveServer_$input_filebackup" ]; then
            tar -zcf DoNotStarveServer_$input_filebackup.tar.gz DoNotStarveServer_$input_filebackup
            echo -e "\033[33m[info] File DoNotStarveServer_$input_filebackup Is Backuped\033[0m"
        fi
        if [ -d "DoNotStarveCaves_$input_filebackup" ]; then
            tar -zcf DoNotStarveCaves_$input_filebackup.tar.gz DoNotStarveCaves_$input_filebackup
            echo -e "\033[33m[info] File DoNotStarveCaves_$input_filebackup Is Backuped\033[0m"
        fi
        cd "../"
    fi
}

function FilesRecovery()
{
    echo -e "\033[32m[info] Choose File To Recovery [1-5]\033[0m"
    read input_filerecovery

    if [ -d $dataPath ]; then
        cd $dataPath
        if [ -f "DoNotStarveServer_$input_filerecovery.tar.gz" ]; then
            if [ -d "DoNotStarveServer_$input_filerecovery" ]; then
                rm -r DoNotStarveServer_$input_filerecovery
            fi
            tar -zxf DoNotStarveServer_$input_filerecovery.tar.gz DoNotStarveServer_$input_filerecovery
            echo -e "\033[33m[info] File DoNotStarveServer_$input_filerecovery Is Recovered\033[0m"
        else
            echo -e "\033[31m[warn] Backup File For DoNotStarveServer_$input_filerecovery Not Found\033[0m"
        fi

        if [ -f "DoNotStarveCaves_$input_filerecovery.tar.gz" ]; then
            if [ -d "DoNotStarveCaves_$input_filerecovery" ]; then
                rm -r DoNotStarveCaves_$input_filerecovery
            fi
            tar -zxf DoNotStarveCaves_$input_filerecovery.tar.gz DoNotStarveCaves_$input_filerecovery
            echo -e "\033[33m[info] File DoNotStarveCaves_$input_filerecovery Is Recovered\033[0m"
        else
            echo -e "\033[31m[warn] Backup File For DoNotStarveCaves_$input_filerecovery Not Found\033[0m"
        fi
        cd "../"
    else
        echo -e "\033[31m[warn] Main Archive Folder Not Found\033[0m"
    fi
}

function SystemPrepsDetail()
{
    echo -e "\033[33m[info] System Library Install\033[0m"
    sudo apt-get update
    sudo apt-get install screen
    sudo apt-get install lib32gcc1
    sudo apt-get install lib32stdc++6
    sudo apt-get install libcurl4-gnutls-dev:i386
    echo -e "\033[33m[info] System Library Install Finished\033[0m"
    echo "$dividing"
}

function SystemPreps()
{
    echo -e "\033[33m[info] System Library Preparing\033[0m"
    sudo apt-get update                                                         1>/dev/null
    sudo apt-get install screen                                                 1>/dev/null
    sudo apt-get install lib32gcc1                                              1>/dev/null
    sudo apt-get install lib32stdc++6                                           1>/dev/null
    sudo apt-get install libcurl4-gnutls-dev:i386                               1>/dev/null
    echo -e "\033[33m[info] System Library Prepare Finished\033[0m"
    echo "$dividing"
}

function CommandPreps()
{
    echo -e "\033[33m[info] Steam Command Line Files Preparing\033[0m"

    if [ ! -d "$commandPath" ]; then
        mkdir "$commandPath"
    fi
    cd "$commandPath"

    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz 1>/dev/null
    tar -xvzf steamcmd_linux.tar.gz                                             1>/dev/null
    rm -f steamcmd_linux.tar.gz                                                 1>/dev/null

    echo -e "\033[33m[info] Steam Command Line Files Prepare Finished\033[0m"
    echo "$dividing"
}

function ServerStart()
{  
    echo -e "\033[32m[info] Choose Game Mode [1.noraml] [2.caves]\033[0m"
    read input_mode
    echo -e "\033[32m[info] Choose Save File [1-5]\033[0m"
    read input_save

    cd "$gamesPath"
    case $input_mode in
        1)
            screen -dm -S "DST Server" "$gamesFile" -conf_dir DoNotStarveServer_"$input_save";;
        2)
            screen -dm -S "DST Server" "$gamesFile" -conf_dir DoNotStarveCaves_"$input_save";;
        *)
            echo -e "\033[31m[warn] Illegal Command,Please Check\033[0m" ;;
    esac
    screen -r "DST Server"

    echo "$dividing"
}

function ServerPreps()
{
    echo -e "\033[33m[info] Preparing Server Files\033[0m"
    if [ ! -d "$commandPath" ]; then
        echo -e "\033[31m[warn] Steam Command Line Not Found\033[0m"
        CommandPreps
    else
        echo -e "\033[33m[info] Steam Command Line Found\033[0m"
        cd "$commandPath"
    fi

    echo -e "\033[32m[info] Choose Game Update Mode [1.noraml] [2.caves]\033[0m"
    read input_game

    case $input_game in
        1)
            "$commandFile" +login anonymous +app_update 343050 validate +quit;;
        2)
            "$commandFile" +login anonymous +app_update 343050 -beta cavesbeta validate +quit;;
        *)
            echo -e "\033[31m[warn] Illegal Command,Please Check\033[0m" ;;
    esac

    cd "../"
    echo "$dividing"
    ServerStart
}

clear
echo "$dividing"

if [ ! -d "$gamesPath" ]; then
    echo -e "\033[31m[warn] Server Files Not Found\033[0m"
    echo "$dividing"
    SystemPrepsDetail
    ServerPreps
else
    echo -e "\033[32m[info] Server Files Found\033[0m"
    echo "$dividing"
    echo -e "\033[33m[info] Choose An Action To Perform\033[0m"

    echo -e "\033[32m[info] System Library Files [0.Prepare]\033[0m"
    echo -e "\033[32m[info] Game Server [1.start]  [2.update]  [3.process kill]\033[0m"
    echo -e "\033[32m[info] Save Files  [7.backup] [8.recovery][9.delete]\033[0m"
    read input_update

    case $input_update in
        0)
            SystemPreps
            ;;
        1)
            ServerStart
            ;;
        2)
            ServerPreps
            ;;
        3)
            screen -X -S "DST Server" quit
            ;;
        7)
            FilesBackup
            ;;
        8)
            FilesRecovery
            ;;
        9)
            FilesDelete
            ;;
    esac
fi
```

* 添加运行权限

```sh
sudo chmod u+x install.sh
```

* 运行脚本

```sh
sh install.sh
# 按下面的输入数字选择：
# Game Mode: 1
# Save File: 1
# Ctrl+c 中断进程
```

* 获得 `Token`

如何获得参考[这里](http://blog.ttionya.com/article-1235.html)：

游戏主界面右下角 `Account` -> `Generate Server Token` -> 复制粘贴保存到 `cluster_token.txt`。

* 本地打开DST，创建一个在线世界，Mod 什么都设置好，点击开始进游戏，然后关闭保存游戏。

找到存档 Linux存档位置：`~/.klei/DoNotStarveTogether` Windows存档位置：`%HOMEPATH%\Klei\DoNotStarveTogether\`。

将对应的 `Cluster_X` 目录覆盖到云主机的下面目录：`~/.klei/DoNotStarveserver_1/`。

> 这里我的存档为 `Cluster_1`。

~~将上一步获得的 `cluster_token.txt` 放到 `Cluster_X` 目录下~~ 存档目录下已存在该文件可以不用替换。

* 记录Mod编号

打开存档目录下的 `Master/modoverrides.lua` 文件，记录所有的 `workshop-XXXXXXXXX` 中的数字编号。

打开 `~/Steam/steamapps/common/Don't Starve Together Dedicated Server/mods/dedocated_server_mods_setup.lua` 将Mod按 `ServerModSetup("XXXXXXXXX")` 的格式一行一行写进去并保存。

* 再次运行 `install.sh`，选择 `1.start`。

几分钟后即可在 DST 的 online 列表中搜到你的服务器。

> 我上面写的教程没开 Cave，你可以通过看视频把 Cave 服务打开，过程类似。