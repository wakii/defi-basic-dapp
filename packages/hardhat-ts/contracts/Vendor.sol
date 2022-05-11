pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';
import './YourToken.sol';

contract Vendor is Ownable {
  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfEth, uint256 amountOfTokens);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  function buyTokens() public payable returns (uint256 tokenAmount) {
    uint256 amountOfTokens = msg.value * tokensPerEth;

    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountOfTokens, 'Not enough Tokens anymore');
    bool result = yourToken.transfer(msg.sender, amountOfTokens);
    require(result, 'Transfer Failed');
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    return amountOfTokens;
  }

  function withdraw() public onlyOwner {
    (bool success, ) = msg.sender.call{value: address(this).balance}('');
    require(success, 'Withdraw Failed');
  }

  function sellTokens(uint256 theAmount) public {
    require(theAmount > 0, 'Amount should be grater than 0');

    uint256 sellerBalance = yourToken.balanceOf(msg.sender);
    require(sellerBalance >= theAmount, 'Seller should have more or equal than selling amounts');

    uint256 vendorEthBalance = address(this).balance;
    uint256 amountEthToBuyback = theAmount / tokensPerEth;
    require(vendorEthBalance >= amountEthToBuyback, "Vendor can't have less balance than buyback");

    bool sell_result = yourToken.transferFrom(msg.sender, address(this), theAmount);
    require(sell_result, "Selling Didn't go well");

    (bool buyback_result, ) = msg.sender.call{value: amountEthToBuyback}('');
    require(buyback_result, "Buyback Didn't go well");

    emit SellTokens(msg.sender, amountEthToBuyback, theAmount);
  }
}
