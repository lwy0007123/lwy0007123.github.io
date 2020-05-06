---
title: MVC 部分刷新的尝试
date: 2017-06-15 23:14:35
tags: 
- JavaScript
- MVC
- Razor
---

<a href="#NewVersion">直接跳到2.0版本</a>

# 版本0.1 - 简单的异步刷新尝试

* ProcessController中加入

<!--more-->

```csharp
[AllowAnonymous] // 这是允许匿名访问的声明，没有用ASP.NET IDENTITY可以删掉
public ActionResult PartialTest()
{
  return View();
}
[AllowAnonymous]
public ActionResult Fetch(int num)
{
  // 取前num条数据
  var model = db.Movies.Take(num).ToList();
  // MovieList是你的Partial页面的名字,model是与该Partial页头部接受的类型一致的model
  return PartialView("MovieList", model);
}
```

* /View/Process/PartialTest.cshtml

```html
<button id="btn" class="btn">加一条</button>

<div id="notificationsTable">
    @{Html.RenderAction("Fetch", new { num = 1 });}
</div>

@* 添加JS到布局页，否则找不到jQuery的$标记 *@
@section scripts{
<script>
    var n = 2;
    $(document).ready(function () {
        $("#btn").click(function () {
            $("#notificationsTable").load('/Process/Fetch?num=' + n);
            n++;
        });
    });
</script>
}
```

* 地址栏运行/Process/PartialTest 即可

# 更新 1.0 - 使用@Ajax.ActionLink

不希望在cshtml代码里用JS?  Razor Helper 还提供了 @Ajax.ActionLink

感谢下面链接里的大佬 

<a href="http://www.c-sharpcorner.com/UploadFile/abhikumarvatsa/ajax-actionlink-and-html-actionlink-in-mvc/" target="_blank">传送门</a>

* 先在VS的程序包管理器控制台输入 (PS.如果有问题就在NuGet搜索安装) 

```powershell
Install-Package Microsoft.jQuery.Unobtrusive.Ajax
```

* 修改/View/Process/PartialTest.cshtml为

```html
@Ajax.ActionLink("一条变两条", "Fetch",new { num = 2 },
   new AjaxOptions
   {
       UpdateTargetId = "notificationsTable",
       InsertionMode = InsertionMode.Replace,
       HttpMethod = "GET"
   },
   new
   {
       @class = "btn btn-default",
       @role = "button"
   }
)

<div id="notificationsTable">
    @{Html.RenderAction("Fetch", new { num = 1 });}
</div>

@section scripts{
    @Scripts.Render("~/Scripts/jquery.unobtrusive-ajax.min.js")
}
```

* 由于用@Ajax.ActionLink生成的按钮是固定的，所以没法像JS那样动态修改请求变量，但是页面的异步刷新效果还是有的

# 更新 1.1 - 解决上面的问题

动态更改ActionLink的routeValues，StackOverflow的回答基本是用JQuery，下面是解决办法：

* 修改/View/Process/PartialTest.cshtml为：

```csharp
@Ajax.ActionLink("加一条", "Fetch",new { num = "xxx" },
   new AjaxOptions
   {
       UpdateTargetId = "notificationsTable",
       InsertionMode = InsertionMode.Replace,
       HttpMethod = "GET"
   },
   new
   {
       @id = "btn",
       @class = "btn btn-default",
       @role = "button"
   }
)
@section scripts{
    <script>
        var n = 2;
        var href = $('#btn').attr('href');
        $(document).ready(function () {
            $("#btn").click(function () {
                this.href = href.replace("xxx", n++);
            });
        });
    </script>
    @Scripts.Render("~/Scripts/jquery.unobtrusive-ajax.min.js")
}
```

* 这里实现了0.1版本一样的功能，是不是有种转了一圈回到原点的感觉？好讽刺啊……

<p id="NewVersion"></p>

# 更新2.0 - Form表单提交实现指定DIV的异步刷新

上面讨论了如何按下按钮时异步刷新页面，那么在表单提交我不想跳转，我也要异步刷新，怎么办呢？下面介绍解决办法。这部分实现一个展示不同分类下的电影列表。从 Model - View - Controller 一步步来实现：

* Model - /Models/Movie

```csharp
public class Movie
{
    public int Id { get; set; }

    [Display(Name = "电影名")]
    public string Name { get; set; }

    public enum Types
    {
        动作, 喜剧, 科幻, 爱情, 纪录, 动画, 恐怖, 悬疑, 青春, 文艺, 励志, 战争, 犯罪
    }
    [Display(Name = "类型")]
    public Types? Type { get; set; }
}
```

* View - /View/Process/PartialTest2.cshtml

```html
@model ZeroMovie.Models.Movie
<form id="tForm">
    <div class="form-horizontal">
        <div class="form-group">
            @Html.LabelFor(model => model.Type, htmlAttributes: new { @class = "control-label col-md-2" })
            <div class="col-md-10">
                @Html.EnumDropDownListFor(model => model.Type, htmlAttributes: new { @class = "form-control" })
            </div>
        </div>
        <div class="form-group">
            <div class="col-md-offset-2 col-md-10">
                <input type="submit" value="提交" id="btn" class="btn btn-default" />
            </div>
        </div>
    </div>
</form>   

<div id="PartialRefreshArea">刷新这里</div>

@section scripts{
    <script>
        $(document).ready(function () {
            $('#tform').on('submit', function (e) {
                e.preventDefault();
                $.ajax({
                    type: 'post', // Form的Method
                    url: '@Url.Action("Fetch","Process")', // Form的Action
                    data: $('#tform').serialize(), // 序列化提交数据
                    success: function (res) {
                        $('#PartialRefreshArea').html(res);
                    }
                });
            });
        });
    </script>
    @Scripts.Render("~/Scripts/jquery.unobtrusive-ajax.min.js")
}
```

* View - /View/Process/MovieList.cshtml


```html
@model IEnumerable<ZeroMovie.Models.Movie>
<table class="table" style="table-layout:fixed">
    <tr>
        <th>
            @Html.DisplayNameFor(model => model.Name)
        </th>
        <th>
            @Html.DisplayNameFor(model => model.Type)
        </th>
    </tr>
@foreach (var item in Model) {
    <tr>
        <td>
            @Html.DisplayFor(modelItem => item.Name)
        </td>
        <td>
            @Html.DisplayFor(modelItem => item.Type)
        </td>
    </tr>
}
</table>
```

* Controller - /Controller/ProcessController.cs


```csharp
public class ProcessController : Controller
{
    // 上下文类有 DbSet<Movie>
    private ApplicationDbContext db = new ApplicationDbContext(); 
    public ActionResult PartialTest2()
    {
        return View();
    }
    public ActionResult Fetch2([Bind(Include = "Type")] Movie movie)
    {
        var model = db.Movies.ToList();
        if(movie.Type != null)
            model = db.Movies.Where(p => p.Type == movie.Type).ToList();
        return PartialView("MovieList", model); // model的类型要与MovieList接受的类型一致
    }
}
```

* 运行后地址栏访问/Process/PartialTest2即可

## 总结：JS大法好

弱弱问一句垃圾代码有人要看吗：

<a href="https://github.com/sko00o/ZeroMovie"  target="_blank">传送门</a>