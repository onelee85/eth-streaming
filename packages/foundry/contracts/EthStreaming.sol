//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { console2 } from "../lib/forge-std/src/console2.sol";

// Import the OpenZeppelin Ownable contract and inherit it in your contract definition
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract EthStreaming is Ownable {
    event AddStream(address recipient, uint256 cap);
    event Withdraw(address recipient, uint256 amount);

    uint256 public immutable unlockTime;

    struct Stream {
        uint256 cap;
        uint256 timeOfLastWithdrawal;
    }

    mapping(address => Stream) public streams;
    // 添加映射来跟踪已提取的金额
    mapping(address => uint256) public totalWithdrawn;

    constructor(uint256 _unlockTime) Ownable(msg.sender) {
        // Setting the state variable to the value received in the constructor
        unlockTime = _unlockTime;
    }
    //Anyone should be able to fund the contract with ETH just by sending a transaction with value to the contract address.

    /**
     * Create an addStream method that receives an address and a uint parameter representing the stream recipient and the amount of ETH that is the maximum amount their stream can unlock. Only the owner should be allowed to use this method. They should be able to call it to update recipients unlock amounts in the future in case they want to increase/decrease a stream.
     */
    function addStream(address _recipient, uint256 _amount) external onlyOwner {
        //if an address has a stream
        //require(streams[_recipient].cap == 0, "Stream already exists");
        //the maximum amount the address can withdraw
        require(_amount > 0, "Amount must be greater than 0");
        // Add the recipient and amount to the streams mapping
        streams[_recipient] = Stream(_amount, block.timestamp);
        // 更新已提取金额
        totalWithdrawn[_recipient] = 0;
        //Go ahead and add a new event called AddStream(address recipient, uint cap)
        emit AddStream(_recipient, _amount);
    }

    /**
     * Add a withdraw method that accepts a uint that represents the amount the stream recipient wishes to withdraw.
     */
    function withdraw(uint256 amount) external {
        // 确保流存在
        require(streams[msg.sender].cap > 0, "No stream exists");
        // 确保请求金额大于0
        require(amount > 0, "Amount must be greater than 0");
        // 确保请求金额不超过合约余额
        require(amount <= address(this).balance, "Amount exceeds contract balance");
        // 确保单次请求金额不超过cap值
        require(amount <= streams[msg.sender].cap, "Amount must be less than or equal to cap");

        // 计算从上次提取以来解锁的资金
        uint256 timeElapsed = block.timestamp - streams[msg.sender].timeOfLastWithdrawal;
        uint256 unlockedAmount;

        // 首次提取：允许提取全部金额
        if (timeElapsed == 0) {
            // 对于首次提取，确保我们不会提取超过cap的金额
            unlockedAmount = streams[msg.sender].cap - totalWithdrawn[msg.sender];
        } else {
            // 非首次提取：按照时间比例解锁
            unlockedAmount = (timeElapsed * streams[msg.sender].cap) / unlockTime;
        }

        // 可提取金额不能超过已解锁的金额，也不能超过合约余额
        uint256 amountToWithdraw = amount > unlockedAmount ? unlockedAmount : amount;
        amountToWithdraw = amountToWithdraw > address(this).balance ? address(this).balance : amountToWithdraw;

        require(amountToWithdraw > 0, "No funds available to withdraw");

        // 转移ETH给调用者
        payable(msg.sender).transfer(amountToWithdraw);

        // 更新stream状态
        streams[msg.sender].timeOfLastWithdrawal = block.timestamp;
        // 更新已提取金额
        totalWithdrawn[msg.sender] += amountToWithdraw;

        // emit an event called Withdraw(address recipient, uint amount)
        emit Withdraw(msg.sender, amountToWithdraw);
    }

    receive() external payable { }
}
