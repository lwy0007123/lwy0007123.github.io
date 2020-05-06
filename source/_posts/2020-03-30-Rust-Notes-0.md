---
title: Rust 学习笔记 0
date: 2020-03-30 23:39:35
tags:
- rust
---

阅读 [《 Rust 程序设计》](https://doc.rust-lang.org/book)的一些笔记。

第 1 章 - 第一个 Rust 项目

<!--more-->

## 安装 Rust

```sh
curl https://sh.rustup.rs -sSf | sh

export PATH="$HOME/.cargo/bin:$PATH"
```

> default 模式安装，会修改 ~/.profile 文件，需要手动修改你的环境变量。

## 新建项目

```sh
# 由于数字开头的 crate 名称不合法，所以使用 --name 指定 crate 名称
cargo new 002_helloworld --name hello_cargo
cd 002_hello_cargo
```

## 编译运行

```sh
cargo build
./target/debug/hello_cargo
```

也可以

```sh
cargo run
```

> 代码没做改动的情况下，不会重新编译，而是直接运行可执行文件。

## 代码检查

```sh
cargo check
```

> 因为不需要生成执行文件，所以 `check` 非常快。

## 构建发布

```sh
cargo build --release
```

> 加上 `--release` 会优化编译（编译速度较慢），可执行文件生成至 `target/release` 目录。

> 如果你需要 benchmark ，那么就要指定 `--release` 。

> 复杂项目的构建使用 `cargo` 将能体现它的价值。

