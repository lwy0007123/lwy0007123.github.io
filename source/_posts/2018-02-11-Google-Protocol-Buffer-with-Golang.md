---
title: 初次了解 Google Protocol Buffer
date: 2018-02-11 18:57:00
tags: 
- Go
- Protocol Buffer
---

Protocol Buffer 是一种语言无关、平台无关的可扩展机制，用于序列化结构话数据。

<!--more-->

## 下载二进制文件

[https://github.com/google/protobuf/releases](https://github.com/google/protobuf/releases)

## 配置环境

### GOPATH

命令行输入:

```sh
go dev
```

或者在系统环境变量里添加一条GOPATH指向你的自定义目录。

最后将`$GOPATH`添加到系统环境变量path中。

### 可执行文件加入$GOPATH

以Windows为例，将下载的压缩包的bin目录下的`protoc.exe`复制到你的任意path路径下，我放到`$GOPATH/bin`目录下。

### 添加Go语言支持

命令行执行以下命令：

```sh
go get -u github.com/golang/protobuf/protoc-gen-go
```

## 代码生成

先编写一个`addressbook.proto`文件

```sh
syntax = "proto3";
package tutorial;
message Person {
  string name = 1;
  int32 id = 2;  // Unique ID number for this person.
  string email = 3;

  enum PhoneType {
    MOBILE = 0;
    HOME = 1;
    WORK = 2;
  }

  message PhoneNumber {
    string number = 1;
    PhoneType type = 2;
  }

  repeated PhoneNumber phones = 4;
}

// Our address book file is just one of these.
message AddressBook {
  repeated Person people = 1;
}
```

命令行输入以下生成命令：

```sh
protoc --go_out=./ ./addressbook.proto
# 命令格式 protoc -I=$SRC_DIR --go_out=$DST_DIR $SRC_DIR/addressbook.proto
```

在当前目录下生成`addressbook.pb.go`文件

## 参考

- [官网](https://developers.google.com/protocol-buffers)
