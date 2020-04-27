---
title: 通俗设计模式（译）
date: 2020-04-23 20:43:42
tags:
- translation
- design pattern
---

[原文：Design Patterns for Humans](https://roadmap.sh/guides/design-patterns-for-humans)

设计模式是对反复出现的问题的解决方案；*解决某些问题的指南*。它们不是像魔法一样的类、包或者库。这个指南说的是在某些情况下如何解决某些问题。

<!--more-->

> 设计模式是对反复出现的问题的解决方案。如何解决某些问题的指南。

维基百科的描述如下：

> 在软件工程领域，软件设计模式是对软件设计中给定上下文中常见问题的通用可重用解决方案。它不是可以直接转换为源代码或机器码的最终设计。它是一种描述或模板，用于在许多不同情况下解决问题。

## 小心

开发人员（大多是初学者）犯了过分思考和强加设计模式的错误，这可能会导致灾难。经验法则是使代码库尽可能简单，当你开发中能在代码库中看到重复模式时，再执行相关设计模式。

- 设计模式不是银弹（译注：银弹指的是万能工具）。
- 不要强行使用，不然有好果子吃。
- 请记住，设计模式是*解决*问题的方法，而不是*发现*问题的方案，不要想太多。
- 用得对时被称为救星，不然就是代码混乱。

> 虽然代码示例用 PHP-7 编写，但丝毫不影响你理解概念。

## 设计模式的类型

本指南参考 Gang of Four (Gof) 的[《设计模式》](https://en.wikipedia.org/wiki/Design_Patterns)一书。书中将设计模式分成 3 类：

- [Creational 创建型模式](#创建型模式)
- [Structural 结构型模式](#结构型模式)
- [Behavioral 行为型模式](#行为型模式)

## 创建型模式

简而言之

> 创建型模式关注如何实例化一个对象或一组对象。

维基说

> 软件工程领域，创建型模式是处理对象创建机制的设计模式，尝试以适合的方式创建对象。对象创建的基本形式可能会导致设计问题或者增加设计的复杂性。创建型模式通过某种方法控制对象的创建来解决此问题。

这里列出 6 种创建型模式：

- [Simple Factory 简单工厂](#🏠-简单工厂) 
- [Factory Method 工厂方法](#🏭-工厂方法) 
- [Abstract Factory 抽象工厂](#🔨-抽象工厂) 
- [Builder 生成器](#👷-生成器) 
- [Prototype 原型](#🐑-原型) 
- [Singleton 单例](#💍-单例) 

### 🏠 简单工厂

现实例子

> 考虑一下，你在盖房子，需要门。你可以穿上木匠衣服，带上木头、胶水、钉子和所有必要的工具，然后开始在房子里造门。或者你只要打个电话给工厂，让他们把造好的门给你，这样你就不需要了解任何造门的额外知识了。

简而言之

> 简单工厂只需要为使用者生成一个实例，而不需要为使用者公开任何实例化的逻辑。

维基说

> 面向对象编程（OOP）中，工厂是用于创建其他对象的对象 —— 正式说法是，工厂是一种函数或方法，它从某个方法（假定为 “new”）调用并返回不同原型或类的对象。

**程序示例**

首先是门的接口和其实现：

```php
interface Door
{
    public function getWidth(): float;
    public function getHeight(): float;
}

class WoodenDoor implements Door
{
    protected $width;
    protected $height;

    public function __construct(float $width, float $height)
    {
        $this->width = $width;
        $this->height = $height;
    }

    public function getWidth(): float
    {
        return $this->width;
    }

    public function getHeight(): float
    {
        return $this->height;
    }
}
```

然后我们有个门工厂来制造门并返回它：

```php
class DoorFactory
{
    public static function makeDoor($width, $height): Door
    {
        return new WoodenDoor($width, $height);
    }
}
```

然后就可以这样用：

```php
// 给我造一扇 100*200 尺寸的门
$door = DoorFactory::makeDoor(100, 200);

echo 'Width: ' . $door->getWidth();
echo 'Height: ' . $door->getHeight();

// 给我造一扇 50*100 尺寸的门
$door2 = DoorFactory::makeDoor(50, 100);
```

**啥时候用呢？**

创建对象时，不仅要复制，还要执行一些逻辑操作，这些代码放到专门的“工厂”里相比四处复制粘贴相同代码是更有意义的。

### 🏭 工厂方法

现实例子

> 思考一个招聘经理的例子，一个人不可能对每个职位进行面试。根据职位空缺，她必须决定面试步骤然后将其委托给其他人。

简而言之

> 它提供了一种将实例化逻辑委托给子类的方法。

维基说

> 基于类的编程中，工厂方法模式是一种创建型模式，该模式使用工厂方法来处理创建对象的问题，而不必指定将要创建对象的确切类。这是通过调用工厂方法创建对象来完成的。该方法在接口中指定并由子类实现，或者在基类中实现，并且可以选择由派生类覆盖，而不是通过调用构造函数来覆盖。

**程序示例**

以我们上文的招聘经理为例。首先，我们有一个面试官接口及其实现：

```php
interface Interviewer
{
    public function askQuestions();
}

class Developer implements Interviewer
{
    public function askQuestions()
    {
        echo 'Asking about design patterns!';
    }
}

class CommunityExecutive implements Interviewer
{
    public function askQuestions()
    {
        echo 'Asking about community building';
    }
}
```

现在定义招聘经理（HiringManager）：

```php
abstract class HiringManager
{

    // 工厂方法
    abstract protected function makeInterviewer(): Interviewer;

    public function takeInterview()
    {
        $interviewer = $this->makeInterviewer();
        $interviewer->askQuestions();
    }
}
```

现在，任何子类都可扩展它并提供所需要的面试官：

```php
class DevelopmentManager extends HiringManager
{
    protected function makeInterviewer(): Interviewer
    {
        return new Developer();
    }
}

class MarketingManager extends HiringManager
{
    protected function makeInterviewer(): Interviewer
    {
        return new CommunityExecutive();
    }
}
```

这样用：

```php
$devManager = new DevelopmentManager();
$devManager->takeInterview(); // Output: Asking about design patterns

$marketingManager = new MarketingManager();
$marketingManager->takeInterview(); // Output: Asking about community building.
```

**啥时候用呢？**

当类中有一些通用处理但所需的子类在运行时动态确定时很有用。或者换句话说，用户不知道它可能需要什么确切的子类。

### 🔨 抽象工厂

现实例子

> 对简单工厂的例子扩展一下。根据你的需求， 你可能从一家木门店买到一扇门，或者在铁门店买到一扇铁门，或者相关的店买到 PVC 门。另外，你可能需要具有不同专业技能的人来安装不同的门，例如，木门的木匠，铁门的焊接工等。如你所见，他们与门之间存在依赖性，木门需要木匠，铁门需要焊接工等。

简而言之

> 工厂的工厂；一个将相关或从属的工厂分组在一起，但不指定其具体类别的工厂。

维基说

> 抽象工厂模式提供了一种方法来封装一组具有共同主题的单个工厂，而无需指定其具体类。

**程序示例**

转换上面门的例子。首先是门的接口及其实现：

```php
interface Door
{
    public function getDescription();
}

class WoodenDoor implements Door
{
    public function getDescription()
    {
        echo 'I am a wooden door';
    }
}

class IronDoor implements Door
{
    public function getDescription()
    {
        echo 'I am an iron door';
    }
}
```

然后我们为每种门配备装配专家：

```php
interface DoorFittingExpert
{
    public function getDescription();
}

class Welder implements DoorFittingExpert
{
    public function getDescription()
    {
        echo 'I can only fit iron doors';
    }
}

class Carpenter implements DoorFittingExpert
{
    public function getDescription()
    {
        echo 'I can only fit wooden doors';
    }
}
```

现在我们有了抽象工厂，它将使我们能够制造一系列对象，即木门工厂将创建木门和木门装配专家，铁门工厂将创建铁门和铁门装配专家。

```php
interface DoorFactory
{
    public function makeDoor(): Door;
    public function makeFittingExpert(): DoorFittingExpert;
}

// 木门工厂返回木匠和木门
class WoodenDoorFactory implements DoorFactory
{
    public function makeDoor(): Door
    {
        return new WoodenDoor();
    }

    public function makeFittingExpert(): DoorFittingExpert
    {
        return new Carpenter();
    }
}

// 铁门工厂返回铁门和相关的装配专家
class IronDoorFactory implements DoorFactory
{
    public function makeDoor(): Door
    {
        return new IronDoor();
    }

    public function makeFittingExpert(): DoorFittingExpert
    {
        return new Welder();
    }
}
```

接着这么用：

```php
$woodenFactory = new WoodenDoorFactory();

$door = $woodenFactory->makeDoor();
$expert = $woodenFactory->makeFittingExpert();

$door->getDescription();  // Output: I am a wooden door
$expert->getDescription(); // Output: I can only fit wooden doors

// Same for Iron Factory
$ironFactory = new IronDoorFactory();

$door = $ironFactory->makeDoor();
$expert = $ironFactory->makeFittingExpert();

$door->getDescription();  // Output: I am an iron door
$expert->getDescription(); // Output: I can only fit iron doors
```

如你所见，木门工厂已经封装了木匠（carpenter）和木门（wooden door），铁门工厂已经封装了铁门（iron door）和焊接工（welder）。因此，它确保我们对于每个已创建的门不会匹配到错误的装配专家。

**啥时候用呢?**

当存在相互关联的依赖关系并且涉及到非简单的创建逻辑时。

### 👷 生成器

现实例子

> 加入你在 Hardee 店里下了一笔订单，他们会毫无疑问的将货品交给你；这是简单工厂的例子。但是某些情况下，创建逻辑可能设计更多的步骤。例如，你想要定制赛百味的订单，在汉堡的制作方式上有多种选择，例如：你想要哪种面包？想要那种调味料？那种奶酪？等等。这种情况下，生成器模式应运而生。

简而言之

> 允许你创建对象的不同样式，同时避免构造函数污染。当一个对象有多种风格时很有用，亦或者创建对象涉及很多步骤时。

维基说

> 生成器模式是一种对象创建软件设计模式，旨在为伸缩构造器反模式找到解决方案。

解释一下什么是伸缩构造器反模式。有时我们见过以下构造函数：

```php
public function __construct($size, $cheese = true, $pepperoni = true, $tomato = false, $lettuce = true)
{
}
```

如你所见，构造函数参数的数量很快会失控，过多的参数看着会很头大。另外，如果你想添加更多选项，则此参数列表还继续增长。这就是伸缩构造函数反模式。

**程序示例**

明智的做法是使用构造器模式。首先，我们要做汉堡：

```php
class Burger
{
    protected $size;

    protected $cheese = false;
    protected $pepperoni = false;
    protected $lettuce = false;
    protected $tomato = false;

    public function __construct(BurgerBuilder $builder)
    {
        $this->size = $builder->size;
        $this->cheese = $builder->cheese;
        $this->pepperoni = $builder->pepperoni;
        $this->lettuce = $builder->lettuce;
        $this->tomato = $builder->tomato;
    }
}
```

接着是我们的生成器：


```php
class BurgerBuilder
{
    public $size;

    public $cheese = false;
    public $pepperoni = false;
    public $lettuce = false;
    public $tomato = false;

    public function __construct(int $size)
    {
        $this->size = $size;
    }

    public function addPepperoni()
    {
        $this->pepperoni = true;
        return $this;
    }

    public function addLettuce()
    {
        $this->lettuce = true;
        return $this;
    }

    public function addCheese()
    {
        $this->cheese = true;
        return $this;
    }

    public function addTomato()
    {
        $this->tomato = true;
        return $this;
    }

    public function build(): Burger
    {
        return new Burger($this);
    }
}
```

这么用：

```php
$burger = (new BurgerBuilder(14))
                    ->addPepperoni()
                    ->addLettuce()
                    ->addTomato()
                    ->build();
```

**啥时候用呢？**

当对象的配置项过多，为了避免伸缩构造函数时，这与工厂模式的主要区别在于：当创建是一步过程时，使用工厂模式，而创建是多步过程是，将使用生成器模式。

### 🐑 原型

现实例子

> 记得多利吗？那只克隆羊！不谈细节，关键是克隆。

简而言之

> 通过克隆基于现有对象创建对象。

维基说

> 原型模式是软件开发中的一种创建型模式。当要创建的对象由原型示例确定时使用，该实例被克隆以生成新对象。

简而言之，它使你可以创建现有对象的副本并根据需要对其进行修改，而不必麻烦从头开始创建对象并设置。

**程序实例**

在 PHP 中，用 `clone` 很容易做到：

```php
class Sheep
{
    protected $name;
    protected $category;

    public function __construct(string $name, string $category = 'Mountain Sheep')
    {
        $this->name = $name;
        $this->category = $category;
    }

    public function setName(string $name)
    {
        $this->name = $name;
    }

    public function getName()
    {
        return $this->name;
    }

    public function setCategory(string $category)
    {
        $this->category = $category;
    }

    public function getCategory()
    {
        return $this->category;
    }
}
```

克隆方式如下：

```php
$original = new Sheep('Jolly');
echo $original->getName(); // Jolly
echo $original->getCategory(); // Mountain Sheep

// Clone and modify what is required
$cloned = clone $original;
$cloned->setName('Dolly');
echo $cloned->getName(); // Dolly
echo $cloned->getCategory(); // Mountain sheep
```

你还可以使用魔法方法 `__clone` 方法修改克隆行为。

**啥时候用呢？**

当需要一个与现有对象相似的对象时，或者与克隆相比创建成本很高。

### 💍 单例

现实例子

> 一个国家一次只能有一位总统。每次接听值班电话的都是同一位总统。总统在这里就是单例。

简而言之

> 确保仅创建特定类的一个对象。

维基说

> 在软件工程中，单例模式时一种将类的实例化限制为一个对象的软件设计模式。当仅需要一个对象来协调整个系统中的动作时，这很有用。

单例模式实际上被认为是反模式，应避免过度使用它。它不一定是坏的，并且可能有一些有效的使用场景但是应谨慎使用，因为它会在你的应用程序中引入全局状态，并且在同一个位置进行更改可能会影响其他区域，这让调试变得非常困难。关于它们的另一个不好的地方是，它会使你的代码高耦合，难以模拟单例。

**程序示例**

要创建单例，请将构造函数设为私有，禁用克隆，禁用扩展，并创建一个静态变量来容纳实例。

```php
final class President
{
    private static $instance;

    private function __construct()
    {
        // Hide the constructor
    }

    public static function getInstance(): President
    {
        if (!self::$instance) {
            self::$instance = new self();
        }

        return self::$instance;
    }

    private function __clone()
    {
        // Disable cloning
    }

    private function __wakeup()
    {
        // Disable unserialize
    }
}
```

接着是使用：

```php
$president1 = President::getInstance();
$president2 = President::getInstance();

var_dump($president1 === $president2); // true
```


## 结构型模式

简而言之

> 结构模式主要与对象组成有关，换句话说，实体如何互相利用。或者还有另一种解释，它们有助于回答“如何构建软件组件？”。

维基说

> 在软件工程中，结构型模式是通过识别实体间的简单方法来简化设计的设计模式。

这有 7 种结构模式：

- [Adapter 适配器](#🔌-适配器)
- [Bridge 桥接](#🚡-桥接)
- [Composite 组合](#🌿-组合)
- [Decorator 装饰器](#☕-装饰器)
- [Facade 外观](#📦-外观模式)
- [Flyweight 享元](#🍃-享元)
- [Proxy 代理](#🎱-代理)

### 🔌 适配器

现实例子

> 在你的存储卡中有一些照片，需要将它们传输到计算机上。为了传输它们，你需要某种和计算机端口兼容的适配器，以便将存储卡连接到计算机。这种情况下，读卡器就是适配器。另一个例子是著名的电源适配器，三脚插头不能连接到两脚插座，需要使用电源适配器，使其与两脚插座兼容。还有个例子是翻译员将一个人说的话翻译给另一个人。

简而言之

> 适配器模式是你可以将其他不兼容的对象包装到适配器中，以使其与另一个类兼容。

维基说

> 软件工程领域，适配器模式是一种软件设计模式，它允许将现有类的接口用作另一个接口。它通常用于将现有类和其他类一起使用而无需修改其源代码。

**程序示例**

思考一个猎人狩猎狮子的游戏。首先我们有一个 `Lion` 接口，所有类型的狮子都必须实现。

```php
interface Lion
{
    public function roar();
}

class AfricanLion implements Lion
{
    public function roar()
    {
    }
}

class AsianLion implements Lion
{
    public function roar()
    {
    }
}
```

猎人使用 `Lion` 接口的任何实现都可以进行狩猎。

```php
class Hunter
{
    public function hunt(Lion $lion)
    {
        $lion->roar();
    }
}
```

现在假设我们必须在游戏中添加 WildDog （野狗），以便猎人对其狩猎。但是我们不能直接这样做，因为狗具有不同的接口。为了使其与我们的猎人兼容，我们必须创建一个兼容的适配器。

```php
// 把它添加到游戏。
class WildDog
{
    public function bark()
    {
    }
}

// 关于野狗的适配器，使其与我们的游戏兼容。
class WildDogAdapter implements Lion
{
    protected $dog;

    public function __construct(WildDog $dog)
    {
        $this->dog = $dog;
    }

    public function roar()
    {
        $this->dog->bark();
    }
}
```

现在可以使用 WildDogAdapter 在我们的游戏中使用 WildDog 了。

```php
$wildDog = new WildDog();
$wildDogAdapter = new WildDogAdapter($wildDog);

$hunter = new Hunter();
$hunter->hunt($wildDogAdapter);
```

### 🚡 桥接

现实例子

> 考虑你有一个包含不同页面的网站，并且允许用户更改主题。你会怎么做？为每个主题创建每个页面的多个副本，还是只创建单独的主题，根据用户的喜好加载它们？桥接模式允许你执行第二种方案。

![Without Bridge](33b7aea0-f515-11e6-983f-98823c9845ee.png)

简而言之

> 桥接模式是优先于继承而不是继承。将实现细节从层次结构推送到具有单独层次结构的另一个对象。

维基说

> 桥接模式是软件工程中使用的一种设计模式，旨在“将抽象与其实现分离，从而使两者可以独立变化”。

**程序示例**

转换上面 WebPage 的例子。这是 WebPage 的层次结构。

```php
interface WebPage
{
    public function __construct(Theme $theme);
    public function getContent();
}

class About implements WebPage
{
    protected $theme;

    public function __construct(Theme $theme)
    {
        $this->theme = $theme;
    }

    public function getContent()
    {
        return "About page in " . $this->theme->getColor();
    }
}

class Careers implements WebPage
{
    protected $theme;

    public function __construct(Theme $theme)
    {
        $this->theme = $theme;
    }

    public function getContent()
    {
        return "Careers page in " . $this->theme->getColor();
    }
}
```

以及单独主题的层次结构

```php
interface Theme
{
    public function getColor();
}

class DarkTheme implements Theme
{
    public function getColor()
    {
        return 'Dark Black';
    }
}
class LightTheme implements Theme
{
    public function getColor()
    {
        return 'Off white';
    }
}
class AquaTheme implements Theme
{
    public function getColor()
    {
        return 'Light blue';
    }
}
```

两个层次的用法

```php
$darkTheme = new DarkTheme();

$about = new About($darkTheme);
$careers = new Careers($darkTheme);

echo $about->getContent(); // "About page in Dark Black";
echo $careers->getContent(); // "Careers page in Dark Black";
```

### 🌿 组合

现实例子

> 每一个组织由雇员组成。每个受雇者有相同功能，比如，有一份薪水、一些职责、是否向某人报告、是否有下属等等。

简而言之

> 组合模式使客户能够以统一的方式对待各个对象。

维基说

> 在软件工程中，组合模式是一种分区设计模式。组合模式将一组对象当成一个对象的单个实例对待。组合的目的是将对象“组成”树状结构，以表示整个部分的层次结构。实现组合模式可以使客户统一对待单个对象和复合对象。

**程序示例**

以我们的雇员为例。这里有不同的员工类型。

```php
interface Employee
{
    public function __construct(string $name, float $salary);
    public function getName(): string;
    public function setSalary(float $salary);
    public function getSalary(): float;
    public function getRoles(): array;
}

class Developer implements Employee
{
    protected $salary;
    protected $name;
    protected $roles;
    
    public function __construct(string $name, float $salary)
    {
        $this->name = $name;
        $this->salary = $salary;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setSalary(float $salary)
    {
        $this->salary = $salary;
    }

    public function getSalary(): float
    {
        return $this->salary;
    }

    public function getRoles(): array
    {
        return $this->roles;
    }
}

class Designer implements Employee
{
    protected $salary;
    protected $name;
    protected $roles;

    public function __construct(string $name, float $salary)
    {
        $this->name = $name;
        $this->salary = $salary;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setSalary(float $salary)
    {
        $this->salary = $salary;
    }

    public function getSalary(): float
    {
        return $this->salary;
    }

    public function getRoles(): array
    {
        return $this->roles;
    }
}
```

然后我们有一个由几种不同类型雇员组成的组织。

```php
class Organization
{
    protected $employees;

    public function addEmployee(Employee $employee)
    {
        $this->employees[] = $employee;
    }

    public function getNetSalaries(): float
    {
        $netSalary = 0;

        foreach ($this->employees as $employee) {
            $netSalary += $employee->getSalary();
        }

        return $netSalary;
    }
}
```

接着这么用

```php
// 准备员工
$john = new Developer('John Doe', 12000);
$jane = new Designer('Jane Doe', 15000);

// 把他们添加到组织
$organization = new Organization();
$organization->addEmployee($john);
$organization->addEmployee($jane);

echo "Net salaries: " . $organization->getNetSalaries(); // Net Salaries: 27000
```

### ☕ 装饰器

现实例子

> 假设你经营一家提供多种服务的汽车维修店。现在，你要如何计算要收取的账单？选择一项服务，并动态地向其添加服务和的价格，知道获得最终花销。这里的每种服务都是装饰器。

简而言之

> 装饰器模式使你可以将对象包装在装饰器类的对象中，从而在运行时动态更改对象的行为。

维基说

> 面向对象编程中，装饰器模式是一种设计模式，它允许将行为动态或静态地添加到单个对象中，而不影响同一类中其他对象地行为。装饰器模式通常可用于遵守“单一职责原则”，因为它允许在具有唯一关注区域的类之间划分功能。

**程序示例**

以咖啡为例，首先，我们有个简单的 offee 的接口及实现。

```php
interface Coffee
{
    public function getCost();
    public function getDescription();
}

class SimpleCoffee implements Coffee
{
    public function getCost()
    {
        return 10;
    }

    public function getDescription()
    {
        return 'Simple coffee';
    }
}
```

我们希望使代码可扩展，以便在需要时通过选项配置，我们为其添加装饰器。

```php
class MilkCoffee implements Coffee
{
    protected $coffee;

    public function __construct(Coffee $coffee)
    {
        $this->coffee = $coffee;
    }

    public function getCost()
    {
        return $this->coffee->getCost() + 2;
    }

    public function getDescription()
    {
        return $this->coffee->getDescription() . ', milk';
    }
}

class WhipCoffee implements Coffee
{
    protected $coffee;

    public function __construct(Coffee $coffee)
    {
        $this->coffee = $coffee;
    }

    public function getCost()
    {
        return $this->coffee->getCost() + 5;
    }

    public function getDescription()
    {
        return $this->coffee->getDescription() . ', whip';
    }
}

class VanillaCoffee implements Coffee
{
    protected $coffee;

    public function __construct(Coffee $coffee)
    {
        $this->coffee = $coffee;
    }

    public function getCost()
    {
        return $this->coffee->getCost() + 3;
    }

    public function getDescription()
    {
        return $this->coffee->getDescription() . ', vanilla';
    }
}
```

现在来制作咖啡。

```php
$someCoffee = new SimpleCoffee();
echo $someCoffee->getCost(); // 10
echo $someCoffee->getDescription(); // Simple Coffee

$someCoffee = new MilkCoffee($someCoffee);
echo $someCoffee->getCost(); // 12
echo $someCoffee->getDescription(); // Simple Coffee, milk

$someCoffee = new WhipCoffee($someCoffee);
echo $someCoffee->getCost(); // 17
echo $someCoffee->getDescription(); // Simple Coffee, milk, whip

$someCoffee = new VanillaCoffee($someCoffee);
echo $someCoffee->getCost(); // 20
echo $someCoffee->getDescription(); // Simple Coffee, milk, whip, vanilla
```

### 📦 外观模式

现实例子

> 你是怎么打开计算机的？“按下电源按钮”你会这么说，那仅仅是你所知道的，那是你使用的计算机在外部提供的简单接口，在内部，它还必须要做很多事情才能实现。与复杂子系统的这种简单接口就是一个外观。

简而言之

> 外观模式提供了到复杂子系统的简化接口。

维基说

> 外观是为大型代码（例如类库）提供简化接口的对象。

**程序示例**

用上面计算机的例子，这里有个计算机类。

```php
class Computer
{
    public function getElectricShock()
    {
        echo "Ouch!";
    }

    public function makeSound()
    {
        echo "Beep beep!";
    }

    public function showLoadingScreen()
    {
        echo "Loading..";
    }

    public function bam()
    {
        echo "Ready to be used!";
    }

    public function closeEverything()
    {
        echo "Bup bup bup buzzzz!";
    }

    public function sooth()
    {
        echo "Zzzzz";
    }

    public function pullCurrent()
    {
        echo "Haaah!";
    }
}
```

这是外观。

```php
class ComputerFacade
{
    protected $computer;

    public function __construct(Computer $computer)
    {
        $this->computer = $computer;
    }

    public function turnOn()
    {
        $this->computer->getElectricShock();
        $this->computer->makeSound();
        $this->computer->showLoadingScreen();
        $this->computer->bam();
    }

    public function turnOff()
    {
        $this->computer->closeEverything();
        $this->computer->pullCurrent();
        $this->computer->sooth();
    }
}
```

使用外观。

```php
$computer = new ComputerFacade(new Computer());
$computer->turnOn(); // Ouch! Beep beep! Loading.. Ready to be used!
$computer->turnOff(); // Bup bup buzzz! Haah! Zzzzz
```

### 🍃 享元

现实例子

> 你有没有在摊子上买过茶？他们通常会多做几杯，把多出来的留给其他顾客，这样可以节约资源，比如燃气。 享元设计模式主要就是这里，即共享。

简而言之

> 它用于通过与相似对象尽可能多地共享来最大程度减少内存使用或者计算开销。

维基说

> 在计算机编程中，享元 是一种软件设计模式。享元是通过与其他类似对象共享尽可能多的数据来最大程度减少内存使用的对象；当简单的重复代码占用了过多内存时，这是一种大量使用对象的方法。

**程序示例**

利用上面茶的例子。首先要有做茶师傅。

```php
// Anything that will be cached is flyweight.
// Types of tea here will be flyweights.
class KarakTea
{
}

// Acts as a factory and saves the tea
class TeaMaker
{
    protected $availableTea = [];

    public function make($preference)
    {
        if (empty($this->availableTea[$preference])) {
            $this->availableTea[$preference] = new KarakTea();
        }

        return $this->availableTea[$preference];
    }
}
```

接着是提供服务的茶店（TeaShop）

```php
class TeaShop
{
    protected $orders;
    protected $teaMaker;

    public function __construct(TeaMaker $teaMaker)
    {
        $this->teaMaker = $teaMaker;
    }

    public function takeOrder(string $teaType, int $table)
    {
        $this->orders[$table] = $this->teaMaker->make($teaType);
    }

    public function serve()
    {
        foreach ($this->orders as $table => $tea) {
            echo "Serving tea to table# " . $table;
        }
    }
}
```

用法

```php
$teaMaker = new TeaMaker();
$shop = new TeaShop($teaMaker);

$shop->takeOrder('less sugar', 1);
$shop->takeOrder('more milk', 2);
$shop->takeOrder('without sugar', 5);

$shop->serve();
// Serving tea to table# 1
// Serving tea to table# 2
// Serving tea to table# 5
```

### 🎱 代理

实际例子

> 用过门禁卡通过安全门吗？开门的方法很多，比如用门禁卡或者按下绕过安全性的按钮。门的主要功能是打开，但是其顶部添加了代理以添加一些功能。让我使用下面的代码示例解释它。

简而言之

> 使用代理模式，一个类表示另一个类的功能。

维基说

> 一般来说，代理是一个类，充当其他类的接口。代理时客户端调用的包装器或者包装对象，用来访问后台的真实对象。使用代理可以简单地转发到真实对象，还可以提供其他逻辑。在代理中，还可以提供额外的功能，例如在对实际对象地操作占用大量资源时进行缓存，或者在调用对真是对象地操作之前检查先决条件。

**程序示例**

用上面安全门的例子。首先，实现门的接口。

```php
interface Door
{
    public function open();
    public function close();
}

class LabDoor implements Door
{
    public function open()
    {
        echo "Opening lab door";
    }

    public function close()
    {
        echo "Closing the lab door";
    }
}
```

接着我们用一个代理使门更安全

```php
class SecuredDoor
{
    protected $door;

    public function __construct(Door $door)
    {
        $this->door = $door;
    }

    public function open($password)
    {
        if ($this->authenticate($password)) {
            $this->door->open();
        } else {
            echo "Big no! It ain't possible.";
        }
    }

    public function authenticate($password)
    {
        return $password === '$ecr@t';
    }

    public function close()
    {
        $this->door->close();
    }
}
```

用例

```php
$door = new SecuredDoor(new LabDoor());
$door->open('invalid'); // Big no! It ain't possible.

$door->open('$ecr@t'); // Opening lab door
$door->close(); // Closing lab door
```

另一个例子是某种数据映射器的实现。例如，我最近使用这种模式为 MongoDB 制作了 ODM (对象数据映射器)，在其中用到了魔法方法 `__call()` 围绕 mongo 类编写了一个代理。所有的方法调用都被代理到原始 mongo 类，并且原样返回检索结果，但是 `find` 或 `findOne` 的情况下，数据映射到所需的类对象，返回的是该对象而不是 `Cursor`。

## 行为型模式

简而言之

> 它与对象之间的职责分配有关。它们与结构模式的不同之处在于它们不仅指定结构，而且还概述了它们之间消息传递/通信的模式。换句话说，它们是为了解决如何在软件组件中运行一种行为的问题。

维基说

> 软件工程中，行为型模式是识别对象之间常见的通信模式并实现这些模式的设计模式。这样做提高了执行此通信的灵活性。

下面列出 10 种行为型模式：

- [Chain of Responsibility 责任链](#🔗-责任链)
- [Command 命令](#👮-命令)
- [Iterator 迭代器](#➿-迭代器)
- [Mediator 调解员](#👽-调解员)
- [Memento 备忘录](#💾-备忘录)
- [Observer 观察者](#😎-观察者)
- [Visitor 访问者](#🏃-访问者)
- [Strategy 策略](#💡-策略)
- [State 状态](#💢-状态)
- [Template Method 模板方法](#📒-模板方法)

### 🔗 责任链

现实例子

> 如果，你的账号有三种支付方式（A，B 和 C)；每个账号都有不同的存款。 A 有 100 元， B 有 300 元 和 C 有 1000 元，支付偏好的顺序依次为 A、B、C 。你将支付以捡 210 元的商品。用上责任链，首先会检查账户 A 够不够支付，如果可以，将进行购买，然后链条断裂。如果不够，则请求会进一步到账户 B ，检查是否够支付，如果可以，将进行购买，然后链条断裂。否则请求继续直到找到何时的处理程序为止。在这里，A、B 和 C 是链上的链接，整个现象就是责任链。

简而言之

> 它有助于构建对象链。请求从一端进入，并不断地从一个对象移到另一个对象，直到找到合适地处理程序为止。

维基说

> 面向对象设计中，责任链模式是一种设计模式，由命令对象的源和一系列处理对象组成。每个处理对象都包含定义其可以处理的命令对象类型的逻辑；其余的将传递到链中的下一个处理对象。

**程序示例**

用上账户的例子。首先，我们有一个基本账户，该账户具有账户和某些账户链接在一起的逻辑。

```php
abstract class Account
{
    protected $successor;
    protected $balance;

    public function setNext(Account $account)
    {
        $this->successor = $account;
    }

    public function pay(float $amountToPay)
    {
        if ($this->canPay($amountToPay)) {
            echo sprintf('Paid %s using %s' . PHP_EOL, $amountToPay, get_called_class());
        } elseif ($this->successor) {
            echo sprintf('Cannot pay using %s. Proceeding ..' . PHP_EOL, get_called_class());
            $this->successor->pay($amountToPay);
        } else {
            throw new Exception('None of the accounts have enough balance');
        }
    }

    public function canPay($amount): bool
    {
        return $this->balance >= $amount;
    }
}

class Bank extends Account
{
    protected $balance;

    public function __construct(float $balance)
    {
        $this->balance = $balance;
    }
}

class Paypal extends Account
{
    protected $balance;

    public function __construct(float $balance)
    {
        $this->balance = $balance;
    }
}

class Bitcoin extends Account
{
    protected $balance;

    public function __construct(float $balance)
    {
        $this->balance = $balance;
    }
}
```

现在，使用上面定义的链接（即银行、PayPal、比特币）准备链。

```php
// 准备这样一条链
//      $bank->$paypal->$bitcoin
//
// 最开始是银行
//      如果银行不够就尝试 PayPal
//     如果 PayPal 不够再尝试 bit coin

$bank = new Bank(100);          // 银行余额 100
$paypal = new Paypal(200);      // Paypal 余额为 200
$bitcoin = new Bitcoin(300);    // Bitcoin 余额为 300

$bank->setNext($paypal);
$paypal->setNext($bitcoin);

// Let's try to pay using the first priority i.e. bank
$bank->pay(259);

// Output will be
// ==============
// Cannot pay using bank. Proceeding ..
// Cannot pay using paypal. Proceeding ..:
// Paid 259 using Bitcoin!
```

### 👮 命令

现实例子

> 一个通用的例子是你在餐厅点餐。你（即客户）要求服务员（即调用者）带来一些食物（即命令），服务员只需将请求转发给负责烹饪的厨师（即接收者）。另一个例子是，你（即客户）使用遥控器（即调用者）打开（即命令）电视（即接收者）。

简而言之

> 允许你将动作封装在对象中。该模式的关键思想是提供使客户端和接收者解耦的方法。

维基说

> 面向对象编程中，命令模式是一种行为型模式，其中的对象用于封装以后执行动作或触发事件所需的所有信息。该信息包括方法名称，拥有方法的对象和方法参数的值。

**程序示例**

首先实现接收者的所有动作

```php
// Receiver
class Bulb
{
    public function turnOn()
    {
        echo "Bulb has been lit";
    }

    public function turnOff()
    {
        echo "Darkness!";
    }
}
```

然后我们将接口的每一个命令都实现

```php
interface Command
{
    public function execute();
    public function undo();
    public function redo();
}

// Command
class TurnOn implements Command
{
    protected $bulb;

    public function __construct(Bulb $bulb)
    {
        $this->bulb = $bulb;
    }

    public function execute()
    {
        $this->bulb->turnOn();
    }

    public function undo()
    {
        $this->bulb->turnOff();
    }

    public function redo()
    {
        $this->execute();
    }
}

class TurnOff implements Command
{
    protected $bulb;

    public function __construct(Bulb $bulb)
    {
        $this->bulb = $bulb;
    }

    public function execute()
    {
        $this->bulb->turnOff();
    }

    public function undo()
    {
        $this->bulb->turnOn();
    }

    public function redo()
    {
        $this->execute();
    }
}
```

接着我们的调用者，客户端将与之交互以处理任何命令。

```php
// Invoker
class RemoteControl
{
    public function submit(Command $command)
    {
        $command->execute();
    }
}
```

最后看看客户端中如何使用

```php
$bulb = new Bulb();

$turnOn = new TurnOn($bulb);
$turnOff = new TurnOff($bulb);

$remote = new RemoteControl();
$remote->submit($turnOn); // Bulb has been lit!
$remote->submit($turnOff); // Darkness!
```

命令模式可以用来实现基于事务的系统。一旦执行命令，便会继续保持命令的历史记录。如果最终的命令被成功执行，要么一切正常否则只需要便利历史记录并继续对所有已执行的命令执行撤销即可。

### ➿ 迭代器

现实例子

> 旧收音机的例子挺不错，用户可以从某个频道开始，然后使用下一个或者上一个按钮浏览各个频道。又或者是 MP3 播放器或者电视机也可以通过前后按钮浏览内容，换句话说它们都提供了一个接口，以循环的方式访问相应的频道，歌曲或广播电台。

简而言之

> 它提供了一种在不暴露底层实现的情况下访问对象元素的方法。

维基说

> 面向对象编程中，迭代器模式是一种设计模式，其中迭代器用于遍历容器并访问容器的元素。迭代器模式将算法与容器解耦；在某些情况下，算法必然特定于容器，因此无法解耦。

**程序示例**

在 PHP 中使用 SPL （标准库） 很容易实现。转换上面电台的例子，首先设计电台类。

```php
class RadioStation
{
    protected $frequency;

    public function __construct(float $frequency)
    {
        $this->frequency = $frequency;
    }

    public function getFrequency(): float
    {
        return $this->frequency;
    }
}
```

然后实现迭代器

```php
use Countable;
use Iterator;

class StationList implements Countable, Iterator
{
    /** @var RadioStation[] $stations */
    protected $stations = [];

    /** @var int $counter */
    protected $counter;

    public function addStation(RadioStation $station)
    {
        $this->stations[] = $station;
    }

    public function removeStation(RadioStation $toRemove)
    {
        $toRemoveFrequency = $toRemove->getFrequency();
        $this->stations = array_filter($this->stations, function (RadioStation $station) use ($toRemoveFrequency) {
            return $station->getFrequency() !== $toRemoveFrequency;
        });
    }

    public function count(): int
    {
        return count($this->stations);
    }

    public function current(): RadioStation
    {
        return $this->stations[$this->counter];
    }

    public function key()
    {
        return $this->counter;
    }

    public function next()
    {
        $this->counter++;
    }

    public function rewind()
    {
        $this->counter = 0;
    }

    public function valid(): bool
    {
        return isset($this->stations[$this->counter]);
    }
}
```

这么用

```php
$stationList = new StationList();

$stationList->addStation(new RadioStation(89));
$stationList->addStation(new RadioStation(101));
$stationList->addStation(new RadioStation(102));
$stationList->addStation(new RadioStation(103.2));

foreach($stationList as $station) {
    echo $station->getFrequency() . PHP_EOL;
}

$stationList->removeStation(new RadioStation(89)); // Will remove station 89
```

### 👽 调解员

现实例子

> 一个一般的例子，当你与其他人通过手机通话时，对话消息是通过网络提供商发送过去的。这里网络提供商就是调解员。

简而言之

> 调解员模式添加了第三方对象（称作调解员）用于控制两个对象（称作同事）之间的交互。它有助于减少彼此通信的类之间的耦合。因为他们不需要了解彼此的实现。

维基说

> 软件工程中，调解员模式定义了一个对象，该对象封装了一组对象的交互方式。由于该模式可以更改程序运行行为，因此该模式被视为行为模式。

**程序示例**

这是一个简单的聊天室（即调解员）中的用户（即同事）互相发消息的例子。

首先，实现调解员接口，即聊天室。

```php
interface ChatRoomMediator 
{
    public function showMessage(User $user, string $message);
}

// Mediator
class ChatRoom implements ChatRoomMediator
{
    public function showMessage(User $user, string $message)
    {
        $time = date('M d, y H:i');
        $sender = $user->getName();

        echo $time . '[' . $sender . ']:' . $message;
    }
}
```

然后是用户，即同事

```php
class User {
    protected $name;
    protected $chatMediator;

    public function __construct(string $name, ChatRoomMediator $chatMediator) {
        $this->name = $name;
        $this->chatMediator = $chatMediator;
    }

    public function getName() {
        return $this->name;
    }

    public function send($message) {
        $this->chatMediator->showMessage($this, $message);
    }
}
```

用例

```php
$mediator = new ChatRoom();

$john = new User('John Doe', $mediator);
$jane = new User('Jane Doe', $mediator);

$john->send('Hi there!');
$jane->send('Hey!');

// Output will be
// Feb 14, 10:58 [John]: Hi there!
// Feb 14, 10:58 [Jane]: Hey!
```

### 💾 备忘录

现实例子

> 举一个计算器的例子，计算器（即 originator ）在这里每执行一些运算，最后的结果都会保存在内存中（即备忘录），以便你返回它，还可以用某些操作按钮（即看守者）将其恢复。

简而言之

> 备忘录模式是关于捕获和存储对象的当前状态的方式，以便之后可以平滑地恢复它。

维基说

> 备忘录模式是一种软件设计模式，它提供了将对象恢复到其先前状态（回滚撤销）的能力。

通常在需要提供某种撤销功能时很有用。

**程序示例**

我们以文本编辑器为例，该编辑器不时保存状态，并可以根据需要进行恢复。

首先是保存编辑器状态的备忘录对象。

```php
class EditorMemento
{
    protected $content;

    public function __construct(string $content)
    {
        $this->content = $content;
    }

    public function getContent()
    {
        return $this->content;
    }
}
```

接着我们的编辑器，即 originator ，将要使用这个备忘录对象。

```php
class Editor
{
    protected $content = '';

    public function type(string $words)
    {
        $this->content = $this->content . ' ' . $words;
    }

    public function getContent()
    {
        return $this->content;
    }

    public function save()
    {
        return new EditorMemento($this->content);
    }

    public function restore(EditorMemento $memento)
    {
        $this->content = $memento->getContent();
    }
}
```

接着这么用

```php
$editor = new Editor();

// Type some stuff
$editor->type('This is the first sentence.');
$editor->type('This is second.');

// Save the state to restore to : This is the first sentence. This is second.
$saved = $editor->save();

// Type some more
$editor->type('And this is third.');

// Output: Content before Saving
echo $editor->getContent(); // This is the first sentence. This is second. And this is third.

// Restoring to last saved state
$editor->restore($saved);

$editor->getContent(); // This is the first sentence. This is second.
```






### 😎 观察者

现实例子

> 找工作的人在职位发布网站上订阅，获得匹配的工作机会时，他们可以收到消息。

简而言之

> 定义对象之间的依赖关系，以便每当对象改变状态时，都会通知其所有依赖对象。

维基说

> 观察者模式是一种软件设计模式，其中对象（称为主题）维护其依赖项的列表（称为观察者），并通过调用其方法来自动将状态更改通知他们。

**程序示例**

实现上面的例子，首先，需要发布通知给求职者。

```php
class JobPost
{
    protected $title;

    public function __construct(string $title)
    {
        $this->title = $title;
    }

    public function getTitle()
    {
        return $this->title;
    }
}

class JobSeeker implements Observer
{
    protected $name;

    public function __construct(string $name)
    {
        $this->name = $name;
    }

    public function onJobPosted(JobPost $job)
    {
        // Do something with the job posting
        echo 'Hi ' . $this->name . '! New job posted: '. $job->getTitle();
    }
}
```

然后求职者将订阅职位消息

```php
class EmploymentAgency implements Observable
{
    protected $observers = [];

    protected function notify(JobPost $jobPosting)
    {
        foreach ($this->observers as $observer) {
            $observer->onJobPosted($jobPosting);
        }
    }

    public function attach(Observer $observer)
    {
        $this->observers[] = $observer;
    }

    public function addJob(JobPost $jobPosting)
    {
        $this->notify($jobPosting);
    }
}
```

用例

```php
// Create subscribers
$johnDoe = new JobSeeker('John Doe');
$janeDoe = new JobSeeker('Jane Doe');

// Create publisher and attach subscribers
$jobPostings = new EmploymentAgency();
$jobPostings->attach($johnDoe);
$jobPostings->attach($janeDoe);

// Add a new job and see if subscribers get notified
$jobPostings->addJob(new JobPost('Software Engineer'));

// Output
// Hi John Doe! New job posted: Software Engineer
// Hi Jane Doe! New job posted: Software Engineer

```

### 🏃 访问者

实际例子

> 加入有人要去迪拜旅游，他们需要一种进入迪拜的方式（即签证）。抵达之后，他们可以独自前往迪拜的任何地方，而不需要跑腿搞许可证；只要告诉他们地名，就可以去参观。访问者模式让你做到这一点，它可以帮助你添加游览的地点，以便他们可以尽可能多访问而不需要做任何繁琐的工作。

简而言之

> 访问者模式使你可以给对象添加进一步的操作，而无需修改它们。

维基说

> 在面向对象程序设计中，访问者设计模式时一种将算法和操作对象的结构分离的方法。这种分离的实际结果是能够在不修改这些对象结构的情况下向现有对象结构添加新操作。这是遵循开闭原则（Open Closed Principle）的一种方法。

**程序示例**

我们来模拟一所动物园，其中有几种不同的动物，我们必须赋予它们声音。下面用访问者模式来实现它。

```php
// Visitee
interface Animal
{
    public function accept(AnimalOperation $operation);
}

// Visitor
interface AnimalOperation
{
    public function visitMonkey(Monkey $monkey);
    public function visitLion(Lion $lion);
    public function visitDolphin(Dolphin $dolphin);
}
```

实现这些动物

```php
class Monkey implements Animal
{
    public function shout()
    {
        echo 'Ooh oo aa aa!';
    }

    public function accept(AnimalOperation $operation)
    {
        $operation->visitMonkey($this);
    }
}

class Lion implements Animal
{
    public function roar()
    {
        echo 'Roaaar!';
    }

    public function accept(AnimalOperation $operation)
    {
        $operation->visitLion($this);
    }
}

class Dolphin implements Animal
{
    public function speak()
    {
        echo 'Tuut tuttu tuutt!';
    }

    public function accept(AnimalOperation $operation)
    {
        $operation->visitDolphin($this);
    }
}
```

实现访问者

```php
class Speak implements AnimalOperation
{
    public function visitMonkey(Monkey $monkey)
    {
        $monkey->shout();
    }

    public function visitLion(Lion $lion)
    {
        $lion->roar();
    }

    public function visitDolphin(Dolphin $dolphin)
    {
        $dolphin->speak();
    }
}
```

这样用

```php
$monkey = new Monkey();
$lion = new Lion();
$dolphin = new Dolphin();

$speak = new Speak();

$monkey->accept($speak);    // Ooh oo aa aa!    
$lion->accept($speak);      // Roaaar!
$dolphin->accept($speak);   // Tuut tutt tuutt!
```

我们可以通过对动物具有继承层次结构来简单地做到这一点，但是每当我们必须向动物添加新动作时，就必须修改动物。但是现在我们不必更改它们。例如：假设我们被要求将跳跃行为添加到动物中，我们可以简单地通过创建一个新的访问者来添加它，即：

```php
class Jump implements AnimalOperation
{
    public function visitMonkey(Monkey $monkey)
    {
        echo 'Jumped 20 feet high! on to the tree!';
    }

    public function visitLion(Lion $lion)
    {
        echo 'Jumped 7 feet! Back on the ground!';
    }

    public function visitDolphin(Dolphin $dolphin)
    {
        echo 'Walked on water a little and disappeared';
    }
}
```

使用

```php
$jump = new Jump();

$monkey->accept($speak);   // Ooh oo aa aa!
$monkey->accept($jump);    // Jumped 20 feet high! on to the tree!

$lion->accept($speak);     // Roaaar!
$lion->accept($jump);      // Jumped 7 feet! Back on the ground!

$dolphin->accept($speak);  // Tuut tutt tuutt!
$dolphin->accept($jump);   // Walked on water a little and disappeared
```

### 💡 策略

现实例子

> 考虑一个排序的例子，我们实现了冒泡排序，但是随着数据的增长，冒泡排序越来越慢。为了解决这个问题，我们实现了快排。但是现在，尽管快速排序算法对大型数据集表现更好，但是对于较小数据集却很慢。为了解决这个问题，我们实现了一种策略，对于小型数据集，使用冒泡排序，而对于较大的使用快排。

简而言之

> 策略模式可以根据情况切换算法或策略。

维基说

> 在计算机编程中，策略（strategy）模式（也称为策略（policy）模式）是一种行为型模式，可以在运行时选择算法行为。

**程序示例**

首先对我们测策略接口做出不同实现。

```php
interface SortStrategy
{
    public function sort(array $dataset): array;
}

class BubbleSortStrategy implements SortStrategy
{
    public function sort(array $dataset): array
    {
        echo "Sorting using bubble sort";

        // Do sorting
        return $dataset;
    }
}

class QuickSortStrategy implements SortStrategy
{
    public function sort(array $dataset): array
    {
        echo "Sorting using quick sort";

        // Do sorting
        return $dataset;
    }
}
```

然后客户可以使用任意策略

```php
class Sorter
{
    protected $sorter;

    public function __construct(SortStrategy $sorter)
    {
        $this->sorter = $sorter;
    }

    public function sort(array $dataset): array
    {
        return $this->sorter->sort($dataset);
    }
}
```

用法

```php
$dataset = [1, 5, 4, 3, 2, 8];

$sorter = new Sorter(new BubbleSortStrategy());
$sorter->sort($dataset); // Output : Sorting using bubble sort

$sorter = new Sorter(new QuickSortStrategy());
$sorter->sort($dataset); // Output : Sorting using quick sort
```

### 💢 状态

实际例子

> 假设你正在使用某些绘图程序，绘画时选择画笔。现在，画笔将根据所选颜色更改其行为，即如果选择红色，它将绘制为红色，选择蓝色，则将绘制为蓝色等。

简而言之

> 当状态改变时，它允许你改变类的行为。

维基说

> 状态模式是一种行为软件设计模式，它以面向对象的方式实现状态机。使用状态模式，通过将每个单独的状态实现为状态模式接口的派生类，并通过调用模式的超类所定义的方法来实现状态转换。状态模式可以解释为策略模式，该模式能够通过调用模式接口中定义的方法来切换当前策略。

**程序示例**

再用文本编辑器的例子，它使你可以改变键入文本的状态，选择斜体，将以斜体显示；如果选择粗体，将以粗体显示。

首先是状态接口及其实现。

```php
interface WritingState
{
    public function write(string $words);
}

class UpperCase implements WritingState
{
    public function write(string $words)
    {
        echo strtoupper($words);
    }
}

class LowerCase implements WritingState
{
    public function write(string $words)
    {
        echo strtolower($words);
    }
}

class DefaultText implements WritingState
{
    public function write(string $words)
    {
        echo $words;
    }
}
```

接着是编辑器

```php
class TextEditor
{
    protected $state;

    public function __construct(WritingState $state)
    {
        $this->state = $state;
    }

    public function setState(WritingState $state)
    {
        $this->state = $state;
    }

    public function type(string $words)
    {
        $this->state->write($words);
    }
}
```

使用

```php
$editor = new TextEditor(new DefaultText());

$editor->type('First line');

$editor->setState(new UpperCase());

$editor->type('Second line');
$editor->type('Third line');

$editor->setState(new LowerCase());

$editor->type('Fourth line');
$editor->type('Fifth line');

// Output:
// First line
// SECOND LINE
// THIRD LINE
// fourth line
// fifth line
```

### 📒 模板方法

实际例子

> 假设我们要造房子，构建步骤可能如下：
> - 打地基
> - 砌墙
> - 加屋顶
> - 添加其他楼层
>
> 这些步骤的顺序是不会改变的，即你不可以在砌墙之前盖屋顶，但是每个步骤可以修改，例如墙壁可以由木头、聚酯或石头制成。

简而言之

> 模板方法定义了如何执行某种算法的框架，但是将这些步骤的实现交给字类。

维基说

> 软件工程领域，模板方法模式是一种行为型模式，用于定义操作中算法的程序框架，从而将某些步骤推迟到子类中。

**程序示例**

设想我们有一个构建工具可以帮助我们测试、整理、构建，生成报告（即覆盖率报告，lint 报告等）并且将我们的程序部署在测试服务器上。

首先，搭建基类，它指定构建算法的框架。

```php
abstract class Builder
{
    // Template method
    final public function build()
    {
        $this->test();
        $this->lint();
        $this->assemble();
        $this->deploy();
    }

    abstract public function test();
    abstract public function lint();
    abstract public function assemble();
    abstract public function deploy();
}
```

实现接口

```php
class AndroidBuilder extends Builder
{
    public function test()
    {
        echo 'Running android tests';
    }

    public function lint()
    {
        echo 'Linting the android code';
    }

    public function assemble()
    {
        echo 'Assembling the android build';
    }

    public function deploy()
    {
        echo 'Deploying android build to server';
    }
}

class IosBuilder extends Builder
{
    public function test()
    {
        echo 'Running ios tests';
    }

    public function lint()
    {
        echo 'Linting the ios code';
    }

    public function assemble()
    {
        echo 'Assembling the ios build';
    }

    public function deploy()
    {
        echo 'Deploying ios build to server';
    }
}
```

用法

```php
$androidBuilder = new AndroidBuilder();
$androidBuilder->build();

// Output:
// Running android tests
// Linting the android code
// Assembling the android build
// Deploying android build to server

$iosBuilder = new IosBuilder();
$iosBuilder->build();

// Output:
// Running ios tests
// Linting the ios code
// Assembling the ios build
// Deploying ios build to server
```

## 最后

到此为止。我将继续对此进行改进，你可以 watch/star 这个[仓库](https://github.com/kamranahmedse/developer-roadmap/)。之后计划编写有关架构模式的文章，敬请期待。
