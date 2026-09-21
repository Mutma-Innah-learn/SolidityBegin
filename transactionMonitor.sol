//SPDX-License-Identifier

pragma solidity ^0.8.0;

contract TxMonitor2 {

    event TransactionRecorded(address indexed sender, address indexed recipient, uint256 amount, bool flagged);
    event TransactionFlagged(address indexed sender, address indexed recipient, uint256 amount);

    struct Transaction {
        address sender;
        address recipient;
        uint256 amount;
        uint256 timestamp;
        bool flagged;
    }

    uint256 public totalTrans;
    uint256 public totalAmountTrans;
    uint256 public suspiciousThreshold = 30;
    uint256 public flaggedCount;
    uint256 public successfulCount;
    uint256 public minEth = 0;

    mapping(address => uint256) public balance;
    Transaction[] public transactions;

    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }

    function transaction(address _recipient) public payable{
        require(msg.value > minEth, "Invalid amount");
        require(msg.sender != _recipient, "Cannot send to yourself");
        require(balance[msg.sender] > msg.value, "Insufficient funds");

         //require(!isFlagged,"Suspicious");

         bool isFlagged = msg.value >= suspiciousThreshold;
        if(isFlagged) {
            flaggedCount++;
            emit TransactionFlagged(msg.sender, _recipient, msg.value);
        } else {
            successfulCount++;
        }

       
      (bool success,) = payable(_recipient).call{value: msg.value}("");
        require(success, "Transfer failed");

        balance[msg.sender] -= msg.value;
        balance[_recipient] += msg.value;
        
        totalTrans++;
        totalAmountTrans += msg.value;

        transactions.push(Transaction({
            sender: msg.sender,
            recipient: _recipient,
            amount: msg.value,
            timestamp: block.timestamp,
            flagged: !isFlagged
        }));

        emit TransactionRecorded(msg.sender, _recipient, msg.value,!isFlagged);
    }

    function getTransaction() public view returns (Transaction[] memory) {
        return transactions;
    }
}
