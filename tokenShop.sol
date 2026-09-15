//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Ownable} from "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import {myToken.sol} from "./myToken.sol";

contract TokenShop is Ownable{

    AggregatorV3Interface internal immutable i_pricefeed;
    myToken public immutable i_token;
    uint256 public constant TOKEN_DECIMALS = 18;
    uint256 public constant TOKEN_USD_PRICE = 2*10**TOKEN_DECIMALS;

    event BalanceWithdrawn();
    error TokenShop_ZeroETHSent();
    error TokenShop_CouldNotWithdraw();

  constructor(address tokenAddress) Ownable(msg.sender) {
   //msg.sender will be deploying the contract 
    i_token = myToken(tokenAddress);
    i_price_feed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
  } 

  function getChainlinkDataFeedLatestAnswer() public view returns(int){
    int price = i_priceFeed.latestRoundData();
    return price; 

  }
  function amountToMint(uint256 amountInETH) public view returns(uint256){
    uint256 ethUsd = uint256(getChainlinkDataFeedLatestAnswer())*10**10;
    uint256 ethAmountInUsed = amountInETH * ethUsd/10**18;
    return (ethAmountInUsd * 10**TOKEN_DECIMALS)/TOKEN_USD_PRICE;
  }
 
  recieve() external payable{ //fnc automatically executes when eth is sent
    if(msg.value == 0){
        revert TokenShop_ZeroETHSent();
    }
    i_token.mint(msg.sender,amountToMint(msg.value));
  }

  function withdraw() external onlyOwner{
    (bool success,) = payable(owner()).call{value: address(this).balance}("");
    if(!success){
        revert TokenShop_CouldNotWithdraw();
    }
    emit BalanceWithdrawn(); //triggers an event which logs data to the blockchain transaction reciept
  }

}
