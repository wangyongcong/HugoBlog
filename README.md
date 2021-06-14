# Hugo Blog Content

保存 Hugo 日志的内容，通过 Hugo 生成静态页面，发布于 github.io

## 发布步骤 

1. 指令 ```hugo new blog/xxx.md``` 生成新的文档，或将 ```.md``` 文档放到 ```content``` 目录
2. 执行 ```hugo server -D``` 进行测试，测试地址为 ```http://localhost:1313/```
3. 执行 ```hugo -d destination``` 生成静态页面，输出到 ```destination``` 目录
4. 提交 ```destination``` 目录到 ```github.io``` 仓库

## 配置

1. 基础配置保存在 `config.toml` 
   - `baseURL` 要填域名，末尾**要**带上反斜杠 `/`
   - ```[[params.best_posts]]``` 用来将文章指定，有两个属性 ```title``` 和 ```url```。这个字段可以有多个，文章按顺序出现在置顶区。
2. `static` 目录的内容会直接被复制到根目录，里面要放以下的文件：
   - CNAME 域名
   - favicon.ico 网站图标

## 主题

目前使用的是 [alageek theme](https://github.com/gkmngrgn/hugo-alageek-theme) ，需要改以下几个地方：

1. 改为暗黑主题，而不是跟随系统设置。在 ```themes\alageek\static\css\main.css``` 直接将 root 改为暗黑配色，移除 ```@media (prefers-color-scheme, dark)``` 的代码。

2. 语法高亮也要改为暗黑主题。修改 ```themes\alageek\static\css\highlight.css```，只引用需要的主题

   ```js
   @import "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.0.1/build/styles/github-dark-dimmed.min.css";
   ```

## 内容

1. `_index.md` 是特殊的，作为主页
2. 资源引用是基于根路径的，例如：```/img/hello.png``` 在发布的时候会简单地将 ```/``` 替换为 ```baseURL```
3. 文章和资源也可以放在子目录下，例如：```/about/``` 既可以是 ```/about.md``` ，也可以是 ```/about/index.md```

## Mermaid

要提供 Mermaid 支持，添加 `layouts/shortcodes/mermaid.html` ，然后在所用的主题的 `layouts/partials/header.html` 中导入 Mermaid js

```js
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
<script>mermaid.initialize({ startOnLoad: true, securityLevel: 'loose', theme: 'dark'});</script>
```

 
