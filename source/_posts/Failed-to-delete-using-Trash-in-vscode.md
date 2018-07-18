---
title: Failed to delete using Trash in vscode
date: 2018-06-18 09:31:23
categories: Linux
tags:
- vscode
- Linux
---

## Environment

Gnome version 3.28.2
VScode version: 1.24.1

## Problem

When I want to delete file from explorer in vscode, following Error occurs:

`Failed to delete using the Trash. Do you want to permanently delete instead?`

## Fix Method

Maybe `gvfs-trash` not work properly. It has been deprecated in this gnome version.
So open shell, install another tool for help.

```sh
## need python installed
sudo easy_install trash-cli
```

## Reference

[Failed to delete using Trash in Ubuntu 18.04 (#49675)](https://github.com/Microsoft/vscode/issues/49675)
[Moving files to trash always fails in Kubuntu 16.04 (#22820)](https://github.com/Microsoft/vscode/issues/22820#issuecomment-288239512)
