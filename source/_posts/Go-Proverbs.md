---
title: Go 谚语
date: 2020-01-10 00:00:00
tags:
- Go
---

 > Go 语言之父 Rob Pike 总结的几条 Go 谚语。

 [来源： Go Proverbs - Rob Pike - Gopherfest - November 18, 2015](https://www.youtube.com/watch?v=PAAkCSZUG1c)

1. Don’t communicate by sharing memory, share memory by communicating.
1. Concurrency is not parallism.
1. Channels orchestrate; mutexes serialize.
1. The bigger the interface, the weaker the abstraction.
1. Make the zero value useful. (e.g. bytes.Buffer or sync.Mutex)
1. interface{} says nothing.
1. Gofmt’s style is no one’s favorite, yet gofmt is everyone’s favorite.
1. A little copying is better than a little dependency.
1. Syscall must always be guarded with build tags.
1. Cgo must always be guarded with build tags.
1. Cgo is not Go.
1. With the unsafe package, there are no guarantees.
1. Clear is better than clever.
1. Reflection is never clear.
1. Errors are values.
1. Don’t just check errors, handle them gracefully.
1. Design the architecture, name the components, document the details.
1. Documentation is for users.
1. Don't panic.

## 解读

1. 不要通过共享内存来通信，而应该通过通信的方式共享内存。
    > Go 官方博客的[解读](https://blog.golang.org/share-memory-by-communicating)
1. 并发不是并行。
1. Channels 编排；互斥量的串行化。
    > 使用 chan 串行处理互斥量。
1. 接口越大，抽象能力越弱。
    > 好的接口定义一般不超过两种方法.
1. 让零值有用（比如 bytes.Buffer 或 sync.Mutex）。
1.  interface{} 没有信息。
    > 因为接口类型无法做到静态检查。
1. Gofmt 的风格没有人喜欢，但 Gofmt 却是每个人的最爱。
1. 做一点复制比一点依赖更好。
1. 系统调用必须由构建标签保证。
1. Cgo 必须由构建标签保证。
1. Cgo 不是 Go 。
    > 他说自己几乎不使用 cgo 。
    > Dave 博客的[解读](https://dave.cheney.net/2016/01/18/cgo-is-not-go)。
1. unsafe 包中的内容，没有保证。
1. 清晰比聪明更重要。
    > 书写逻辑清晰的代码，不要耍小聪明。
1. 反射永远是不清晰的。
1. 错误也是值。
    > Go 官方博客的[解读](https://blog.golang.org/errors-are-values)。
1. 不要仅仅检查报错，要优雅的处理它们。
    > Dave 博客的[解读](https://dave.cheney.net/2016/04/27/dont-just-check-errors-handle-them-gracefully)。
1. 设计架构，命名组件，记录细节。
    > 取一个好名字解释起来也省事。
1. 文档是给用户看的。
    > 文档应该记录用户需要知道的内容。
1. 不要恐慌。
    > 程序 panic 不是正常的错误，要找到问题并解决。正常错误用 error 处理。

## 参考

- [Go Proverbs](https://go-proverbs.github.io/)
- [Go 语言中文网 - Go 谚语](https://studygolang.com/articles/12327)
