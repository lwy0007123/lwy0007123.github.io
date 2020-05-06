---
title: Go 内存模型（译）
tags:
  - Go
  - translation
date: 2020-05-04 00:11:38
---


原文： [The Go Memory Model - Version of May 31, 2014](https://golang.google.cn/ref/mem)

<!--more-->

## 引言

Go 内存模型指定了一种条件，在这种条件下，可以保证在一个 goroutine 中对变量的读取操作可以观察到在不同 goroutine 中对同一变量的写入操作所产生的值。

## 忠告

修改由多个 goroutine 同时访问的数据时，程序必须将这种访问序列化。

为了序列化访问，请使用通道（channel）操作或其他同步原语（例如 `sync` 和 `sync/atomic` 包中的原语）以保护数据。

如果您必须阅读本文档其余部分来了解程序的行为，那么您就太聪明了。

别耍小聪明。

## 发生之前

在单个 goroutine 中，读取和写入行为必须按照程序指定的顺序执行。也就是说，仅当重新排序不会改变语言规范所定义的该 goroutine 中的行为时，编译器和处理器才可以对单个 goroutine 中执行的读取和写入行为重新排序。正因为这个重新排序，一个 goroutine 观察到的执行顺序可能与另一个  goroutine 察觉到的执行顺序不同。例如，如果一个 goroutine 执行 `a = 1; b = 2;`，另一个可能会在 `a` 的值更新以前观察到 `b` 已更新的值。

为了指定读取和写入的要求，我们定义了 `发生之前 (happens before)`，发生在 Go 程序中执行内存操作的部分顺序。如果事件 `e1` 发生在事件 `e2` 之前，那么我们就说 `e2` 发生在 `e1` 之后。同理，如果 `e1` 不在 `e2` 之前发生并且在 `e2` 发生之后也没有发生，那么我们说 `e1` 和 `e2` 同时发生。

> 在单个 goroutine 中，事前发生（happens-before）顺序是程序表示的顺序。

如果同时满足以下两个条件，则允许变量 v 的读操作 `r` 观察到对 v 的写操作 `w` ：

1. `r` 不在 `w` 之前发生 。
1. 在 `w` 之后但在 `r` 之前没有发生对 v 的其他写入 `w'` 。

为了保证变量 v 的读取操作 `r` 能观察到对 v 的特定写入操作 `w` ，确保 `w` 是唯一允许 `r` 观察的写操作。也就是说，如果以下两个条件成立，则保证 `r` 能观察到 `w` ：

1. `w` 发生在 `r` 之前。
1. 任何对共享变量 v 的其他写操作，发生在 `w` 之前或 `r` 之后。

这一对条件要比第一对条件更苛刻，它要求没有其他写入操作与 `w` 或者 `r` 同时发生。

在一个 goroutine 中，没有并发，因此两个定义是等效的：一个读操作 `r` 观察到最近写操作 `w` 写入变量 v 的值。当多个 goroutine 访问共享变量 v 时，它们必须使用同步事件来建立事前发生条件，这些条件必须确保读取操作能够观察到所需的写入操作。

用 v 的类型的零值初始化变量 v 的行为与在内存模型中的写操作相同。

大于单个机器字的值的读写将表现为未指定顺序的多个机器字（machine-word-sized）大小的操作。

## 同步

### 初始化

程序初始化在单个 goroutine 中运行，但是该 goroutine 可能会创建其他同时运行的  goroutine 。

> 如果包 p 导入了包 q ，则 q 的 `init` 函数会在 p 包中的任何函数之前完成。

> 函数 `main.main` 的启动发生在所有 `init` 函数完成之后。

### goroutine 的创建

> 启动新的 goroutine 的 Go 语句在 goroutine 的执行开始之前发生。

例如，这段程序：

```go
var a string

func f() {
	print(a)
}

func hello() {
	a = "hello, world"
	go f()
}
```

调用 `hello` 函数会在将来某个时候（也许是 `hello` 返回之后）打印出 "hello, world" 。

### goroutine 的销毁

不能保证 goroutine 的退出会在程序发生任何事件之前发生。例如，这段程序中：

```go
var a string

func hello() {
	go func() { a = "hello" }()
	print(a)
}
```

给 `a` 分配之后没有任何同步事件，因此，不能保证任何其他 goroutine 能观察到它的值。实际上，激进的编译器可能会删除整个 `go` 语句。

如果必须通过另一个 goroutine 来观察 goroutine 的影响，请使用同步机制（例如锁或者通道通信）来建立相对顺序。

### 通道通信

通道是 goroutine 之间同步的主要方法。通常在不同的 goroutine 中，将特定通道上的每个发送与该通道上的响应接收进行匹配。

> 在一个通道上的发送操作在那个通道相应接收操作之前发生。

这有段程序：

```go
var c = make(chan int, 10)
var a string

func f() {
	a = "hello, world"
	c <- 0
}

func main() {
	go f()
	<-c
	print(a)
}
```

这段代码就能保证打印出 "hello, world" 。对 `a` 的写操作一定发生在发消息给 `c` 之前，即发生在 `c` 上相应接收完成之前，即发生在打印（print）之前。

> 通道的关闭发生在关闭的通道返回的零值被接收前。

在前面的示例中，用 `close(c)` 替换  `c <- 0` 也能达到相同的保证。

> 无缓冲通道的接收发生在该通道上的发送完成之前。

这段程序（与上一段相似，但是发送和接收的语句被交换，并使用了无缓冲的通道)

```go
var c = make(chan int)
var a string

func f() {
	a = "hello, world"
	<-c
}

func main() {
	go f()
	c <- 0
	print(a)
}
```

也保证能打印 "hello, world" 。对 `a` 的写操作发生在 c 接收之前，即发生在相应的 `c` 上发送完成之前，即发生在打印之前。

如果是有缓冲的通道（例如： `c = make(chan int, 1)`）那么程序就不能保证打印出 "hello, world" 了（可能打印出空字符串，崩溃或者其他）。

> 容量为 C 的通道上的第 k 个接收发生在该通道的第 k+C 个发送完成之前。

通道中的项目数量对应有效使用的数量，通道的容量对应与最大同时使用的数量，发送项目会获取信号量，接收项目会释放信号量。这是限制并发的常见惯用用法。

该程序为工作列表中的每个条目启动一个 goroutine ，但是 goroutine 使用限制通道进行协调，以确保一次最多运行三个函数。

```go
var limit = make(chan int, 3)

func main() {
	for _, w := range work {
		go func(w func()) {
			limit <- 1
			w()
			<-limit
		}(w)
	}
	select{}
}
```

### 锁

sync 包实现了两种锁定数据类型，即 `sync.Mutex` 和 `sync.RWMutex` 。

> 对于任何 `sync.Mutex` 或者 `sync.RWMutex` 类型的变量 l ，第 n 次 `l.Unlock()` 的调用发生在第 m 次 `l.Lock()` 的调用返回之前，其中 n < m 。

这段程序：

```go
var l sync.Mutex
var a string

func f() {
	a = "hello, world"
	l.Unlock()
}

func main() {
	l.Lock()
	go f()
	l.Lock()
	print(a)
}
```

也保证可以打印出 "hello, world" 。第一次调用 `l.Unlock()` （在 f 中） 发生在第二次调用 `l.Lock()` （在 main 中） 返回之前，即在 `print` 函数之前。

> 对于一个 `sync.RWMutex` 类型的变量 `l` 的的任何 `l.RLock()` 调用，第 n 次 `l.RLock()` 在 n 次 `l.Unlock()` 之后发生（返回），并且与之匹配的 `l.RUnlock()` 在 n+1 次 `l.Lock()` 之前发生。

### 一次（Once）

`sync` 包为使用 `Once` 类型的多个 goroutine 进行初始化提供了一种安全的机制。多个线程可以对特定的 `f` 函数，执行 `once.Do(f)` ，但是只有一个线程会执行 `f()` ，其他的调用会被阻塞直到 `f()` 返回。

> 使用 `once.Do(f)` 单次调用 `f()` 发生（返回）在任何一次 `once.Do(f)` 调用返回之前。

这段程序中：

```go
var a string
var once sync.Once

func setup() {
	a = "hello, world"
}

func doprint() {
	once.Do(setup)
	print(a)
}

func twoprint() {
	go doprint()
	go doprint()
}
```

调用 `twoprint` 函数将完全调用一次 `setup` 函数。`setup` 函数将在两次调用 `print` 之前完成。最后将打印两次 "hello, world" 。

## 同步不正确

注意，一个读取操作 `r` 可能会观察到一个同时发生的写入操作 `w` 写入的值。即使发生这种情况，也不意味着 `r` 之后发生的读取操作将观察到 `w` 之前发生的写入操作。

这段程序中：

```go
var a, b int

func f() {
	a = 1
	b = 2
}

func g() {
	print(b)
	print(a)
}

func main() {
	go f()
	g()
}
```

有可能 `g` 先打印 2 ，然后打印 0 。

这实际上使一些惯用习语无效。

双重检查锁定是为了避免同步的开销。例如， `twoprint` 程序可能被错误地写成：

```go
var a string
var done bool

func setup() {
	a = "hello, world"
	done = true
}

func doprint() {
	if !done {
		once.Do(setup)
	}
	print(a)
}

func twoprint() {
	go doprint()
	go doprint()
}
```

但不能保证在 `doprint` 中观察到写入 `done` 就意味着写入了 `a` 。此版本可以（错误地）打印出一个空字符串，而不是 "hello, world" 。

另一个不正确地习惯用法是忙于等待一个值，例如：

```go
var a string
var done bool

func setup() {
	a = "hello, world"
	done = true
}

func main() {
	go setup()
	for !done {
	}
	print(a)
}
```

和上一个例子一样，不能保证在 `main` 上观察到写入 `done` 就意味着写入了 `a` ，因此该程序也可能打印一个空字符串。更糟糕的是，由于两个线程之间没有同步事件，因此无法保证对 `done` 的写入操作被 `main` 观察到。不能保证 `main` 中的循环能完成。

此主题有一些微妙的变体，例如该程序：

```go
type T struct {
	msg string
}

var g *T

func setup() {
	t := new(T)
	t.msg = "hello, world"
	g = t
}

func main() {
	go setup()
	for g == nil {
	}
	print(g.msg)
}
```

即使 `main` 观察到 `g != nil` 并且退出它的循环，也无法保证它将观察到对 
`g.ms`g 初始化的值。

所有这些例子，解决方案都是相同的：使用显式同步。
