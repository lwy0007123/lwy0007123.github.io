---
title: LoRaWAN Backend Interfaces v1.0 学习 (p3)
date: 2019-07-16 14:01:27
categories: LoRaWAN
tags:
- LoRaWAN
---

接上一篇。

[原文档链接](https://lora-alliance.org/resource-hub/lorawantm-back-end-interfaces-v10)

本部分主要介绍漫游过程。

<!--more-->

## 11. 漫游过程

### 11.1 漫游类型

有两种 LoRa 漫游类型，名为被动漫游（Passive Roaming）和切换漫游（Handover Roaming）。被动漫游使终端设备能够受益于 NS 的 LoRaWAN 网络服务，处于两个网络的终端设备即使在重叠 RF 功能受限（即信道）范围内在另一个 NS 的控制下使用网关（Gateways）时也能工作。LoRa 会话和终端设备的 MAC 层控制由前 NS 维护，称为 sNS ，而往返于空中接口的帧由后 NS 处理，后者称为 fNS （转发 NS ）。对于给定的 LoRa 会话，只能有一个 sNS，而同一个会话可能涉及零个或多个 fNS 。

有两种类型的 fNS ：有状态和无状态。有状态 fNS 在终端设备的被动漫游开始时创建上下文（context），并利用该上下文来处理相同终端设备的任何后续上行链路/下行链路分组（subsequent）。无状态 fNS 不会创建任何上下文，因此最终必须彼此独立地处理任何上行链路/下行链路分组。假设某个超范围机制漫游伙伴知道给定的 fNS 是无状态还是有状态的。

即使在终端设备执行从一个 NS 到另一个 NS 的切换漫游之后， hNS 仍然使用 JS 和 AS 维护控制平面（control-plane）和数据平面（data-plane）。对于给定 LoRa 会话， hNS 保持不变，直到终端设备执行下一个入网过程。与 fNS 不同， sNS 具有控制终端设备 RF 设置的能力，这允许更灵活的漫游场景。

![Figure 6 Use of Handover and Passive Roaming](f6.png)

f6. 使用切换漫游和被动漫游

图 f6 所示，其中切换漫游和被动漫游同时用于 LoRa 会话。这个例子中，终端设备通过 NS1 激活， NS1 充当 hNS。随后，当 NS2 成为 sNS 时，漫游设备执行了从 NS1 到 NS2 的切换漫游，并且当 NS3 成为终端设备的 fNS 时，还从 NS2 到 NS3 进行被动漫游。

漫游激活是终端设备在 vNS 的覆盖范围内激活的能力。

本规范描述了下列漫游情况的过程：

- 正在进行的 LoRa 会话期间的被动漫游
- 正在进行的 LoRa 会话期间的切换漫游
- 基于 hNS 和 vNS 之间的切换漫游，漫游激活新的 LoRa 会话
- 基于 hNS 和 vNS 之间的被动漫游，漫游激活新的 LoRa 会话

当 hNS 和 vNS 没有任何漫游协议时激活新的 LoRa 会话超出了本规范的范围。这包含两种 NS 可能与第三个 NS 签订漫游协议的情况（例如， hNS 和第三个 NS 具有切换漫游协议，第三个 NS 和 vNS 具有被动漫游协议）。

### 11.2 漫游策略

每个网络运营商（network operator）都应该（SHALL）配置漫游策略，该漫游可以单独允许/禁止被动漫游、切换漫游、基于被动漫游的激活、基于其 NetID 识别的其他网络运营商的基于切换漫游的激活。对于被动漫游，策略还应该（SHALL）包括上行链路 MIC 检查是否由 fNS 完成。

每个网络运营商（network operator）都应该（SHALL）配置漫游策略，该漫游可以允许/禁止被动漫游、切换漫游、基于被动漫游的激活、基于其 DevEUI 识别的单独终端设备的基于切换漫游的激活。

### 11.3 被动漫游

此过程适用于 R1.0 [LW10, LW102] 和 R1.1 [LW11] 终端设备和网络。

#### 11.3.1 被动漫游开始

图 f7 所示针对终端设备的正在进行的 LoRa 会话的两个 NS 之间的被动漫游过程的消息流。有关基于被动漫游的新 LoRa 会话的激活，请参阅第 12.2 节。

![Figure 7 Passive Roaming start](f7.png)

f7. 被动漫游开始

步骤 0：

终端设备已通过 NS1 激活。

步骤 1：

当终端设备发送一个数据包，它由 NS2 接收， NS2 与终端设备没有任何上下文关联。

步骤 2：

如果 NS2 被其他网络运营商启用了被动漫游，那么 NS2 应该（SHALL）将接收数据包中的 NwkID 映射到具有被动漫游协议的运营商 NetID。如果未查到， NS2 应该（SHALL）忽略这个数据包，程序终止于此。

步骤 3：

如果查到了一个或多个 NetID ，然后如果 NS2 没有通过 out-of-band 机制配置 NS 的 IP 地址/主机名， 它就应该（SHALL）使用 DNS 去查找（见第 19 章）每一个匹配上 NetID 的 NS 的 IP 地址（比如，NS1 处于这种情形）。如果有不止一个匹配项，那么对每一个匹配的 NS 执行步骤 4-6 。

步骤 4：

NS2 应该发送 PRStartReq 消息到 NS1 ，携带收到数据包的 PHYPayload 以及关联的 ULMetadata 。元数据（metadata）的详情见第 16 章。

步骤 5：

NS1 应该（SHALL）检查它是否与收到的 NetID 标识的网络运营商签有被动漫游协议。如果未找到协议，要决定返回携带 Result=NoRoamingAgreement 的 PRStartAns 。

NS1 应该（SHALL）从 PHYPayload 中提取终端设备的 DevAddr ，识别相应的网络会话完整性密钥（R1.1 中为 FNwkSIntKey，在 R1.0/R1.0.2 中为 NwkSKey），并验证 PHYPayload 中的 MIC 。如果未找到密钥或 MIC 验证失败，则 NS1 应决定返回携带 Result=MICFailed 的 PRStartAns 。

步骤 6：

如果识别出的终端设备配置为使用被动漫游并且 NS1 决定通过 NS2 启用被动漫游，则 NS1 应（SHALL）向 NS2 发送携带 Result=Success 以及与被动漫游相关联的生命周期的 PRStartAns。如果 NS2 要作为有状态 fNS 运行，则 NS1 还应（SHALL）包括 DevEUI 和 ServiceProfile 。如果是 NS1-NS2 的被动漫游协议要求 NS2 对上行数据包进行 MIC 检查，则 PRStartAns 消息中还要有的 FCntUp 和 FNwkSIntKey （R1.1 的情况下） 或 NwkSKey （在 R1.0/1.02 的情况下）。

如果 NS1 此时不希望通过 NS2 启用被动漫游，那么它应该（SHALL）将携带 Result=Deferred 和 Lifetime 的 PRStartAns 发送到 NS2 。在收到此消息时， NS2 在生命周期内不应（SHALL not）再向同一终端设备的 NS1 发送 PRStartReq 。

如果步骤 5 失败了，接着 NS1 应该（SHALL）发送带有标识结果的 PRStartAns 给 NS2 。

NS1 可以同时从多个 NS 接收 PRStartReq ，并决定使用零个或多个 NS 来启用被动漫游。

在相关生命周期到期之后， NS1 和 NS2 应自行终止被动漫游（即，不涉及彼此的额外信令），除非在到期之前使用新一轮 PRStartReq/PRStartAns 扩展被动漫游。对于无状态 fNS 操作， NS1 应（SHALL）将与被动漫游关联的 Lifetime 设置为零。

步骤 7：

一旦收到成功的 PRStartAns ，NS2 就会成为该终端设备 LoRa 会话中的一个 fNS 。NS1 继续作为 sNS 服务。

在此之后， NS2 应该（SHALL）将从终端设备接收的数据包转发给 NS1 ， NS1 应（SHALL）接收来自 NS2 的此类数据包。此外， NS1 应（SHALL）记录 NS2 作为用于将数据包发送到终端设备的候选 fNS 。 NS2 应（SHALL）接受 NS1 发送的数据包，通过其中一个网关转发到终端设备。

#### 11.3.2 数据包传输

TODO...

### 11.3.3 被动漫游停止

### 11.4 切换漫游

#### 11.4.1 切换漫游开始

#### 11.4.2 数据包传输

#### 11.4.3 切换漫游停止

#### 11.4.4 hNS 重获控制权
