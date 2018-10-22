---
title: 如何在Windows上使用GLUT
date: 2018-03-09 17:05:59
categories: 图形学
tags: 
- Windows
- GLUT
---

# 如何在Windows上使用GLUT

最近在看计算机图形学
书里的代码要用到OpenGL，然而在Windows上少了GLUT，需要自己手动配置。

<!--more-->

## 准备

* Microsoft Visual Studio 2017 Community （勾选安装`使用C++的桌面开发`那项，确保安装MSVC）
* [GLUT for Windows](https://www.opengl.org/resources/libraries/glut/glut37.zip)

## 配置

1. 打开 glut37.zip。
1. `glut.dll`,`glut32.dll` 解压到 Windows目录。
    > 我放到了`C:\Windows`目录下，当然你也可以把它们分别放到`C:\Windows\SysWOW64`和`C:\Windows\System32`下。
1. 找到MSVC的目录。
    > 例如 `C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.??.??????`。 (根据版本文件夹的名称的`?`会有不同)
1. 在`include`目录下新建`GL`文件夹，将`glut.h`复制进去。
    > 例如 `C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.13.26128\include\GL`。
1. 在`lib`目录下，将`glut.lib`,`glut32.lib`复制进去。

## 编写一个简单的opengl程序

1. 打开VS2017，依次点击 `新建` - `项目` - `Visual C++` - `Windows 控制台应用程序` - `确定`。

1. 右键点击解决方案管理器中的项目名称(ConsoleApplication?) - 属性 - 链接器
    > 注意：配置平台是Win32。
    * 常规 - 附加库目录 - <编辑…> - 粘贴你lib的路径
        > 例如 `C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.13.26128\lib`。
    * 输入 - 附加依赖项 - <编辑…> - 粘贴glut的lib
        > 例如 `glut32.lib`。

1. `ConsoleApplication1?.cpp`中写入以下代码：

    ```cxx
    #include "stdafx.h"
    #include <gl/glut.h>

    void init(void)
    {
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glMatrixMode(GL_PROJECTION);
        gluOrtho2D(0.0, 200.0, 0.0, 250.0);
    }

    void lineSegment(void)
    {
        glClear(GL_COLOR_BUFFER_BIT);

        glColor3f(0.0, 0.4, 0.2);
        glBegin(GL_LINES);
        glVertex2i(180, 15);
        glVertex2i(10, 145);
        glEnd();
        glFlush();
    }

    int main(int argc, char** argv)
    {
        glutInit(&argc, argv);
        glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
        glutInitWindowPosition(50, 100);
        glutInitWindowSize(400, 300);
        glutCreateWindow("An Example OpenGL Program");

        init();
        glutDisplayFunc(lineSegment);
        glutMainLoop();

        return 0;
    }
    ```

1. F5调试，你可以看到图像是一条斜线。

## 参考

* [https://www.cs.csustan.edu/~rsc/SDSU/GLUTinstall.html](https://www.cs.csustan.edu/~rsc/SDSU/GLUTinstall.html)

* [http://blog.csdn.net/qq_19982213/article/details/69970977](http://blog.csdn.net/qq_19982213/article/details/69970977)
