---
title: Rime默认简体中文配置
date: 2018-06-09 15:09:28
categories: Linux
tags:
- Rime
- linux
---

[Rime](https://rime.im/)这个输入法是很强大。

但是我对输入法的要求不高: 能输入中文；界面简洁；词汇联想别太"睿智"。

恰好这些需求Rime都很轻松的满足了，但是唯一不爽的是每次切换到Rime都默认输入繁中，再F4切换简中就很不方便。

虽然这是作者的喜好，但是我不习惯，还好文档提供了默认使用简中的配置方案。

解决方案：`vim ~/.config/ibus/rime/luna_pinyin.custom.yaml`

> 这是linux中的用户配置位置，其他系统查看[这里](https://github.com/rime/home/wiki/RimeWithSchemata#rime-%E4%B8%AD%E7%9A%84%E6%95%B8%E6%93%9A%E6%96%87%E4%BB%B6%E5%88%86%E4%BD%88%E5%8F%8A%E4%BD%9C%E7%94%A8)

```yaml
# luna_pinyin.custom.yaml

patch:
  switches:                   # 注意缩进
    - name: ascii_mode
      reset: 0                # reset 0 的作用是当从其他输入法切换到本输入法重设为指定状态
      states: [ 中文, 西文 ]   # 选择输入方案后通常需要立即输入中文，故重设 ascii_mode = 0
    - name: full_shape
      states: [ 半角, 全角 ]   # 而全／半角则可沿用之前方案的用法。
    - name: simplification
      reset: 1                # 增加这一行：默认启用「繁→簡」转换。
      states: [ 漢字, 汉字 ]
```

参考 [Rime 定制指南](https://github.com/rime/home/wiki/CustomizationG)