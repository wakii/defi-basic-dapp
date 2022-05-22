// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 10 days;
  bool public openForWithdraw = false;
  bool public executed = false;
  bool public closed = false;

  event Stake(address sender, uint256 amount);

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier onlyOpen(bool isStillOpened) {
    uint256 _timeLeft = timeLeft();
    if (isStillOpened) {
      require(_timeLeft > 0, "Deadline is passed already");
    } else {
      require(_timeLeft <= 0, "It's still open");
    }
    _;
  }

  modifier notCompleted {
    bool isCompleted = exampleExternalContract.completed();
    require(!isCompleted, "It's completed");
    _;
  }

  function stake() public payable onlyOpen(true) {
    require(msg.value >= 0, "Staking amount should be grater than 0");
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);
  }

  function execute() public notCompleted {
    require(block.timestamp >= deadline, "Not yet");
    require(!executed, "Already Executed");
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
    executed = true;
  }

  function withdraw(address _toAddress) public onlyOpen(false) notCompleted {
    require(openForWithdraw, "Withdraw is not allowed");
    uint256 amount = balances[msg.sender];
    require(amount > 0, "User has no balance");
    balances[msg.sender] = 0;
    (bool success, ) = _toAddress.call{value:amount}("");
    require(success, "Transfer Failed");
  }

  function timeLeft() public view returns(uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  receive() external payable {
    stake();
  }

}
