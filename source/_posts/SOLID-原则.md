---
title: SOLID 原则 —— 理解现实中的问题（译）
date: 2020-04-14 16:28:50
tags:
- translation
- design pattern
---

[原文：SOLID Principles — Understanding with Real-Life Problems.](https://medium.com/@minhajukhan/solid-principles-and-how-we-write-code-57beb1668db3)

毕业至今进入软件公司工作，我们多次接受有关 SOLID 原则的讲座，其中包括其定义和抽象示例。
今天我们将以不同的方式去理解这个原则。

我们遵循 SOLID 原则从头开始构造一些东西。

如果你是初学者，不知道什么是 SOLID ，没关系，边看边学。

<!--more-->

---

最近我被要求实现一个服务，该服务在某些事件发生时发送文本消息。

这里是需求：

1. 在系统发生登录事件时，从分布式队列接收一条消息。
1. 根据配置验证传入的消息，评估向哪些用户发送短信消息。
1. 发送短信消息给评估通过的用户。

简单，那么用我最喜欢的 Go 语言实现。

## 1. 单一职责原则 (Single Responsibility Principle)

> 一个类或模块应该有且仅有一个被修改的原因。

考虑到需求，我将应用拆成三个组件。

1. 消费者 （consumer） —— 从分布式队列读取消息
1. 规则引擎 （rule engine） —— 根据传入消息验证用户
1. 通知者（notifier） —— 发送消息给通过验证的用户

### 消费者

消费者应该只做一件事：从队列中读取消息，传递给规则引擎。

我们服务中的这个消费者是一个简单的 Kafka 消费者，它可以读取消息。

```go
for message := range claim.Messages() {
    n.Engine.ProcessEvent(message)
}
```

### 规则引擎

当你把某物称为引擎时，意味着你暗示它很强大，它管理这系统中困难工作的核心。这里想法类似。

当我的规则引擎启动（实例化）时，它就等待 `ProcessEvent()` 接口被调用。在我们的例子中是，消费者去调用它。

因此，它主要负责一件事，至少对外是这样的。

```go
type Engine interface {
    ProcessEvent(message types.NotificationMessage) error
}
```

### 小结

如果你真的以 SRP（单一职责原则） 的方式考虑架构组件，那么可以创建出相同行为的接口或类。

## 2. 开闭原则 （Open Closed Principle）

> 软件实体应该为拓展而开放，为修改而封闭。

更进一步，我们来实现通知者组件。

### 通知者，天真的实现

一种天真的方式将是简单，简洁且直接的：

1. 实现一个类。
2. 在需要时传递类实例。

```go
type SMSNotifier struct {}
func (s *SMSNotifier) SendSMS(msg string, recipient string) error
```

> 对于不熟悉 Go 的程序员，第二句表示该类拥有名为 SendSMS 的方法。

### 通知者，一种更好的实现

1. 定义一个接口，具体类要实现这个接口。
1. 传递实现了该接口的具体类的实例。

接口：

```go
type Notifier interface {
    Notify(msg string, recipient string) error
}
```

类：

```go
type SMSNotifier struct {}
func (s *SMSNotifier) Notify(msg string, recipient string) error
```

- 问： 为什么后一种方法更好？
- 答： 考虑“天真”方式的实现，如果客户还要求我们通过电子邮件发送通知，我们就要“打开” SMSNotifier 类的实现，并在其中添加代码。这不可避免地违反了开闭原则。如果我们考虑了后者地实现，我们只需要实现另一个通知者。

    ```go
    type EmailNotifier struct {}
    func (s *EmailNotifier) Notify(msg string, recipient string) error
    ```

### 小结

并非总是如此，但是在大多数情况下，都是在程序中传递接口而不是具体实现，因此当新的需求到来时，你只需实现接口的另一个实例。


## 3. 里氏替换原则 （Liskov Substitution Principle）

抱歉。

### 小结

不好意思。

## 4. 接口隔离 （Interface Segregation Principle）

> 不应强迫客户端依赖于不使用的接口。

### 规则引擎

回到我们的规则引擎，并实现其接口要求我们实现的唯一方法。

```go
func ProcessEvent(message types.NotificationMessage) error
```

规则引擎可以处理许多不同类型的传入消息。我倾向于称它为事件，因为我们正在根据系统中发生的事件来接收消息。

考虑以上描述，我们可以肯定地将一条消息转换为一个事件。为此，我们可以使用“[工厂设计模式](https://en.wikipedia.org/wiki/Factory_method_pattern)”，稍后介绍这个。

继续，创建一个事件接口，

```go
type Event interface {}
```

概括需求，我们必须根据传入系统的事件向用户发送文本消息。

因为事件已经成为我们服务中的一个实体，我们应该在定义该实体边界时，围绕我们刚学习的“单一职责原则”进行思考。

1. 事件应该知道它要发送什么消息，以封装事件的所有细节。
2. 事件不应该知道如何发送消息。

由于要发送消息，就必须告知事件有关通知者的信息。因此，我们将其作为参数提供。

```go
type Event interface {
    Send(n Notifier) error
}
```

最后，这是我们规则引擎的消息提取方法的小而美的实现。

```go
func (e *engine) ProcessMessage(message types.NotificationMessage) {
    event, err := e.eventFactory(message)
    if err != nil {
        return err
    }

    return event.Notify(e.notifier)
}
```

消息到事件的转换就是 EventFactory 的全部内容。

以下是工厂中的一段代码，以供熟悉：

```go
switch messageType {
    case loginSuccessfulEvent:
       return NewLoginEvent()
}
```

### 小结

接口要求如下：

- Notifier
    1. Notifier 接口只想要客户端实现 Notify() 接口。
    1. 除了需要的之外， SMSNotifier 不会实现 Notifier 强迫它实现的任何方法。

- Event
    1. Event 接口只要客户端实现 Send() 接口。
    1. 除了需要的之外， LoginEvent （由工厂返回） 不会实现 Event 强迫它实现的任何方法。

要点： 保持接口尽可能短，最多一种方法就很不错。

## 5. 依赖倒置原则 （Dependency Inversion Principle）

> 高级模块不应该依赖低级模块，两者都应依赖抽象。

我们系统中主要由两个组件（由于消费者除了读取队列中的消息并扔到规则引擎之外，没做多少事情，我们可以忽略它）。

规则引擎相比通知者是更高级的模块。

假如 Notifier 不是接口，但是具体实现是 SMSNotifier。
这种情况下，Engine（高级模块）依赖于 SMSNotifier （低级模块），它在引导时实例化引擎时注入。

```
 +--------+   +-------------+
 | Engine +---> SMSNotifier |
 +--------+   +-------------+
```

在实例化依赖项是将其注入 Engine 中：

```go
fucn NewRuleEngine(config Config, notifier SMSNotifier) *Engine
```

考虑到依赖关系树，以下是此服务的生命周期中可能发生的事件：

- 12:00 AM —— 更改在 SMSNotifier 中完成。
- 12:01 AM —— SMSNotifier 重新编译，因为有更改。
- 12:02 AM —— 因为 SMSNotifier 是 Engine 的直接依赖，它被重新编译。
- 04:20 AM —— 违反依赖倒置原则。

### 引入抽象
通过引入我们的 Notifier 接口，我们可以反转来自 Engine 的 SMSNotifier 的依赖关系。

```
      +----------+
   +--> Notifier +<--+
   |  +----------+   |
   |                 |
+--+-----+   +-------+-----+
| Engine |   | SMSNotifier |
+--------+   +-------------+
```

回看之前的事件：

- 12:00 AM —— 更改在 SMSNotifier 中完成。
- 12:01 AM —— SMSNotifier 重新编译。
- 12:02 AM —— 此时 SMSNotifier 不是 Engine 的直接依赖，它不会被重新编译。
- 12:01 同上 —— 依赖倒置原则完好。

## 总结

1. 基于组件的方法架构适合以 SOLID 原则实施。
1. 组件必须与合约以及配置通信，而不是与具体的实现。
1. 保持合约越小越好，这样生活更轻松。
1. 不要一满意就签入代码。上述解决方案不是初稿。花时间分析你写的内容。
