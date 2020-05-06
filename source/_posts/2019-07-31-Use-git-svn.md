---
title: 使用 git 管理 svn
date: 2019-07-31 09:24:25
tags:
- git
- svn
---

习惯于使用 git 的你，可能会受不了 svn 残缺的功能。

还好 git 拥有一个十分好用的命令 `git svn`。

本文仅记录普通场景的使用，详细内容见[官方文档](https://git-scm.com/docs/git-svn)。

<!--more-->

## 新建 svn 仓库

主干代码放在 trunk 目录下，即 git 中的 master 分支。

分支代码按分支命名的目录放在 branches 目录下，假如有个分支是 bra1 那么它将在 branches/bra1 下。

标签代码分支代码目录结构一致，排布在 tags 目录下，子目录为标签名称，一般为版本号，类似于 tags/v1.0.0 。

所以一般 svn 仓库的标准目录结构如下：

```sh
project
├── branches
│   ├── bra1
│   └── bra2
├── tags
│   ├── v1.0.0
│   └── v1.1.0
└── trunk
```

## 拉取 svn 仓库

第一步，也是最重要的一步，拉取代码。

咱们使用 `git svn` 命令管理 svn 仓库就需要区分一下目录结构及目录层级。

### 项目在根目录

这种情况，体验相对最舒适，以下命令即可完成：

```sh
git svn clone -s svn://host/project
```

`-s` 让工具知道这是一个标准目录结构。

<details>
<summary>可能遇到的问题</summary>

```sh
Can't locate Term/ReadKey.pm in @INC (you may need to install the Term::ReadKey module)
```

该问题是缺少 perl 模块，无法读取 svn 密码

解决办法：

```sh
sudo cpan Term::ReadKey
```

</details>

<details>
<summary>如果不是标准目录命名</summary>

假如目录结构是这样的：

```sh
project
├── branches1
├── tags2
└── trunk0
```

就自己指定下各类目录的实际名称：

```sh
git svn clone svn://host/project -T trunk0 -b branches1 -t tags2
```

- `-T` 主干目录
- `-b` 分支目录
- `-t` 标签目录

</details>

### 项目不在根目录

> 但现实可能没这么美好。

此时我们的实际项目可能在： `svn://host/s001/p002/project`

咱们不能直接 `git svn clone`，因为会出问题。咱们要把这个命令拆成几步来完成。

```sh
mkdir project && cd project
git svn -s init svn://host/s001/p002/project
```

接着你会看到：

```sh
Initialized empty Git repository in ~/project/.git/
Using higher level of URL: svn://host/s001/p002/project => svn://host/s001
```

它默认去使用了根目录，如果我们有根目录的修改权限，这样也能用，但是我们一般只有 project 那层的权限，所以咱们要修改下当前目录的 git 配置文件。

```sh
git config -e
```

配置文件大概是这样的：

```ini
[core]
    # 省略
[svn-remote "svn"]
    url = svn://host/s001
    fetch = p002/project/trunk:refs/remotes/origin/trunk
    branches = p002/project/branches/*:refs/remotes/origin/*
    tags = p002/project/tags/*:refs/remotes/origin/tags/*
```

修改如下：

```ini
[core]
    # 省略
[svn-remote "svn"]
    url = svn://host/s001/p002/project
    fetch = trunk:refs/remotes/origin/trunk
    branches = branches/*:refs/remotes/origin/*
    tags = tags/*:refs/remotes/origin/tags/*
```

<details>
<summary>如果不是标准目录命名</summary>

```sh
git svn init svn://host/s001/p002/project -T trunk0 -b branches1 -t tags2
git config -e
```

```ini
[svn-remote "svn"]
    url = svn://host/s001/p002/project
    fetch = trunk0:refs/remotes/origin/trunk
    branches = branches1/*:refs/remotes/origin/*
    tags = tags2/*:refs/remotes/origin/tags/*
```

</details>

配置文件保存后，拉取代码：

```sh
git svn fetch
```

## 递交版本

一般流程如下：

**步骤一:**

正常的 git 的方式提交本地记录

当需要将本地记录推送到 svn 服务的时候，使用以下命令：

```sh
git svn dcommit
```

> 这个命令强制要求，版本管理中的文件的更改都已提交到本地记录。

**步骤二:**

当遇到远程仓库已经存在别的提交时，会提交失败，咱们需要先拉取最新版本，但不是用 `git pull`，而是用以下命令：

```sh
git svn rebase
```

**步骤三:**

如果有冲突，手动解决冲突，再进行`步骤一`。

## 新建分支

假如要新建一个分支叫 bra6

```sh
git svn branch -m "new branch bra6" bra6
```

检查所有分支

```sh
git branch -a
```

你能发现有个新的远程分支叫 `remotes/origin/bra6` 。

> 但是当前的活动分支还是指向 `remotes/origin/trunk` 。

## 切换分支

新建一个本地分支映射远程分支，再切换到新的本地分支：

```sh
git branch bra6 remotes/origin/bra6
git checkout bra6
```

模拟提交一次，确认当前活动分支推送到对应的 svn 分支目录：

```sh
git svn dcommit --dry-run
# Committing to svn://host/s001/p002/project/branches/bra6 ...
```

> 你还可以通过 `git svn info` 查看详情

## 参考

- [Reference/External Systems/svn](https://git-scm.com/docs/git-svn)
- [Git 与其他系统 - 作为客户端的 Git](https://git-scm.com/book/zh/v2/Git-%E4%B8%8E%E5%85%B6%E4%BB%96%E7%B3%BB%E7%BB%9F-%E4%BD%9C%E4%B8%BA%E5%AE%A2%E6%88%B7%E7%AB%AF%E7%9A%84-Git)
- [How to switch svn branches using git-svn?](https://stackoverflow.com/questions/728931/how-to-switch-svn-branches-using-git-svn)
