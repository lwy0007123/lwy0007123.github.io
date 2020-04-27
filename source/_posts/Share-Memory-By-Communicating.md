---
title: 通过通信共享内存（译）
date: 2020-04-27 22:42:50
tags:
- Go
- translation
---

> 原文 [The Go Blog - Share Memory By Communicating](https://blog.golang.org/codelab-share)

<!--more-->

传统线程模型（例如，在编写 Java、 C++ 和 Python 程序时常用）要求程序员使用共享内存在线程之间通信。通常，共享数据结构受锁的保护，线程将争夺这些锁以访问数据。在某些情况下，通过使用线程安全的数据结构（例如 Python 的队列）可以使此操作变得更容易。

Go 的并发原语 —— goroutine 和 channel ，提供了一种优雅而独特的方式来构造并发软件。（这些概念有一段有趣的历史，始于 C.A.R Hoare 的[通信顺序流程 CSP](http://www.usingcsp.com/)。）与其明确使用锁来调解对共享数据的访问，Go 鼓励使用 channels 在 goroutine 之间传递对数据引用。这种方法确保在给定时间只有一个 goroutine 可以访问数据。该概念在 [Effective Go](https://golang.org/doc/effective_go.html)（Go 程序员必读）中进行了总结。

`不要通过共享内存通信，而是，通过通信共享内存。`

考虑一个轮询 URL 列表的程序。在传统的线程环境中，人们可能会这样构造其数据：

```go
type Resource struct {
    url        string
    polling    bool
    lastPolled int64
}

type Resources struct {
    data []*Resource
    lock *sync.Mutex
}
```

然后，一个轮询器函数（其中的许多函数将在单独线程中运行）可能看起来像这样：

```go
func Poller(res *Resources) {
    for {
        // 获取最近最少轮询的资源
        // 并将其标记为已轮询
        res.lock.Lock()
        var r *Resource
        for _, v := range res.data {
            if v.polling {
                continue
            }
            if r == nil || v.lastPolled < r.lastPolled {
                r = v
            }
        }
        if r != nil {
            r.polling = true
        }
        res.lock.Unlock()
        if r == nil {
            continue
        }

        // 轮询 URL

        // 更新资源的 polling 和 lastPolled
        res.lock.Lock()
        r.polling = false
        r.lastPolled = time.Nanoseconds()
        res.lock.Unlock()
    }
}
```

此函数大约要写一页纸，并且需要更多细节才能完成。它甚至不包括 URL 轮询逻辑（它本身只有几行），也不能优雅地处理资源池耗尽的问题。

让我们看一下使用 Go 惯用语实现的相同功能。在这个例子中，轮询器是一个函数，可以从输入 channel 接收要轮询地资源，并在完成后将其发送给输入 channel 。

```go
type Resource string

func Poller(in, out chan *Resource) {
    for r := range in {
        // 轮询 URL

        // 将处理后地资源发送出去
        out <- r
    }
}
```

上一个示例中地微妙逻辑显然不存在，并且我们的资源数据结构不再包含用作标记的字段。实际上，剩下的就是重要的部分。这应该使你对这些简单语言功能的强大之处有所了解了。

上述代码有很多遗漏之处。使用 Go 的惯用写法的完整实现，移步 Codewalk [通过通信共享内存](https://golang.org/doc/codewalk/sharemem/)
