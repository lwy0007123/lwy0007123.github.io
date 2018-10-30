---
title: Solve ridiculous problem in Golang
date: 2018-10-30 19:00:20
tags:
- Go
- Linux
---

# problem

```sh
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x10 pc=0x6e2bea]

goroutine 10233 [running]:
.../backend.(*ActionBackend).ReceiveTXPacket(0xc42968f940)
        /.../backend/actionbackend.go:102 +0x2a
.../backend.NewActionBackend.func1(0xc42968f940)
        /.../backend/actionbackend.go:45 +0x2b
created by .../backend.NewActionBackend
        /.../backend/actionbackend.go:44 +0x89
```

<!--more-->

# solve

```sh
ulimit -n 65536
```

# why

First, I try to find some logic problem in panic lines. But nothing should be modified.

Then I reconigized my program need to create 3000 connection. (It's a stress test program.)

While I type this `ulimit -n`, it shows the file-size writing limit is `1024`. So ... boooom!