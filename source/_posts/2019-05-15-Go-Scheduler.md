---
title: Go 调度器如何工作（译）
date: 2019-05-15 13:27:30
tags:
- Go
- scheduler
- translation
---

> 本文翻译自 Go 核心开发者 Ian Lance Taylor, 在 Quora 上的[回答](https://qr.ae/pNrVMG)。

<!--more-->

我将概述从 Go 版本 1.7 开始使用的调度程序。

有三个基础数据结构，被称作 G、M 和 P 。G 是 goroutine， M 是操作系统线程， P 是（逻辑）处理单元。

调度器拥有确切的 GOMAXPROCS 数量的 P （GOMAXPROCS 是一个环境变量，并且运行时函数用它来设置程序中的并发度）。为了让一个 M 执行一个 G ，它需要先获取一个 P 。然后运行 G 直到停止。 G 通过诸如 I/O 操作的系统调用、通过阻塞一个 channel 操作、通过调用一个 C 函数、通过被预抢占（pre-empted），或者一些少数情况来停止。一个 G 只能在安全的地方被预抢占，当前实现中只能在代码发生函数调用时发生。

当一个 G 被 channel 操作之类的东西所阻塞时，它会被放进队列中，此时 M 将会寻找另一个可运行的 G 。如果没有可运行的 G ，这个 M 就会释放 P 然后进入休眠。

当一个 G 被系统调用之类的东西所阻塞时，它会释放 P 且继续在 M 上运行。有一个系统监视器线程，每隔一段时间（20us 到 10ms 之间）就会唤醒一次。如果系统监视器线程发现有可运行的 G 和可用的 P ，它就会唤醒一个正在休眠的 M ，或者没有休眠的 M 就启动一个新的。那个 M 将获得 P 并捡起一个可运行的 G 。

当一个 G 完成一次系统调用时，它必须重新获取 P 。如果没有可用的 P ，它将被标记为可运行接着 M 就会休眠。

当一个 channel 操作成功时，它将唤醒另一个 goroutine ，把它标记为可运行，并且如果有可用的 P ，唤醒一个 M 去运行它。

虽然垃圾回收器多数情况下是并发的，但还是有部分情况需要短暂停止所有线程才能安全地转移到回收的下一个阶段。它通过将所有正在运行的 goroutine 标记为预抢占来实现此目的。当它们到达安全地点时， G 和 M 将会休眠。当垃圾回收器是唯一剩下的正在运行的 G 时，它将进入下一阶段，接着唤醒 GOMAXPROCS [<sup>1</sup>](#note1) 数量的 M ，它们将各自找到可运行的 G 并继续下去。

runtime.Gosched 函数促使 M 将当前的 G 放到可运行 goroutine 列表中，并从那个列表中选取一个新的 G 开始运行。

## 参考

- [How does the golang scheduler work?](https://www.quora.com/How-does-the-golang-scheduler-work/answer/Ian-Lance-Taylor)
- [Go 调度工作机制](https://studygolang.com/articles/12326)

## 注

<div id="note1"></div>

- [1] 原回答中应该是少了个 `S` 。
