---
title: Rust 学习笔记 1
date: 2020-03-30 23:39:36
tags:
- rust
---

阅读 [《 Rust 程序设计》](https://doc.rust-lang.org/book)的一些笔记。

从一个猜数字游戏了解语言特性。

<!--more-->

> 参考[原文](https://doc.rust-lang.org/book/ch02-00-guessing-game-tutorial.html)

## 保存值到变量

Rust 中，变量默认是不可变的（immutable）。

`String::new` 函数返回的 `String.String` 是标准库提供的字符串类型，它是可增长的（grawable），UTF-8 编码的文本。

`::new` 中的 `::` 语法表明 `new` 是 `String` 类型的关联函数（associated function），关联函数都是再类型上实现的，而不是再某一类型的特定实例上实现。

`&` 表明这个参数是一个引用（reference），即直接访问某块内存中的数据而不需要拷贝。引用是一项复杂的功能， Rust 的主要优势之一是使用引用的安全性和便捷性（第 4 章会有详细介绍）。而目前需要知道的是，像变量一样，引用也默认是不可变的，因此 `read_line()` 函数中需要传递 `&mut guess` 参数，而不是 `&guess` 。

## 使用结果（Result）类型处理潜在的故障

`read_line` 接收用户输入，返回一个值，本例中它是 `io::Result`， Rust 在其标准库中有大量名为 `Result` 的类型：通用 `Result` 和特定版本的子模块，例如 `io::Result` 。

`Result` 类型是枚举类型（enumerations），通常被成为 `enums`，枚举类型是一种有固定值集合的类型，这些值成为枚举变量，第 6 章会详细介绍枚举类型。

`Result` 类型的目的是对错误处理（error-handling）信息进行编码。`io::Result` 的实例拥有 `expect` 方法。如果 `io::Result` 实例是一个 `Err` 值， `expect` 将导致程序崩溃，并显示你传递给 `expect` 的参数。如果 `read_line` 方法返回一个 `Err` ，可能是来自底层操作系统的错误导致的。如果 `io::Result` 实例是 `Ok` 值，`expect` 将获得 `Ok` 持有的返回值，并只将该值返回给你，以便你使用它。这种情况下，该值是用户输入到标准输入的字节数。

如果你不调用 `expect` ，程序可以通过编译，但是你会获得警告：

```sh
warning: unused `std::result::Result` that must be used
 --> src/main.rs:8:5
  |
8 | /     io::stdin()
9 | |         .read_line(&mut guess);
  | |_______________________________^
  |
  = note: `#[warn(unused_must_use)]` on by default
  = note: this `Result` may be an `Err` variant, which should be handled
```

抑制警告的正确做法是编写实际的错误处理，但是你仅仅希望问题发生时程序崩溃，你可以使用 `expect` 。第 9 章可以学到如何从错误中恢复。

## 使用 `println!` 占位符

闭合的大括号 `{}` 就是一个占位符：`{}` 像螃蟹的小钳子抓住一个值。

## 产生秘密数字

我们使用 1 至 100 之间的随机数，虽然 Rust 当前的标准库中没有随机数函数，但是 Rust 团队提供了 `rand` 板条箱（crate）。

## 使用板条箱获得更多功能

一个 crate 是 Rust 源码文件的集合。我们正在构建的项目是一个可执行的二进制板条箱（binary crate）。`rand` 是一个库板条箱（library crate）包含可以被其他程序使用的代码。

在 `Cargo.toml` 文件中，依赖项部分添加一行：

```toml
[dependencies]
rand = "0.5.5"
```

我们指定 `rand` 板条箱的语义版本说明符（semantic version specifier）为 `0.5.5` ， Cargo 理解语义版本（有时称为 `SemVer`），这是一种书写版本号的标准。`0.5.5` 是 `^0.5.5` 的简写，它表示“具有兼容 0.5.5 版本公共 API 的任意版本”。

执行 `cargo build` 获取依赖。

## 使用 Cargo.lock 文件确保可复制的构建

Cargo 具有一种机制，可以确保你或其他任何人每次构建代码时都可以重建相同的工件：除非另有说明，否则 Cargo 将仅使用你指定的依赖项版本。

## 更新 Crate 获取新版本

`update` 命令将忽略 Cargo.lock 文件并找到所有最新版本依赖，并写入 Cargo.lock 文件。

默认情况下，Cargo 将仅查找介于 `0.5.5` 和 `0.6.0` 的版本。

通过修改 Cargo.toml 来指定 rand 0.6.x 版本，再次执行 `cargo build`， Cargo 将更新可用的注册表，并根据你指定的新版本重新评估你的 `rand` 需求。

## 产生随机数

首先添加 `use` 行： `use rand::Rng` 。 `Rng` 特征（trait）定义了产生随机数的实现方法，并且该特性必须要在我们可以使用这些方法的范围内。第 10 章详细介绍 trait 。

接着添加两行， `rand::thread_rng` 函数将为我们提供将要使用的特定随机数生成器：它有当前线程执行并且操作系统提供随机种子。

## 查看使用说明文档

你不可能一开始就知道要使用哪些 traits 或者要调用哪些函数，crate 的使用说明在其文档中，使用 `cargo doc --open` 可以构建所有本地依赖的文档。

使用说明文档生成在 `./target/doc/guessing_game/index.html` 目录中，我们起一个简单的 web 服务方便查看文档（需要 python3 支持，你也可以直接打开目标文件）。

```sh
python3 -m http.server -d ./target/doc/
```

浏览器打开 http://localhost:8000/guessing_game 。

## 比较 Guess 和 Secret Number

我们用到了 match 表达式，一个 `match` 表达式由手臂（arms）构成，手臂由模式（pattern）和执行代码构成，如果 `match` 表达式开头的值符合该模式，就会执行这段代码。`match` 结构和模式是 Rust 中的强大功能，可以当你表达代码可能遇到的各种情况，并确保对所有情况进行处理。这些功能分别在第 6 章和第 18 章中详细介绍。

Rust 具有强大的静态类型系统。然而，它也有类型推断（type inference）。当我们写下 `let mut guesss = String::new()` ， Rust 就能够推断出 `guess` 应该是 `String` 类型。

由于 `guess` 和 `secret_number` 类型不匹配，cmp 方法调用失败，则我们需要类型转换。我们再创建一个变量 `guess` ，虽然它和之前的变量重名，但是 Rust 允许我们用一个新的值来掩盖（shadow）以前的 `guess` 值，次功能通常用于值类型转换的情况。掩盖使我们可以重用变量名称，而不是强迫我们创建两个唯一变量，例如 `guess_str` 和 `guess` 。（第 3 章详细描述 shadowing ）

`trim` 方法用于消除（eliminates）按下回车键时被读取到的 `\n` 字符。

`parse` 方法作用于字符串可以将字符串解析为数字。但是这个方法可以解析出多种类型，我们要明确指定 `guess` 的类型：`let guess: u32` 。

例程中的 `u32` 注解，影响到与 `secret_number` 比较时，将其也推断成 `u32` 类型。
