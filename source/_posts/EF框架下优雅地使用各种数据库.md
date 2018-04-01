---
title: EF框架下优雅地使用各种数据库
date: 2017-06-04 14:22:39
tags: 
- Databases
- EntityFramework
- MySQL
- Oracle
- SQL Server
- Visual Studio
typora-root-url: EF框架下优雅地使用各种数据库
---

### Content

- [LocalDB](#localdb)
- [SQL Server](#sql-server)
- [MySQL](#mysql)
- [Oralce](#oracle)

### 准备工作

_环境： Visual Studio Community 2017，Windows 10.0.15063 pro_

* 先新建一个ASP.NET MVC项目DbConnectPrac

![00](/00.png)

![0](/0.png)

* 程序包管理器控制台安装EF框架

```powershell
Install-Package EntityFramework
```

  _PS. 如果解决方里有多个项目，默认项目注意选择DbConnectPrac_

* Models中新建一个类

  ![1](1.png)

  _Program.cs_

```c#
using System.ComponentModel.DataAnnotations;
namespace DbConnectPrac.Models
{
    public class User
    {
        [Key]
        public int Uid { get; set; }
        [Required]
        [StringLength(16, MinimumLength = 3)]
        public string NickName { get; set; }
        [Required]
        [StringLength(16, MinimumLength = 6)]
        public string Password { get; set; }
        [Required]
        [RegularExpression(@"^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$")]
        public string Email { get; set; }
        public int Privilege { get; set; }
    }
    public class Video
    {
        [Key]
        public int Vid { get; set; }
        [Required]
        [StringLength(30)]
        public string Vname { get; set; }
        [Required]
        public string Vurl { get; set; }
        [Required]
        public string Thumbnail { get; set; }
        public int ViewedNum { get; set; }
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        [Required]
        public string UploadTime { get; set; }
        [Required]
        public string Vtype { get; set; }
        public int Uid { get; set; }
        [StringLength(200)]
        public string Vinfo { get; set; }
    }
    public class Comment
    {
        [Key]
        public int Cid { get; set; }
        [Required]
        public int Uid { get; set; }
        [Required]
        public int Vid { get; set; }
        [Required]
        public string Content { get; set; }
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        [Required]
        public string CommentTime { get; set; }
    }
    public class History
    {
        [Key]
        public int Hid { get; set; }
        [Required]
        public int Uid { get; set; }
        [Required]
        public int Vid { get; set; }
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        [Required]
        public string HistoryTime { get; set; }
    }
}
```


* 生成解决方案

快捷键 Ctrl+Shift+b

* Controllers中新建控制器

![2](2.png)

![3](3.png)

点击添加，将生成以下文件

![5](5.png)

_分别把另外几个类也创建好带视图的控制器_

### LocalDB

_LocalDB是VS自带的简化版SQL Server_

* 查看项目根目录的Web.config，发现已添加了LocalDB的相关内容

```xml
<connectionStrings>
    <add name="DbConnectPracContext" connectionString="Data Source=(localdb)\MSSQLLocalDB; Initial Catalog=DbConnectPracContext-20170603111224; Integrated Security=True; MultipleActiveResultSets=True; AttachDbFilename=|DataDirectory|DbConnectPracContext-20170603111224.mdf" providerName="System.Data.SqlClient" />
</connectionStrings>
<entityFramework>
    <defaultConnectionFactory type="System.Data.Entity.Infrastructure.LocalDbConnectionFactory, EntityFramework">
      <parameters>
        <parameter value="mssqllocaldb" />
      </parameters>
    </defaultConnectionFactory>
    <providers>
      <provider invariantName="System.Data.SqlClient" type="System.Data.Entity.SqlServer.SqlProviderServices, EntityFramework.SqlServer" />
    </providers>
</entityFramework>
```

* 运行项目进入对应的Controller你可以方便的实现增删改查(CRUD)操作。

![6](6.png)

### SQL Server

_版本 2016 Developer edition_

* 在根目录的Web.config中添加SQL Server的连接字段

```xml
<connectionStrings>
<!-- 按实际情况更改 Data Source, User ID, Password -->
<add name="MSSQLConnectContext" 
     connectionString="Data Source=localhost; Initial Catalog=TESTDB; Persist Security Info=True; User ID=sa; Password=123" 
     providerName="System.Data.SqlClient"/>
</connectionStrings>
```

* 打开Models/DbConnectPracContext.cs

```c#
public class DbConnectPracContext : DbContext
{
  // 修改指定使用的数据库连接
  //public DbConnectPracContext() : base("name=DbConnectPracContext"){} // LocalDB
  public DbConnectPracContext() : base("name=MSSQLConnectContext") {} // SQL Server
  // .....省略......
}
```

* 程序包管理器控制台输入

```powershell
Enable-Migrations -EnableAutomaticMigrations
```
* 运行项目进入对应的Controller你可以方便的实现增删改查(CRUD)操作。

### MySQL

_版本 5.7.18_

* 程序包管理器控制台安装EF框架

```shell
Install-Package MySql.Data.Entity
```

* 查看项目根目录的Web.config

  _更新了以下有关MySQL的内容_

```xml
<entityFramework>
    <providers>
      <provider invariantName="MySql.Data.MySqlClient" type="MySql.Data.MySqlClient.MySqlProviderServices, MySql.Data.Entity.EF6, Version=6.9.9.0, Culture=neutral, PublicKeyToken=c5687fc88969c44d"></provider>
    </providers>
</entityFramework>
<system.data>
  <DbProviderFactories>
    <remove invariant="MySql.Data.MySqlClient" />
    <add name="MySQL Data Provider" invariant="MySql.Data.MySqlClient" description=".Net Framework Data Provider for MySQL" type="MySql.Data.MySqlClient.MySqlClientFactory, MySql.Data, Version=6.9.9.0, Culture=neutral, PublicKeyToken=c5687fc88969c44d" />
  </DbProviderFactories>
</system.data>
```

* connectionStrings中添加MySQL的连接字段

```xml
<connectionStrings>
    <add name="MySQLConnectContext" 
         connectionString="server=localhost; port=3306; database=TESTDB; uid=root; password=123"
         providerName="MySql.Data.MySqlClient"/>
</connectionStrings>
```

* 打开Models/DbConnectPracContext.cs完成两处修改

```c#
// 在Context指定mySql的配置文件
[DbConfigurationType(typeof(MySql.Data.Entity.MySqlEFConfiguration))]
public class DbConnectPracContext : DbContext
{
  // 修改指定使用的数据库连接
  //public DbConnectPracContext() : base("name=DbConnectPracContext"){} // LocalDB
  public DbConnectPracContext() : base("name=MySQLConnectContext"){} // MySQL
  // .....省略......
}
```

* 程序包管理器控制台输入

```powershell
Enable-Migrations -EnableAutomaticMigrations
```

* 运行项目进入对应的Controller你可以方便的实现增删改查(CRUD)操作。


  _连接MySQL查看生成的testdb表_

![7](7.png)

### Oracle

_版本 12.2.0.1.0_

* 建议先创建一个新用户，否则使用默认用户可能有意想不到的问题

```sql
-- 用SQLPLUS登录后，连接管理员 (system_password 是你的管理员密码)
CONNECT system/system_password@ORCL
-- 该版本Oracle上创建新用户名必须C##或c##开头，否则不合法
CREATE USER C##TESTUSER IDENTIFIED BY 123;
-- 创建测试用户并授权，要给DBA权限
GRANT CONNECT, RESOURCE, DBA, CREATE VIEW TO  C##TESTUSER ;
```

* 程序包管理器控制台安装EF框架

```shell
Install-Package Oracle.ManagedDataAccess.EntityFramework
```
* 查看根目录的Web.config

  _更新了以下有关Oracle的内容_

```xml
<configSections>
    <section name="oracle.manageddataaccess.client" type="OracleInternal.Common.ODPMSectionHandler, Oracle.ManagedDataAccess, Version=4.122.1.0, Culture=neutral, PublicKeyToken=89b483f429c47342" />
</configSections>
<connectionStrings>
    <add name="OracleDbContext" providerName="Oracle.ManagedDataAccess.Client" connectionString="User Id=oracle_user;Password=oracle_user_password;Data Source=oracle" />
</connectionStrings>
<entityFramework>
    <providers>
      <provider invariantName="Oracle.ManagedDataAccess.Client" type="Oracle.ManagedDataAccess.EntityFramework.EFOracleProviderServices, Oracle.ManagedDataAccess.EntityFramework, Version=6.122.1.0, Culture=neutral, PublicKeyToken=89b483f429c47342" />
    </providers>
</entityFramework>
<system.data>
  <DbProviderFactories>
    <remove invariant="Oracle.ManagedDataAccess.Client" />
    <add name="ODP.NET, Managed Driver" invariant="Oracle.ManagedDataAccess.Client" description="Oracle Data Provider for .NET, Managed Driver" type="Oracle.ManagedDataAccess.Client.OracleClientFactory, Oracle.ManagedDataAccess, Version=4.122.1.0, Culture=neutral, PublicKeyToken=89b483f429c47342" />
  </DbProviderFactories>
</system.data>
<oracle.manageddataaccess.client>
  <version number="*">
    <dataSources>
      <dataSource alias="SampleDataSource" descriptor="(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=ORCL))) " />
    </dataSources>
  </version>
</oracle.manageddataaccess.client>
```

* connectionStrings中修改Oracle的连接字段的参数

```xml
<connectionStrings>
    <!-- 因为生成的<dataSources>中服务名是ORCL，与我的设置相同，所以这里直接用别名SampleDataSource-->
    <add name="OracleDbContext" 
         providerName="Oracle.ManagedDataAccess.Client" 
         connectionString="User Id=C##TESTUSER;Password=123;Data Source=SampleDataSource" />
</connectionStrings>
```
* 修改Models/DbConnectPracContext.cs

```c#
namespace DbConnectPrac.Models
{
    public class DbConnectPracContext : DbContext
    {
        // 修改指定使用的数据库连接
        //public DbConnectPracContext() : base("name=DbConnectPracContext") { } // LocalDB
        public DbConnectPracContext() : base("name=OracleDbContext") { } // Oracle
        // 默认的模式名是dbo，但Oracle中不存在模式名为dbo，需要指定默认模式名
      	protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.HasDefaultSchema("C##TESTUSER"); // 默认模式名就是把你用户名大写
        }
        // .....省略......
    }
}
```
Oracle中不存在模式名为dbo，dbo是SQL Server数据库的，如图例。

![9](9.png)

* 程序包管理器控制台输入

```powershell
Enable-Migrations -EnableAutomaticMigrations
```

* 运行项目进入对应的Controller你可以方便的实现增删改查(CRUD)操作。


_连接Oracle查看生成的表_

![10](10.png)

**最后一次测试时，发现一个BUG，如果把刚生成的表全删除，试图通过重新运行项目重新建表，会失败。这个情况只在Oracle上发生，大概官方还没注意到这个BUG。“一次性”用户真是尴尬……**


