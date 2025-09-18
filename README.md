# EthStreaming

EthStreaming 是一个基于以太坊的智能合约，允许所有者为指定地址创建资金流，并让接收者在时间流逝中逐步提取资金。

## 功能特点

- **资金流管理**：所有者可以为任意地址设置资金流上限
- **时间解锁机制**：资金根据时间逐步解锁，接收者可以提取已解锁部分
- **灵活提取**：接收者可以随时提取已解锁的资金
- **ETH 直接转账**：任何人都可以通过向合约发送 ETH 来为资金流提供资金

## 合约方法

### `addStream(address _recipient, uint256 _amount)`

创建或更新指定接收者的资金流

- 仅所有者可以调用
- `_recipient`: 资金流接收者地址
- `_amount`: 资金流上限（以 wei 为单位）
- 触发 `AddStream` 事件

### `withdraw(uint256 amount)`

接收者提取已解锁的资金

- 仅资金流接收者可以调用
- `amount`: 请求提取的金额（以 wei 为单位）
- 触发 `Withdraw` 事件

### `receive()`

接收直接发送到合约的 ETH 转账

## 事件

### `AddStream(address recipient, uint256 cap)`

当所有者添加或更新资金流时触发

### `Withdraw(address recipient, uint256 amount)`

当接收者提取资金时触发

## 状态变量

### `unlockTime`

资金完全解锁所需的时间（不可变）

### `streams`

映射存储每个地址的资金流信息（上限和上次提取时间）

### `totalWithdrawn`

映射存储每个地址已提取的总金额

## 部署

部署时需要指定 `unlockTime` 参数，表示资金完全解锁所需的时间（以秒为单位）。

```solidity
constructor(uint256 _unlockTime) Ownable(msg.sender)
```

## 使用流程

1. 所者部署合约并设置解锁时间
2. 所有者调用 `addStream` 为接收者创建资金流
3. 任何人可以通过向合约发送 ETH 来提供资金
4. 接收者可以调用 `withdraw` 提取已解锁的资金

## 许可证

MIT License
