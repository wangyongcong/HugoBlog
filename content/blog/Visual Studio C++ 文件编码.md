---
title: Visual Studio C++ 文件编码
date: 2020-09-13
tags: [C++, MSVC]
description: Visual Studio C++ 文件编码相关设置和编译选项
---

编译器处理源文件字符编码时，分为 *source charset* 和 *execution charset*
1. source charset: 源文件的字符编码
2. execution charset：代码中的字符串以何种编码写到 binary

Microsoft C/C++ 编译器按以下的方式处理：
1. 所有源文件，内部会先转换为 UTF-8 再进行编译
2. 如果有 BOM，则根据 BOM 来决定如何进行转换
3. 如果无 BOM，则根据前8个字符来判断是否为 UTF-16 及 endian
4. 如果无 BOM，也不是 UTF-16，则当作本地编码处理
5. 编译时，会根据 *execution charset* 的设置，将代码中的字符串从 UTF-8 转换到目标编码

VS2015 Update 2 之后新添加了两个编译选项：

- ```/source-charset:<iana-name>|.NNNN``` 
- ```/execution-charset:<iana-name>|.NNNN```

分别用来指定 *source charset* 和 *execution charset*

此外还有个简化的指令 ```/utf-8``` 等介于同时使用 ```/source-charset:utf-8``` 和 ```/execution-charset:utf-8```

综上，对于带中文注释的源码，最佳解决方案是：
1. 全部源文件使用 UTF-8 编码
2. 编译指令加上 ```/utf-8``
3. 并开启 ```/validate-charset``` 确保源码没有包含非法字符。当使用了上述 charset 选项之后，默认会开启这个检查，除非被显示关闭 ```/validate-charset-```

---
参考资料：
1. [New Options for Managing Character Sets in the Microsoft C/C++ Compiler](https://devblogs.microsoft.com/cppblog/new-options-for-managing-character-sets-in-the-microsoft-cc-compiler/)

---
