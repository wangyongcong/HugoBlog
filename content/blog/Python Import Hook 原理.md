---
title: Python Import Hook 原理
date: 2021-06-14
tags: [python]
---
Python import 过程中，可以通过添加钩子，修改文件查找和加载的方式。游戏开发中，通常需要将脚本文件打包和加密，这时就要用到 Python import hook 机制。下面分别阐述 Python3 和 Python2 的 import hook 工作流程。

## Python3
官方文档 [Python3 The Import System](https://docs.python.org/3/reference/import.html) 提供了最详细的说明。

### 模块查找
工作流程跟 Python2 不同，废除了 ```find_module``` 和 ```load_module```，代之为 ```find_spec```，```create_module``` 和 ```exec_module```。模块查找过程为：
1. 先从 ```sys.modules``` 里面找
2. 其次通过 *meta hooks* 机制来加载模块，这是注册到 ```sys.meta_path``` 列表的对象，它拥有最高优先级，设置可以通过它替换 built-in module
3. 然后从 ```sys.path``` 路径列表找模块，其中每个 path 会经由 *import path hooks* 来处理，这是注册到 ```sys.path_hooks``` 列表的对象，用以修改查找路径

### Meta Hook 工作流程
分为2个部分：*Finder* 和 *Loader*
1. 调用 *Finder.find_spec* 获得 *Spec* 对象，其中 *Spec.loader* 为自定义的 *Loader* 对象
2. 调用 *Loader.create_module* 创建模块
3. 将新创建的模块加入 ```sys.modules``` 避免无限递归 import
4. 调用 *Loader.exec_module* 执行模块代码，任何异常都会从 ```sys.modules``` 移除该模块，import 失败

> ```importlib.machinery``` 可以找到 import 机制相关对象的声明

下面为基础的 *Finder* 和 *Loader* 实现，摘抄自 [How to implement an import hook that can modify the source code on the fly using importlib?](https://stackoverflow.com/questions/43571737/how-to-implement-an-import-hook-that-can-modify-the-source-code-on-the-fly-using#)
```python
import sys
import os.path

from importlib.abc import Loader, MetaPathFinder
from importlib.util import spec_from_file_location

class MyMetaFinder(MetaPathFinder):
	"""
	Finder 对象，必须实现接口 find_spec
	"""

    def find_spec(self, fullname, path, target=None):
		"""
		Finder 对象必须实现 find_spec 接口
		- fullname: 模块的全名，如果是子模块的话，包含完整的路径，e.g "a.b.c"
		- path:  对应 module.__path__，子模块路径列表，如果是顶层模块，则为 None
		- target: a module object that the finder may use to make a more educated guess about what spec to return

		"""
        if path is None or path == "":
            path = [os.getcwd()] # top level import -- 
        if "." in fullname:
            *parents, name = fullname.split(".")
        else:
            name = fullname
		
		# 遍历 path 列表，判断要加载的模块是否还有子模块
        for entry in path:
            if os.path.isdir(os.path.join(entry, name)):
                # this module has child modules
                filename = os.path.join(entry, name, "__init__.py")
                submodule_locations = [os.path.join(entry, name)]
            else:
                filename = os.path.join(entry, name + ".py")
                submodule_locations = None
            if not os.path.exists(filename):
                continue

            # 创建并返回 spec 对象
			return spec_from_file_location(fullname, filename, loader=MyLoader(filename),
                submodule_search_locations=submodule_locations)

        return None # we don't know how to import this

class MyLoader(Loader):
	"""
	Loader 对象，要实现两个接口 create_module 和 exec_module
	"""
    def __init__(self, filename):
        self.filename = filename

    def create_module(self, spec):
		"""
		用来创建 module 对象，返回 None 的话会使用默认的对象创建
		也可以通过 types.ModuleType("ModuleName", "module docs") 来创建并进行额外的初始化
		"""
        return None # use default module creation semantics

    def exec_module(self, module):
		"""
		模块创建成功之后，会调用这个接口来执行模块代码。抛 ImportError 表示执行失败
		"""
        with open(self.filename) as f:
            data = f.read()

        # manipulate data some way...

        exec(data, vars(module))

def install():
    """Inserts the finder into the import machinery"""
    sys.meta_path.insert(0, MyMetaFinder())
```

## Python2
官方文档 [Python2.7 import hook 文档](https://www.python.org/dev/peps/pep-0302/) 提供了最详细的说明。

python在查找模块时，有三个层次, 先后为：
1. cache, 即 sys.modules
2. import hook
3. 常规的导入

新导入的模块的都会放到 ```sys.modules``` 中。
hook执行导入模块涉及两个类：
1. finder: 必须拥有方法```finder.find_module(fullname, path=None)```, 作用是查找模块，返回一个loader
2. loader: 必须拥有方法```loader.load_module(fullname)```, 作用是加载模块

其中，import hook又有两个层次：
1. **sys.meta_path**, 这是一个列表，每个元素都是一个finder实例。 导入模块时，遍历finder列表，调用 ```finder.find_module```, 直到有一个finder返回一个loader, 然后调用loader的 ```load_module``` 方法，加载模块。 否则进入下一层。
2. **sys.path_hooks**, 同样也是一个finder类(不是finder实例)的列表，```sys.path``` 中的每一个路径会按顺序输入 ```sys.path_hooks``` 中的每个Finder的init函数, 直到某个finder没有抛出ImportError，则该模块的导入会交给这个finder执行。同样finder会返回loader, 去执行加载。

一旦finder被选中，不管模块能否加载成功，模块导入的流程都不会进入下一层。
```sys.path_hooks``` 中的 hookers，只有在导入顶层模块时才调用, 比如：```import test``` 会使用 ```path_hooks```, ```import test.world``` 就不会。 ```sys.meta_path``` 就没有这个限制。

## 参考资料
1. [Python3 The Import System](https://docs.python.org/3/reference/import.html) 
2. [Python2.7 import hook 文档](https://www.python.org/dev/peps/pep-0302/)
3. [How to implement an import hook that can modify the source code on the fly using importlib?](https://stackoverflow.com/questions/43571737/how-to-implement-an-import-hook-that-can-modify-the-source-code-on-the-fly-using#)