---
title: Protocal Buffer 学习 (语言指南)
date: 2018-02-23 17:45:00
categories: Protocol
tags: 
- Protocol Buffer
---

## 官方指南

[Language Guide (proto3)](https://developers.google.com/protocol-buffers/docs/proto3#simple)

## 简介

该文章为阅读官方指南顺便翻译的。

<!--more-->

## 定义消息类型

看一个简单的例子。假如你想定义一个搜索请求信息格式，搜索请求有个询问字符串。你感兴趣的特定页面的结果，以及每个结果页面的条目数。下面是 `.proto` 文件。

```protobuf
syntax = "proto3"

message SearchRequest {
    string query = 1;
    int32 page_number = 2;
    int32 result_per_page = 3;
}
```

* 第一行指定了你使用 proto3 语法：如果你不这样做，protocal buffer 编译器将默认假设你使用 proto2 。这句必须在文件的第一非空无注释行。
* `SearchRequest`信息定义指定了三个字段(名/值 对)，一个用于你希望包含在此类消息中的每条数据。每个字段有一个名称和一个类型。

### 指定字段类型

在上面的例子中，所有的字段都是 scalar (标量)类型：两个整数(`page_number`和`result_per_page`)和一个字符串(`query`)。当然，你也可以为你的字段指定 composite (复合)类型。

### 分配标签

如你所见，信息定义中的每个字段有一个独特的数字标签。这些标签被用来在二进制信息格式中识别你的字段，并且一旦你的信息类型在使用就不该修改这些字段。请注意，值为1到15的变量需要1字节编码，包括标签号和字段类型(你可以在 Protocal Buffer Encoding 中了解更多信息)。标签在16到2047之间需要2字节。所以你应该为频繁出现的消息元素保留标签1至15。请留意为将来可能添加的频繁出现的元素留出一些空间。
最小标签号码你可以指定为1，最大的为$2^{29}-1$，或536,870,911。你还不能使用数组19000至19999(`FieldDescriptor::kFirstReservedNumber`至`FieldDescriptor::kLastReservedNumber`)。因为它们是为 Protocal Bufffers 接口实现保留的，如果你在`.proto`文件中使用这些保留数字，protocal buffer 编译器会发出警告。同样的，你不能使用任何以前保留的标签。

### 指定字段规则

信息字段可以是下列中一种：

* `singular` ：一种格式正确的消息可以有0或1个这个字段(但不超过1个)。
* `repeated` ：这个字段可以在格式正确的消息中被重复任意次。重复值的顺序会被保留。

在 proto3 中， `repeated` 的 scalar 数字类型默认使用 `packed` 编码。
你可以在 Protocal Buffer Encoding 中了解有关 `packed` 的信息。

### 添加更多信息类型

单个`.proto`文件中可以定义多种信息类型。这便于你定义多种相关的信息。因此，举个例子，如果你想的定义回复信息格式来相应你的`SearchResponse`信息类型，你可以添加它到同一`.proto`文件：

```protobuf
message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
}

message SearchResponse {
 ...
}
```

### 添加注释

欲添加注释到你的`.proto`文件，使用C/C++样式的`//`和`/* ... */`语法。

```protobuf
/* SearchRequest represents a search query, with pagination options to
 * indicate which results to include in the response. */

message SearchRequest {
  string query = 1;
  int32 page_number = 2;  // Which page number do we want?
  int32 result_per_page = 3;  // Number of results to return per page.
}
```

### 保留字段

如果你通过删除整个字段或者将它注释掉来更新一种消息类型，未来的用户可以在更新类型时重用该标签号码。如果他们稍后加载同样的`.proto`旧版本，可能会导致严重的问题，包括数据损坏，隐私错误，诸如此类。确保这种情况不会发生的一种方法是指定已删除字段的字段标记(和/或者名称)被保留(这可能会导致JSON序列化问题)。如果将来的任何用户试图使用这些标识符，protocal buffer 编译器将报错。

```protobuf
message Foo {
  reserved 2, 15, 9 to 11;
  reserved "foo", "bar";
}
```

请注意，你不能在同一`reserved`语句中混合字段名称和标签号码。

### 你的`.proto`可以生成什么？

当你在protocal buffer 编译器中运行一个`.proto`，编译器会生成你需要的语言的代码，包括getting和setting字段的值，序列化你的信息到输出流，从输入流解析你的信息。

* 对于**C++**，编译器为每个`.proto`生成一个`.h`和`.cc`文件，每个信息类型用一个类定义。
* 对于**Java**，编译器会为每个消息来行生成一个带有类的`.java`文件，以及用于创建消息类实力的特殊`Builder`类。
* **Python**有一些不同——Python编译器会在`.proto`中为每个消息类型生成一个静态描述符，然后与`metaclass`一起使用，以在运行时创建必要的Python数据访问类。
* 对于**Go**，编译器为每种消息类型生成一个`.pb.go`文件。
* 对于**Ruby**，编译器使用包含消息类型的Ruby模块生成一个`.rb`文件。
* 对于**JavaNano**，编译器输出与Java相似，但没有`Builder`类。
* 对于**Object-C**，编译器会从每个`.proto`生成一个`pbobjc.h`和`pbobjc.m`文件，并为你的文件中描述的每种消息类型生成一个类。
* 对于**C#**，编译器会从每个`.proto`生成一个`.cs`文件，并为你的文件中描述的每种消息类型生成一个类。

你可以按照所选语言的教程(即将推出proto3版本)了解更多关于使用每种语言的API的信息。有关更多API的详细信息，请参阅相关[API参考](https://developers.google.com/protocol-buffers/docs/reference/overview)(即将推出proto3版本)。

## Scalar 值类型

标量消息字段可以具有以下类型之一——该表显示.proto文件中指定的类型以及自动生成的类中的相应类型：

.proto Type|Notes|C++ Type|Java Type|Python Type<sup>[2]</sup>|Go Type|Ruby Type|C# Type|PHP Type
---|---|---|---|---|---|---|---|---
double||double|double|float|float64|Float|double|float
float||float|float|float|float32|Float|float|float
int32|使用可变长度编码。负数是无效编码——如果你的字段可能含有负数，请改用sint32|int32|int|int|int32|Fixnum or Bignum (as required)|int|integer
int64|使用可变长度编码。负数是无效编码——如果你的字段可能具有负值，请改用sint64。|int64|long|int/long<sup>[3]</sup>|int64|Bignum|long|integer/string<sup>[5]</sup>
uint32|使用可变长度编码。|uint32|int<sup>[1]</sup>|int/long<sup>[3]</sup>|uint32|Fixnum or Bignum (as required)|uint|integer
uint64|使用可变长度编码。|uint64|long<sup>[1]</sup>|int/long<sup>[3]</sup>|uint64|Bignum|ulong|integer/string<sup>[5]</sup>
sint32|使用可变长度编码。带符号的int值。这些比常规的int32更有效地编码负数。|int32|int|int|int32|Fixnum or Bignum (as required)|int|integer
sint64|使用可变长度编码。带符号的int值。这些比常规的int64更有效地编码负数。|int64|long|int/long<sup>[3]</sup>|int64|Bignum|long|integer/string<sup>[5]</sup>
fixed32|总是四个字节。如果值通常大于$2^{28}$，则比uint32效率更高。|uint32|int<sup>[1]</sup>|int|uint32|Fixnum or Bignum (as required)|uint|integer
fixed64|总是八个字节。如果值通常大于$2^{56}$，则会比uint64更高效。|uint64|long<sup>[1]</sup>|int/long<sup>[3]</sup>|uint64|Bignum|ulong|integer/string<sup>[5]</sup>
sfixed32|总是四个字节。|int32|int|int|int32|Fixnum or Bignum (as required)|int|integer
sfixed64|总是八个字节。|int64|long|int/long<sup>[3]</sup>|int64|Bignum|long|integer/string<sup>[5]</sup>
bool||bool|boolean|bool|bool|TrueClass/FalseClass|bool|boolean
string|字符串必须始终包含UTF-8编码或7位ASCII文本。|string|String|str/unicode<sup>[4]</sup>|string|String (UTF-8)|string|string
bytes|可能包含任何字节序列。|string|ByteString|str|[]byte|String (ASCII-8BIT)|ByteString|string

你可以在 Protocal Buffer Encoding 中了解有关这些类型序列化消息如何编码的更多信息。

<sup>[1]</sup> 在Java中，无符号的32位和64位整数使用其签名对应表示，最高位仅存储在符号位中。

<sup>[2]</sup> 在所有情况下，将值设置为字段将执行类型检查以确保其有效。

<sup>[3]</sup> 64位或无符号32位整数在解码时总是表示为long，但如果在设置字段时给定整型，则可以是int。在所有情况下，该值必须符合设置时表示的类型。见<sup>[2]</sup>。

<sup>[4]</sup> Python字符串在解码时表示为unicode，但如果给出ASCII字符串(可能会更改)，则可以为str。

<sup>[5]</sup> Integer用于64位机器，字符串用于32位机器。

## 默认值

当一条消息被解析，如果编码的信息不包含特定的 singular 元素，则解析对象中的对应字段将设置为该字段的默认值。这些默认值是特定于类型的：

* 对于 string 类型，默认值为空字符串。
* 对于 byte 类型，默认值是空字节。
* 对于 bool 类型，默认值是 false 。
* 对于 numeric(数字) 类型，默认值是0。
* 对于 enums 类型，默认值是第一个定义的枚举值，一定为0。
* 对于消息字段，该字段未设置。它的确切值是语言相关的。详情请参阅生成的代码指南。

重复(repeated)字段的默认值为空(通常是相应语言的空列表)。

请注意，对于标量(scalar)消息字段，一旦解析了消息，就无法判断字段是否被显式设置为默认值(例如布尔值是否设置为`false`)或者根本没有设置：在定义消息类型时应该记住这一点。举个例子，如果你不希望该行为在默认情况下发生，请将其设置为`false`时切换某些行为的布尔值。另请注意，如果标量(scalar)消息字段被设置为其默认值，则该值不会在连线上序列化。有关如何在生成的代码中使用默认值的更多详细信息，请参阅所选语言的[生成代码指南](https://developers.google.com/protocol-buffers/docs/reference/overview)。

## 枚举

当你定义一个消息类型时，你可能希望它的一个字段只有一个预定义的值。例如，假设你想为每个`SearchRequest`添加一个`corpus`(语料库)字段，其中语料库可以是`UNIVERSAL`,`WEB`,`IMAGES`,`LOCAL`,`NEWS`,`PRRDUCTS`或`VIDEO`。你可以非常简单地通过为每个可能值添加一个常量来为消息定义添加枚举。
下面的示例中，我们添加一个名为`Corpus`的枚举，其中包含所有可能的值以及一个类型为`Corpus`的字段：

```protobuf
message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
  enum Corpus {
    UNIVERSAL = 0;
    WEB = 1;
    IMAGES = 2;
    LOCAL = 3;
    NEWS = 4;
    PRODUCTS = 5;
    VIDEO = 6;
  }
  Corpus corpus = 4;
}
```

如你所见，`Corpus`枚举的第一个常量映射为0：每个枚举定义都必须包含一个映射为0的常量作为第一个元素。这是因为：

* 必须有一个零值，以便我们可以使用0作为数字的默认值。
* 零值需要是第一个元素，与第一个枚举值始终是默认值的proto2语义兼容。

你可以通过将相同的值分配给不同的枚举常量来定义别名。为此，你需要将`allow_alias`选项设置为`true`，否则当找到别名时，协议编译器将生成错误消息。

```protobuf
enum EnumAllowingAlias {
  option allow_alias = true;
  UNKNOWN = 0;
  STARTED = 1;
  RUNNING = 1;
}
enum EnumNotAllowingAlias {
  UNKNOWN = 0;
  STARTED = 1;
  // RUNNING = 1;  // Uncommenting this line will cause a compile error inside Google and a warning message outside.
}
```

枚举器常量必须在32位整数的范围内。由于枚举值在线路上使用`varint`编码，所以负值效率不高，因此不推荐使用。你可以在消息定义中(如上例)或外部定义枚举——这些枚举可以在`.proto`文件中的任何消息定义中重用。你还可以使用语法`MessageType.EnumType`将一个消息中声明的枚举类型用作不同消息中字段的类型。

当你在使用`enum`的`.proto`文件上运行protocol buffer编译器，生成的代码将为Java或C++提供相应的枚举值，这是一种特殊的`EnumDescriptor`类，用于在运行时生成的类中创建一组具有整数值的符号常量。

在反序列化过程中，无法识别的枚举值将保留在消息中，但是当消息被反序列化时如何表示是依赖于语言的。在支持指定符号范围之外的值的开放枚举类型的语言(如C++和Go)中，未知枚举值仅作为其基础整数表示形式存储。在具有封闭枚举类型的语言(如Java)中，枚举中的一个用于表示无法识别的值，并且可以使用特殊访问器访问基础整数。在任何一种情况下，如果消息被序列化，则无法识别的值仍将与消息一起序列化。有关如何在应用程序中使用消息枚举的更多信息，请参阅所选语言的[生成代码指南](https://developers.google.com/protocol-buffers/docs/reference/overview)。

### 保留值

如果你通过完全删除枚举条目或将其注释掉来更新枚举类型，未来的用户可以在对该类型进行自己的更新时重新使用数值。如果稍后加载相同的`.proto`的旧版本，包括数据损坏，隐私错误等，则可能会导致严重问题。确保这种情况不会发生的一种方法指定已删除条目的数字值(和/或名称)被保留(这也可能会导致JSON序列化的问题)。如果将来的任何用户试图使用这些标识符，protocol buffer 编译器将会报错。你可以使用`max`关键字指定保留的数值范围上升到最大可能值。

```protobuf
enum Foo {
  reserved 2, 15, 9 to 11, 40 to max;
  reserved "FOO", "BAR";
}
```

请注意，你不能在同一`reserved`语句中混合字段名称和数字值。

### 使用其他消息类型

你可以使用其他消息类型作为字段类型。例如，假设你想在每个`SearchResponse`消息中包含`Result`消息——为此，你可以在同一个`.proto`中定义一个`Result`消息类型，然后在`SearchResponse`中指定`Result`类型的字段：

```protobuf
message SearchResponse {
  repeated Result results = 1;
}

message Result {
  string url = 1;
  string title = 2;
  repeated string snippets = 3;
}
```

### 导入定义

在之前的例子中，`Result`消息类型与`SearchResponse`定义在同一文件中——如果你要使用的消息类型已经在其他`.proto`文件中定义了呢？
你可以通过导入来使用其他`.proto`文件中的定义。要导入另一个`.proto`的定义，可以在文件顶部添加一条导入语句：

```protobuf
import "myproject/other_protos.proto";
```

默认情况下，你只能使用直接导入的`.proto`文件中的定义。但是，有时你可能需要将`.proto`文件移至新位置。不是直接移动`.proto`文件，而是在一次更改中更新所有调用站点，现在你可以在旧位置放置一个虚拟`.proto`文件，以使用`import public`概念将所有导入转移到新位置。`import public`依赖可以被过渡到任何包含`import public`语句的proto中。例如：

```protobuf
// new.proto
// All definitions are moved here
```

```protobuf
// old.proto
// This is the proto that all clients are importing.
import public "new.proto";
import "other.proto";
```

```protobuf
// client.proto
import "old.proto";
// You use definitions from old.proto and new.proto, but not other.proto
```

协议编译器使用`-I / --proto_path`标志在协议编译器命令行中指定一组目录中搜索导入的文件。
如果没有给标志，它将在调用编译器的目录中查找。通常，你应该将`--proto_path`标志设置为根目录，并为所有导入使用完整名称。

### 使用proto2消息类型

可以导入proto2消息类型并在proto3消息中使用它们，反之亦然。然而，proto2枚举不能直接用在proto3语法中(如果导入的proto2消息使用它们，这是可以的)。

## 嵌套类型

你可以在其他消息类型中定义和使用消息类型，如下例所示这里`ResultResponse`消息中定义了`Result`消息——这里`ResultResponse`消息中定义了`Result`消息：

```protobuf
message SearchResponse {
  message Result {
    string url = 1;
    string title = 2;
    repeated string snippets = 3;
  }
  repeated Result results = 1;
}
```

如果你想在其父消息类型外重复使用此消息类型，请将其称为`Parent.Type`：

```protobuf
message SomeOtherMessage {
  SearchResponse.Result result = 1;
}
```

你可以根据需要深度嵌套消息：

```protobuf
message Outer {                  // Level 0
  message MiddleAA {  // Level 1
    message Inner {   // Level 2
      int64 ival = 1;
      bool  booly = 2;
    }
  }
  message MiddleBB {  // Level 1
    message Inner {   // Level 2
      int32 ival = 1;
      bool  booly = 2;
    }
  }
}
```

## 更新消息类型

如果现有的消息类型不再满足你的所有需求——例如，你希望消息格式具有额外的字段——但你仍然希望使用使用旧格式创建的代码，别担心！在不破坏任何现有代码的情况下更新消息类型非常简单。请记住以下规则：

* 不要更改任何现有字段的数字标记。
* 如果你添加新字段，则任何由代码使用“旧”消息格式序列化的消息仍然可以通过新生成的代码解析。你应该记住这些元素的默认值，以便新代码可以正确地与旧代码生成的消息交互。同样的，由新代码创建的消息可以由旧代码解析：旧的二进制文件在解析时会简单地忽略新字段。有关详情，请参阅未知字段部分。
* 只有在更新的消息类型中不再使用标签号码，字段就可以被删除。你可能希望重命名该字段，可能会添加前缀“OBSOLETE_”，或者保留标记，以便将来的`.proto`用户不会意外重用该号码。
* `int32`,`uint32`,`int64`,`uint64`,和`bool`全都兼容——这意味着你可以将字段从这些类型之一更改为另一字段而不破坏向前或向后兼容性。如果一个数字从不适合相应类型的线路中解析出来，则会得到与在C++中将数字转换为该类型相同的效果(例如，如果将64位数字读为int32，它将被截断为32位)。
* `sint32`和`sint64`相互兼容，但与其他整数类型不兼容。
* 只要字节是有效的UTF-8，`string`和`bytes`是兼容的。
* 嵌入式消息与字节兼容，如果字节包含消息，如果字节包含消息的编码版本。
* `fixed32`与`sfixed32`兼容，而`fixed64`与`sfixed64`兼容
* `enum`与wire格式的`int32`，`uint32`，`int64`和`uint64`兼容(请注意，如果它们不适合，值将被截断)。但请注意，当消息被反序列化时，客户端代码可能会以不同的方式处理它们：例如，无法识别的proto3枚举类型将保留在消息中，但消息反序列化时如何表示是语言相关的。 Int域始终只保留它们的值。

## 未知字段 
未知字段是格式良好的 protocal buffer 序列化数据，表示解析器无法识别的字段。例如，当一个旧的二进制文件的解析被包含新字段的新二进制文件发送时，这些新的字段将成为旧的二进制文件中的未知字段。
Proto3可以成功解析未知字段的消息，但是，是否能保留这些未知字段就不确定了。你不应该以来保存或删除未知字段。对于大多数 Google protocol buffer的实现，未知字段在proto3中无法通过相应的 proto runtimes 访问，并且在反序列化时被丢弃或遗忘。这是 proto2 的不同行为吗，其中未知字段总是与消息一起保存并序列化。

## Any
`Any` 消息类型允许你将消息用作嵌入类型，而不必具有`.proto`定义。一个`Any`包含一个任意的序列化消息作为字节，以及一个充当全局唯一标识符并解析为该消息类型的URL。要使用`Any`类型，你需要导入`google/protobuf/any.proto`。

```protobuf
import "google/protobuf/any.proto";

message ErrorStatus {
  string message = 1;
  repeated google.protobuf.Any details = 2;
}
```

给定消息类型的默认的URL是`type.googleapis.com/packagename.messagename`
不同语言实现将支持runtime库帮助程序以类型安全的方式打包和解压缩Any的值——例如，在Java中，Any类型将具有特殊的`pack()`和`unpack()`访问器，而在C++中则有`PackForm()`和`UnpackTo()`方法：

```protobuf
// Storing an arbitrary message type in Any.
NetworkErrorDetails details = ...;
ErrorStatus status;
status.add_details()->PackFrom(details);

// Reading an arbitrary message from Any.
ErrorStatus status = ...;
for (const Any& detail : status.details()) {
  if (detail.Is<NetworkErrorDetails>()) {
    NetworkErrorDetails network_error;
    detail.UnpackTo(&network_error);
    ... processing network_error ...
  }
}
```

**当前用于处理Ang类型的的runtime库都在开发中**
如果你已经熟悉[proto2语法](https://developers.google.com/protocol-buffers/docs/proto)，则Any类型会替换[拓展名](https://developers.google.com/protocol-buffers/docs/proto#extensions)。

## Oneof

如果你有一个包含多个字段的消息，并且最多只能同时设置一个字段，则可以使用 oneof 功能强制执行此操作并节省内存。
Oneof字段与常规字段很相似，但共享中的所有字段除外，并且最多只能同时设置一个字段。设置 oneof 中的任何成员会自动清除所有其他成员。根据你选择的语言，你可以使用特殊的 `case()`或`WhichOneof()`方法检查oneof中的哪个值(如果有)被设置。

### 使用 Oneof

要在`.proto`中定义一个oneof关键字，请使用oneof关键字，后跟你的oneof名称，在此例中为`test_oneof`：

```protobuf
message SampleMessage {
  oneof test_oneof {
    string name = 4;
    SubMessage sub_message = 9;
  }
}
```

然后，将你的oneof字段添加到oneof定义中。你可以添加任意类型的字段，但不能使用`repeated`字段。
在你生成的代码中，oneof字段与常规字段具有相同的`getter`和`setter`。你还可以获得一种特殊的方法检查oneof中的哪个值(如果有)被设置。你可以在相关的[API参考](https://developers.google.com/protocol-buffers/docs/reference/overview)中找到更多关于你所选语言的API。

### Oneof 的特点

* 设置一个oneof字段将自动清除oneof中的其他成员。所以如果你设置了多个字段，则只有你设置的最后一个字段会有值。

```protobuf
SampleMessage message;
message.set_name("name");
CHECK(message.has_name());
message.mutable_sub_message();   // Will clear name field.
CHECK(!message.has_name());
```

* 如果解析器在线上遇到多个同一oneof中成员，则只有最后一个成员被用于解析的消息。
* 一个oneof不能是`repeated`。
* 反射API适用于oneof字段。
* 如果你使用C++，请确保你的代码不会导致内存崩溃。以下示例代码将因为调用`set_name()`方法删除了`sub_message`而崩溃。

```protobuf
SampleMessage message;
SubMessage* sub_message = message.mutable_sub_message();
message.set_name("name");      // Will delete sub_message
sub_message->set_...            // Crashes here
```

* 还是C++，如果你`Swap()`两个带有oneof的消息，每个消息都会以另一个 oneof case 结尾：在下面的例子中，`msg1`将有一个`sub_message`，而`msg2`将有一个`name`。

```protobuf
SampleMessage msg1;
msg1.set_name("name");
SampleMessage msg2;
msg2.mutable_sub_message();
msg1.swap(&msg2);
CHECK(msg1.has_sub_message());
CHECK(msg2.has_name());
```

### 向后兼容性问题

添加或删除一个字段时请小心。如果检查一个返回值的值为`None`/`NOT_SET`，则可能意味着oneof的值没有被设置，或者被设置为不同版本的oneof字段。没有办法分辨这种差异，因为无法知道线路上的未知字段是否为oneof的成员。

### 标记重用问题

* **将字段移入或移出oneof字段**：在消息序列化和解析后，可能会丢失一些信息(某些字段将被清除)。
* **删除一个oneof字段再将其添加回来**：在消息序列化和解析后，这可能会清除你当前设置的oneof字段。
* **拆分或合并oneof**：这与移动常规字段具有相似的问题。

## Maps

如果你想创建一个关联映射(map)作为数据定义的一部分，protocol buffer提供了一个方便的快捷语法。

```protobuf
map<key_type, value_type> map_field = N;
```

其中`key_type`可以是任何整数或字符串类型(因此，除了浮点类型和字节外的任何标量类型)。请注意，枚举不是有效的`key_type`。`value_type`可以是除另一个map之外的任何类型。

因此，例如，如果你想创建一个项目映射，其中每个`Project`消息都与一个字符串相关联，则可以像这样定义它：

```protobuf
map<string, Project> projects = 3;
```

* Map 字段不能被 `repeated`。
* 线格式排序和映射迭代排序是不确定的，所以你不能依靠映射项目的特定顺序。
* 为`.proto`生成文本格式时，映射按键排序。数字键按数字排序。
* 从线路解析或合并时，如果有重复的映射键，则使用所看到的最后一个键。从文本格式解析映射时，如果有重复的键，解析可能会失败。
 
生成映射API目前可用于所有proto3支持的语言。你可以在相关的[API参考](https://developers.google.com/protocol-buffers/docs/reference/overview)中找到更多关于你所选语言的映射API的信息。

### 向后兼容性

映射语法等同于线路中的以下内容，因此不支持映射的 protocol buffer 接口实现仍然可以处理你的数据：

```protobuf
message MapFieldEntry {
  key_type key = 1;
  value_type value = 2;
}

repeated MapFieldEntry map_field = N;
```

## 包

你可以将可选`package`说明符添加到`.proto`文件，以防止协议消息类型之间的名称冲突。

```protobuf
package foo.bar;
message Open { ... }
```

你可以在定义消息类型的字段时使用包说明符：

```protobuf
message Foo {
  ...
  foo.bar.Open open = 1;
  ...
}
```

* 在C++中，生成的类被封装在C++命名空间中。例如，`Open`将位于命名空间`foo::bar`。
* 在Java中，除非你在`.proto`文件中明确提供了`option java_package`，否则该包将用作Java包。
* 在Python中，package指令被忽略，因为Python模块根据它们在文件系统中的位置进行组织。
* 在Go中，除非你在`.proto`文件中明确提供了`option go_package`，否则该软件包将用作Go软件包名称。
* 在Ruby中，生成的类将被封装在嵌套的Ruby命名空间中，并转换为所需的Ruby大写样式(首字母大写;如果第一个字符不是字母，则`PB_`被预置)。例如，`Open`将位于命名空间`Foo::Bar`中。
* 在JavaNano中，该包用作Java包，除非你在`.proto`文件中明确提供了一个`option java_package`。
* 在C＃中，除非你在`.proto`文件中明确提供了`option csharp_namespace`，否则在转换为PascalCase之后，该包将用作名称空间。例如，`Open`将位于名称空间`Foo.Bar`中。

### 包和名称解决方案

Protocol buffer 语言中的类型名称解析与C++类似：首先搜索最内层的范围，然后搜索最内层的内容，依此类推，每个包被认为是其父包的“内层”。开头的的'.' (例如`.foo.bar.Baz`)意味着从最外层的范围开始。
Protocol buffer 编译器通过解析导入的`.proto`文件来解析所有类型名称。每种语言的代码生成器都知道如何引用该语言中的每种类型，即使它具有不同的作用域规则。

## 定义服务

如果你想将消息类型用于RPC(Remote Procedure Call - 远程过程调用)系统，则可以在.proto文件中定义一个RPC服务接口，并且 protocol buffer 编译器将使用你选择的语言生成服务接口代码和存根。所以，例如，如果你想用一个带有你的`SearchRequest`并返回一个`SearchResponse`的方法来定义一个RPC服务，你可以在你的`.proto`文件中定义它，如下所示：

```protobuf
service SearchService {
  rpc Search (SearchRequest) returns (SearchResponse);
}
```

与 protocol buffer 一起使用的最直接的RPC系统是gRPC：由谷歌开发的语言无关和平台无关的开源RPC系统。gRPC特别适用于 protocol buffer ，并且可以使用特殊的 protocol buffer 编译器插件直接从.proto文件生成相关的RPC代码。
如果你不想使用gRPC，也可以在你自己的RPC接口实现中使用 protocol buffer 。你可以在[Proto2语言指南](https://developers.google.com/protocol-buffers/docs/proto#services)中找到更多关于此的信息。
还有一些正在进行的第三方项目为 Protocol Buffers 开发RPC实现。有关我们了解的项目的链接列表，请参阅[第三方附加组件wiki页面](https://github.com/google/protobuf/blob/master/docs/third_party.md)。

## JSON映射

Proto3支持JSON中的规范编码，使系统之间共享数据变得更加容易。编码在下表中按类型逐个描述。
如果JSON编码数据中缺少值或其值为空，则在解析为 protocol buffer 时，它将被解释为适当的默认值。如果一个字段在 protocol buffer 中具有默认值，默认情况下它将在JSON编码数据中省略以节省空间。实现可能提供选项以在JSON编码的输出中发送具有默认值的字段。

proto3 | JSON | JSON example | Notes
---|---|---|---
message | object | {"fBar": v, "g": null, …} | 生成JSON对象。消息字段名称映射到lowerCamelCase并成为JSON对象键。接受null并将其视为相应字段类型的默认值。
enum | string | "FOO_BAR" | 使用proto中指定的枚举值的名称。
map<K,V> | object | {"k": v, …} | 所有的密钥都转换为字符串。
repeated V | array | [v, …] | null被接受为空list[]
bool | true, false | true, false | 
string | string | "Hello World!" | 
bytes | base64 string | "YWJjMTIzIT8kKiYoKSctPUB+" | JSON值将是使用带填充的标准base64编码作为字符串编码的数据。无论是标准的还是URL安全的base64编码，都可以接受。
int32, fixed32, uint32 | number | 1, -10, 0 | JSON值将是一个十进制数。数字或字符串都被接受。
int64, fixed64, uint64 | string | "1", "-10" | JSON值将是一个十进制字符串。数字或字符串都被接受。
float, double | number | 1.1, -10.0, 0, "NaN", "Infinity" | JSON值将是一个数字或特殊字符串值“NaN”，“Infinity”和“-Infinity”之一。数字或字符串都被接受。指数符号也被接受。
Any | object | {"@type": "url", "f": v, … } | 如果Any包含具有特殊JSON映射的值，则它将按如下所示进行转换： {"@type": xxx, "value": yyy}。否则，该值将被转换为JSON对象，并且将插入“@type”字段以指示实际的数据类型。
Timestamp | string | "1972-01-01T10:00:20.021Z" | 使用RFC 3339，其中生成的输出始终是 Z-normalized ，并使用0,3,6或9小数位。
Duration | string | "1.000340012s", "1s" | 生成的输出总是包含0,3,6或9个小数位，具体取决于所需的精度，后面跟着后缀“s”。接受的是任何小数位（也没有），只要它们符合纳秒精度并且后缀“s”是必需的。
Struct | object | { … } | 任何JSON对象。请参见`struct.proto`。
Wrapper types | various types | 2, "2", "foo", true, "true", null, 0, … | 包装器在JSON中使用与包装的基本类型相同的表示形式，除了在数据转换和传输期间允许和保留null。
FieldMask | string | "f.fooBar,h" | 见 `fieldmask.proto`.
ListValue | array | [foo, bar, …] | 
Value | value |  | 任何JSON值
NullValue | null |  | JSON null

## 选项 (option)

`.proto`文件中的各个声明可以用多个*选项*批注。选项不会更改声明的整体含义，但可能会影响在特定上下文中处理它的方式。可用选项的完整列表在`google/protobuf/descriptor.proto`中定义。
有些选项是文件级选项，这意味着它们应该写在顶层作用域中，而不是任何消息，枚举或服务定义中。有些选项是消息级选项，意味着它们应该写在消息定义中。有些选项是字段级选项，这意味着它们应该写在字段定义中。选项也可以写在枚举类型，枚举值，服务类型和服务方法上;但是，目前没有任何有用的选项。

以下是一些最常用的选项：

* `java_package`(文件选项)：你要用于生成的Java类的包。如果在`.proto`文件中没有给出明确的`java_package`选项，那么默认情况下会使用proto包(在`.proto`文件中使用“package”关键字指定)。但是，proto软件包通常不会制作出良好的Java软件包，因为proto软件包不希望以反向域名开头。如果不生成Java代码，则此选项不起作用。

```protobuf
option java_package = "com.example.foo";
```

* `java_multiple_files`(文件选项)：导致在包级别定义顶级消息，枚举和服务，而不是在以`.proto`文件命名的外部类中定义。

```protobuf
option java_multiple_files = true;
```

* `java_outer_classname`(文件选项)：要生成的最外层Java类(因此文件名)的类名。如果没有在`.proto`文件中指定明确的`java_outer_classname`，则通过将`.proto`文件名称转换为驼峰命名(因此`foo_bar.proto`变为`FooBar.java`)来构造类名称。如果不生成Java代码，则此选项不起作用。

```protobuf
option java_outer_classname = "Ponycopter";
```

* `optimize_for`(文件选项)：可以设置为`SPEED`，`CODE_SIZE`或`LITE_RUNTIME`。这会通过以下方式影响C++和Java代码生成器(以及可能的第三方生成器)：
  * `SPEED`(默认)： protocol buffer 编译器将生成用于序列化，解析和执行消息类型的其他常见操作的代码。这段代码是高度优化的。
  * `CODE_SIZE`:  protocol buffer 编译器将生成最少的类，并依靠共享的基于反射的代码来实现序列化，解析和各种其他操作。生成的代码因此比`SPEED`要小得多，但操作会比较慢。类仍将实现与`SPEED`模式中完全相同的公共API。这种模式在包含大量`.proto`文件的应用程序中非常有用，并且不需要所有这些文件都变得非常快速。
  * `LITE_RUNTIME`: protocol buffer 编译器将生成仅取决于“lite”的runtime库(`libprotobuf-lite`而不是`libprotobuf`)的类。lite runtime比整个库小得多（大约小一个数量级），但省略了描述符和反射等特定功能。这对于在移动电话等受限平台上运行的应用程序特别有用。编译器仍然会像在`SPEED`模式下那样生成所有方法的快速实现。生成的类将仅实现每种语言的`MessageLite`接口，该接口仅提供完整的`Message`接口的一部分方法。

```protobuf
option optimize_for = CODE_SIZE;
```

* `cc_enable_arenas`（文件选项）：为C ++生成的代码启用竞技场分配。
* `objc_class_prefix`（文件选项）：设置所有Objective-C生成的类和来自此.proto的枚举的Objective-C类前缀。没有默认值。你应该使用[Apple建议](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Conventions/Conventions.html#//apple_ref/doc/uid/TP40011210-CH10-SW4)的3-5个大写字符之间的前缀。请注意，所有2个字母的前缀都由Apple保留。
* `deprecated`（字段选项）：如果设置为true，则表示该字段已被弃用且不应被新代码使用。在大多数语言中，这没有实际影响。在Java中，这变成了`@Deprecated`注释。将来，其他语言特定的代码生成器可能会在字段的访问器上生成弃用注释，这会在编译试图使用该字段的代码时反过来导致发出警告。如果该字段不被任何人使用，并且你想阻止新用户使用该字段，请考虑用保留语句替换字段声明。

```protobuf
int32 old_field = 6 [deprecated=true];
```

### 自定义选项

Protocol Buffers还允许你定义和使用你自己的选项。这是大多数人不需要的**高级功能**。如果你认为需要创建自己的选项，请参阅[Proto2语言指南](https://developers.google.com/protocol-buffers/docs/proto.html#customoptions)了解详细信息。请注意，创建自定义选项使用的扩展只允许proto3中的自定义选项。

## 生成你的类

要生成需要使用.proto文件中定义的消息类型的Java，Python，C ++，Go，Ruby，JavaNano，Objective-C或C＃代码，需要在.proto文件上运行 Protocol Buffers 编译器协议。如果你尚未安装编译器，请[下载软件包](https://developers.google.com/protocol-buffers/docs/downloads.html)并按照README中的说明进行操作。对于Go，你还需要为编译器安装特殊的代码生成器插件：你可以在GitHub上的[golang/protobuf](https://github.com/golang/protobuf/)存储库中找到此安装说明。
协议编译器调用如下：

```protobuf
protoc --proto_path=IMPORT_PATH --cpp_out=DST_DIR --java_out=DST_DIR --python_out=DST_DIR --go_out=DST_DIR --ruby_out=DST_DIR --javanano_out=DST_DIR --objc_out=DST_DIR --csharp_out=DST_DIR path/to/file.proto
```

* `IMPORT_PATH`指定解析`import`指令时要在其中查找`.proto`文件的目录。如果省略，则使用当前目录。可以通过多次传递`--proto_path`选项来指定多个导入目录;他们将按顺序搜索。`-I=IMPORT_PATH`可以用作`--proto_path`的简短形式。
* 你可以提供一个或多个输出指令：
  * `--cpp_out`在`DST_DIR`中生成C++代码。有关更多信息，请参阅[C++生成的代码参考](https://developers.google.com/protocol-buffers/docs/reference/cpp-generated)。
  * `--java_out`在`DST_DIR`中生成Java代码。查看[Java生成的代码参考](https://developers.google.com/protocol-buffers/docs/reference/java-generated)以获取更多信息。
  * `--python_out`在`DST_DIR`中生成Python代码。查看[Python生成的代码参考](https://developers.google.com/protocol-buffers/docs/reference/python-generated)以获取更多信息。
  * `--go_out`在`DST_DIR`中生成Go代码。查看[Go生成的代码参考](https://developers.google.com/protocol-buffers/docs/reference/go-generated)了解更多信息。
  * `--ruby_out`在`DST_DIR`中生成Ruby代码。 Ruby生成的代码引用即将推出！
  * `--javanano_out`在`DST_DIR`中生成JavaNano代码。JavaNano代码生成器有许多选项可用于自定义生成器输出：你可以在生成器[README](https://github.com/google/protobuf/tree/master/javanano)中找到更多关于这些的信息。 JavaNano生成的代码参考即将推出！
  * `--objc_out`在`DST_DIR`中生成Objective-C代码。有关更多信息，请参阅[Objective-C生成的代码参考](https://developers.google.com/protocol-buffers/docs/reference/objective-c-generated)。
  * `--csharp_out`在`DST_DIR`中生成C＃代码。有关更多信息，请参阅[C＃生成的代码参考](https://developers.google.com/protocol-buffers/docs/reference/csharp-generated)。
  * `--php_out`在`DST_DIR`中生成PHP代码。查看[PHP生成的代码参考](https://developers.google.com/protocol-buffers/docs/reference/php-generated)了解更多信息。
  
  为了方便起见，如果`DST_DIR`以`.zip`或`.jar`结尾，编译器会将输出写入一个具有给定名称的ZIP格式存档文件。根据Java JAR规范的要求，`.jar`输出也会被赋予一个清单文件。请注意，如果输出存档已经存在，它将被覆盖;编译器不够聪明，无法将文件添加到现有存档。

*  你必须提供一个或多个`.proto`文件作为输入。可以一次指定多个`.proto`文件。虽然这些文件是相对于当前目录命名的，但每个文件都必须驻留在其中一个`IMPORT_PATH`中，以便编译器可以确定其规范名称。

# 其他
## RPC framework
RPC (Remote Procedure Call - 远程过程调用) 

* [GRPC - Google](http://www.grpc.io/docs/)
* [Thrift - Apache](https://thrift.apache.org/)