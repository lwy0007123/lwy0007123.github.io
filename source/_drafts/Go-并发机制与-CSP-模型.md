---
title: Go 并发机制与 CSP 模型
tags:
- CSP
- Go
---

CSP (Communicating Sequential Processes) 首次出现在 Tony Hoare 在 1978 年的论文中。

> 注： Tony Hoare 也是快排算法（Quicksort）的作者。

CSP 是用于描述并发系统中交互模式的正式用语。它属于并发数学理论，被称为进程代数（process algebras）或进程计算（peocess calculi），基于通道传递的消息。

CSP 用于描述两个独立的并发实体通过共享通讯管道（channel）进行通信的并发模型。

Goroutine 是 Go 实际并发执行的实体，它底层使用协程（coroutine）实现并发，协程是一种运行在在用户态的用户线程，类似于 greenthread ，它具有以下特点：
	- 用户空间避免了内核态和用户态的切换成本。
	- 可以由语言和框架层进行调度。
	- 更小的栈空间允许创建大量实例。

G （Gorouine）用户级轻量线程，每个 Goroutine 对象中的 sched 保存其上下文信息。
M （Machine） 内核级线程封装，数量对应真实 CPU 数。
P （Processor）用于调度 G 和 M 之间的关联关系，数量可以通过 GOMAXPROCS 设置，默认是核心数。

Go 中常见并发控制：
	- chan 实现并发控制
	- sync.WaitGroup 实现
	- Go 1.7 后引入的 context.Context

## 参考

- [Wiki - Tony Hoare](https://en.wikipedia.org/wiki/Tony_Hoare)
- [Wiki - Communicating Sequential Processes](https://en.wikipedia.org/wiki/Communicating_sequential_processes)
- [KeKe-Li/data-structures-questions](https://github.com/KeKe-Li/data-structures-questions/blob/master/src/chapter05/golang.01.md)
