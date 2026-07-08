// SPDX-License-Identifier: MIT 

pragma solidity >=0.6.0 <0.9.0;

//import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract fundMe{

    mapping(address => uint256) public addressToAmountFund;
    address owner;
    address[] funders;


    constructor(){
      owner == msg.sender;
    }


    function fund() public payable {
      uint256 minimumUSD = 2000;
     require(getConversionRate(msg.value) >= minimumUSD, "Send more!");
      addressToAmountFund[msg.sender] += msg.value;
      funders.push(msg.sender);
    }

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();

    }

    function getPrice() public view returns(uint256) {
      AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      //Tuple is a list of object of potentially differnent types whose number is a constant at compile-time.
      (, 
      int256 answer,,,) =priceFeed.latestRoundData();
      return uint256(answer);
    }

    function getConversionRate(uint256 ethAmount)  public view  returns(uint256){
      uint256 ethPrice = getPrice();
      uint256 ethAmountUsd = (ethPrice * ethAmount);
      return ethAmountUsd;
    }

    modifier onlyOwner(){
      require(owner == msg.sender);
      _;
    }

    //whomever calls on withdraw, transfer them all our balance
    function withdraw() public payable onlyOwner { 
      /*//transfer is a function that we can call on any address to send eth from one address to another
       //transfering money to sender; this keyword refers to the contract youre already on */
     payable(msg.sender).transfer(address(this).balance);
     for(uint256 fundersIndex=0; fundersIndex <= funders.length; fundersIndex++){
      address funder = funders[fundersIndex];
      addressToAmountFund[funder] = 0;
     }

     funders = new address[](0);
    }

}
