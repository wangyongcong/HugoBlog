---
title: PCH 问题总结
date: 2021-05-21
tags: [C++, PCH, MSVC]
---

MSVC 下可能遇到的 PCH 错误
-   fatal error [C3859](https://docs.microsoft.com/en-us/cpp/error-messages/compiler-errors-2/compiler-error-c3859): virtual memory range for PCH exceeded; please recompile with a command line option of ‘-ZmXXX’ or greater
-   fatal error [C1076](https://docs.microsoft.com/en-us/cpp/error-messages/compiler-errors-1/fatal-error-c1076): compiler limit: internal heap reached; use /Zm to specify a higher limit
-   fatal error [C1083](https://docs.microsoft.com/en-us/cpp/error-messages/compiler-errors-1/fatal-error-c1083): Cannot open include file: ‘xyzzy’: No such file or directory

MSVC 会开多进程编译，每个 cl 进程都会加载 PCH，如果 PCH 较大且进程很多，就会爆内存或虚存。编译选项 ```/MP``` 用来指定并行 cl 的数量，默认值为机器的核心数量。例如：```/MP32``` 开32个 cl 进程并行编译，如果 PCH 为 250MB，那么可能同时触发 32 次 ```VirtualAlloc()``` ，请求 ```32 * 250 MB = 8000 MB``` 的内存请求，把虚存爆掉（fatal error C3857）。

所以，根本的解决方法是：
1. 设置 Windows 的虚拟存储，把初始值和最大值都设置为 ```max PCH size * max CL count```
2. 或者，减少并行的 cl 的数量
3. 或者，减少 PCH size

[修改 Windows 虚存大小](/blog/AdjustVirtualMemorySettings.png)

VS2015 或之前的版本，PCH 只能在连续的虚存，通过 ```/Zm``` 选项来控制虚存上限。在之后的 VS 版本，PCH 破除了这个限制，可以分布在不同的虚存区间，所以这个选项只用于具有 ```#pragma hdrstop``` 标记的 PCH。