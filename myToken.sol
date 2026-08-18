//SPDX-Liscense-Ientifier: MIT

pragma solidity ^0.8.34;

//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract myToken{

    mapping(address => uint256) balance;

    string tokenName = "MyToken";
    string tokenAbrv = "MTK";
    


   /* function mint() public payable{
        _mint(msg.sender, 10000000 * (10 ** 18)); 
    } */

    function balanceOf(address tkOwner) public view returns(uint256){
      return balance[tkOwner];
    }

    function tranfer(address recipient, uint256 amount) public payable{
        require(amount <= balance[msg.sender], "insufficient balance");
        balance[msg.sender] = balance[msg.sender] - amount;
        balance[recipient] = balance[recipient] + amount;
    }

    function transferFrom(address owner, address buyer, uint256 amount) public payable{
      require(amount <= balance[owner]);
      balance[owner] = balance[owner] - amount;
      balance[buyer] = balance[buyer] + amount;
    }


}
