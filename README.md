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
3. 文章和资源也可以放在子目录下，例如：创建一个 ```about``` 子目录，内容文档为 ```/about/index.md```，资源也放在子目录下 ```/about/image.png```，只需通过名字就可以引用资源 ```![alt](image.png)``` 。这种组织方式称为 ```page bundle```。

## Mermaid

要提供 Mermaid 支持，添加 `layouts/shortcodes/mermaid.html` ，然后在所用的主题的 `layouts/partials/header.html` 中导入 Mermaid js
```js
{{ if .Params.mermaid }}
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
<script>mermaid.initialize({ startOnLoad: true, securityLevel: 'loose', theme: 'dark'});</script>
{{end}}
```

先在 front matter 中打开当前页面的 Mermaid 支持
``` yaml
mermaid: true
```

通过 shortcode 嵌入 Mermaid 图表
```markdown
{{<mermaid align="left">}}
add mermaid graph here
{{</mermaid>}}
```

## 图像
通过使用 [lightbox2](https://github.com/lokesh/lightbox2/releases) 来增强图像显示，支持图像列表，点击缩放，按钮导航等功能。

将 `lightbox.min.js`, `lightbox.min.css` 分别放到 `static/js`, `static/ccss` 目录下，然后在 `layouts/partials/header.html` 中添加代码
```js
{{ if .Params.gallery }}
<script src="https://code.jquery.com/jquery-1.12.4.min.js" integrity="sha256-ZosEbRLbNQzLpnKIkEdrPv7lOy9C27hHQ+Xp8a4MxAQ=" crossorigin="anonymous"></script>
<script src="/js/lightbox.min.js"></script>
<link href="/css/lightbox.min.css" rel="stylesheet"></link>
<script>
  <!-- lightbox2 选项 -->
  lightbox.option({
    'fadeDuration': 100,
    'wrapAround': true
  })
</script>
{{ end }}
```

添加 `layouts/_default/_markup/render-image.html` 文件，用来 hook markdown image 的渲染。所有文档中的图像链接：
```markdown
![alt text](image.png "Title")
```
都会用 `render-image.html` 中的代码替换成 html。

最后，在 front matter 中打开当前页面的 lightbox2 支持：
``` yaml
gallery: true
```

要注意的是，图像要以 ```page bundle``` 的形式来组织，即放在页面子目录下面。
