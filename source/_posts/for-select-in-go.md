---
title: For-Select loop in Go
date: 2019-03-14 09:36:50
tags: Go
---

# For-Select loop in Go

Simple `break` in for-select loop, will not break out of `for` loop. You should use `break label`.

## demo

```go
package main

import (
    "fmt"
    "time"
)

func main() {

    one := time.After(time.Second * 2)
    two := time.After(time.Second * 4)
    three := time.After(time.Second * 6)

out:
    //fmt.Println("out of for") // anything here will invoke error
    for {
        fmt.Println("head")
        select {
        case <-one:
            fmt.Println("one")
            continue

        case <-two:
            fmt.Println("two")
            break

        case <-three:
            fmt.Println("three")
            break out

        }
        fmt.Println("tail")
    }
    //out: // break label must define before for loop
    fmt.Println("in the end")
}
```

[Playground](https://play.golang.org/p/vz_uQb4nhPz)

## more

[Break statement](https://golang.org/ref/spec#Break_statements)