//SPDX-License-Identifier:MIT
pragma solidity ^0.8.34;

contract nihao{

    address public person;
    bool public paused;
    mapping(address => uint256) public balances;


    /*constructor is a special function executed only once when a smart contract is deployed,
    used to initialize state variables and set up contract parameters.*/
    constructor(){ 
        person = msg.sender;
        paused = false;
        balances[person] = 200000000;
    }
    
    /*modifier is a special function used to change or control the behavior of other functions,
    often enforcing conditions before or after execution.*/
    modifier onlyPerson(){
      require(msg.sender == person, "only Owner can perform this action");
      _;
    }

    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function pause() internal onlyPerson{
        paused = true;
    }

    function unpause() internal  onlyPerson{
        paused = false;
    }

function transfer(address to, uint256 amount) public notPaused{
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

 
}
