---
title: 'screen: Cannot open your terminal ''/dev/pts/1'''
date: 2018-07-25 14:35:57
categories: Linux
tags:
- Screen
- Linux
---

# What happened

I bought a Tencent Cloud CVM to hold my DST server few days ago.

<!--more-->

Use screen to run `server.sh` is perfect. I login `UserA` to run screen session. Then, use another device to login `UserB`. When I use `UserB` to login `UserA` and run `screen -r` to continue my screen session, following error occur:

```sh
Cannot open your terminal '/dev/pts/1' - please check.
```

# How to Fix

After login in `UserB`, run this to get a new `tty`

```sh
script /dev/null
```

# Reference

[polygun2000's blog](http://blog.sina.com.cn/s/blog_704836f401010osn.html)