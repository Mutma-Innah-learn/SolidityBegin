// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Chainlink Automation v1.x (v0.8 line).
// If your package is older, the path is:
//   @chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol
import {AutomationCompatibleInterface} from
    "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

contract TransactionMonitor is AutomationCompatibleInterface {


    enum TxStatus {
        PENDING, // 0 - reserved, unused in this demo
        SUCCESS, // 1
        FAILED   // 2
    }

    struct Transaction {
        address sender;
        address recipient;
        uint256 amount;    // ether
        uint64  timestamp; // block.timestamp at record time
        TxStatus status;
        bool    flagged;   // suspicious, decided at record time
    }

    struct Stats {
        uint256 totalTx;    // everything monitored inside the 24h window
        uint256 successTx;
        uint256 failedTx;
        uint256 flaggedTx;
        uint256 totalValue; // wei moved by SUCCESSFUL txs in the window
        uint64  lastUpdated;
    }

   
    // Storage

    Transaction[] private _transactions;

    /// @notice Live aggregates consumed by the dashboard.
    Stats public stats;

    address public owner;

    // @notice Transfers >= this value (wei) are flagged at record time.
    uint256 public flagThreshold = 0.1 ether;

    // @notice Recipients on this list are flagged on sight.
    mapping(address => bool) public watchlist;

    // @notice Rolling window length.
    uint256 public constant WINDOW = 24 hours;

    // @notice Minimum spacing between analysis runs.
    uint256 public constant INTERVAL = 30 seconds;

    // @notice Timestamp of the last analysis run (seeded in the constructor).
    uint64 public lastUpkeep;

    // @dev Index of the oldest transaction currently counted inside `stats`.
    uint256 private _cursorOld;

    // @dev Index of the next transaction that has NOT yet been counted.
    uint256 private _cursorNew;


    // Events

    event TransactionRecorded(
        uint256 indexed id,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        TxStatus status,
        bool flagged
    );

    // Emitted every 30s by the Automation run. The dashboard can
    //        either poll `getStats()` or subscribe to this.
    event StatsUpdated(
        uint256 totalTx,
        uint256 successTx,
        uint256 failedTx,
        uint256 flaggedTx,
        uint256 totalValue,
        uint256 timestamp
    );

    event FlagThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event WatchlistUpdated(address indexed account, bool flagged);

   
    // Modifiers
    

    modifier onlyOwner() {
        require(msg.sender == owner, "TransactionMonitor: not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        lastUpkeep = uint64(block.timestamp);
    }


    // Recording transactions

    /*
    Record a successful transfer.
    Note: Send the value with the call: `recordTransaction(recipient, {value: 1e15})`.
   The ETH stays in the contract; `withdraw()` lets the owner pull it out. */

    function _store(
        address sender,
        address recipient,
        uint256 amount,
        TxStatus status
    ) private {
        // Suspicion rules (record-time, deterministic, cheap).
        bool flagged = amount >= flagThreshold || watchlist[recipient];

        _transactions.push(
            Transaction({
                sender: sender,
                recipient: recipient,
                amount: amount,
                timestamp: uint64(block.timestamp),
                status: status,
                flagged: flagged
            })
        );

        _add(_transactions[_transactions.length - 1]);
        _cursorNew = _transactions.length;
        stats.lastUpdated = uint64(block.timestamp);

        emit TransactionRecorded(
            _transactions.length - 1,
            sender,
            recipient,
            amount,
            status,
            flagged
        );
    }
    function recordTransaction(address recipient) external payable {
        require(recipient != address(0), "TransactionMonitor: bad recipient");
        require(recipient != msg.sender, "TransactionMonitor: self transfer");
        require(msg.value > 0, "TransactionMonitor: zero value");


        _store(msg.sender, recipient, msg.value, TxStatus.SUCCESS);
        if(msg.value > flagThreshold) {
            stats.flaggedTx++;
        } else {stats.successTx++;
}

     stats.totalTx++;
     stats.totalValue += msg.value;
    }

    function recordFailedTransfer(address recipient) public payable {
        require(recipient != address(0), "TransactionMonitor: bad recipient");
        require(recipient != msg.sender, "TransactionMonitor: self transfer");

        _store(msg.sender, recipient, msg.value, TxStatus.FAILED);
        stats.failedTx;
    }


    
    // Chainlink Automation
    // Returns true once 30 seconds have elapsed since the last run.

    function checkUpkeep(bytes calldata)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = (block.timestamp - lastUpkeep) >= INTERVAL;
        performData = "";
    }

    //Called on-chain by the Automation network when checkUpkeep is true.
    function performUpkeep(bytes calldata) external override {
        require(
            block.timestamp - lastUpkeep >= INTERVAL,
            "TransactionMonitor: too soon"
        );
        lastUpkeep = uint64(block.timestamp);
        _analyze();
    }

    // Manual trigger for local testing / before Automation is funded.
   
    function analyzeNow() external onlyOwner {
        lastUpkeep = uint64(block.timestamp);
        _analyze();
    }

   
    function _analyze() internal {
        uint256 cutoff = block.timestamp > WINDOW
            ? block.timestamp - WINDOW
            : 0;

        uint256 len = _transactions.length;

        //1. expire 
        uint256 i = _cursorOld;
        while (i < _cursorNew && _transactions[i].timestamp < cutoff) {
            _remove(_transactions[i]);
            unchecked { ++i; }
        }
        _cursorOld = i;

        //2. ingest 
        uint256 j = _cursorNew;
        while (j < len) {
            _add(_transactions[j]);
            unchecked { ++j; }
        }
        _cursorNew = j;

        stats.lastUpdated = uint64(block.timestamp);

        emit StatsUpdated(
            stats.totalTx,
            stats.successTx,
            stats.failedTx,
            stats.flaggedTx,
            stats.totalValue,
            block.timestamp
        );
    }

    function _add(Transaction storage t) private {
        Stats storage s = stats;

        s.totalTx += 1;

        if (t.status == TxStatus.SUCCESS) {
            s.successTx += 1;
            s.totalValue += t.amount;
        } else if (t.status == TxStatus.FAILED) {
            s.failedTx += 1;
        }

        if (t.flagged) {
            s.flaggedTx += 1;
        }
    }

    function _remove(Transaction storage t) private {
        Stats storage s = stats;

        // Guards are defensive only; cursors should keep these in sync.
        if (s.totalTx > 0) s.totalTx -= 1;

        if (t.status == TxStatus.SUCCESS) {
            if (s.successTx > 0) s.successTx -= 1;
            if (s.totalValue >= t.amount) s.totalValue -= t.amount;
        } else if (t.status == TxStatus.FAILED) {
            if (s.failedTx > 0) s.failedTx -= 1;
        }

        if (t.flagged && s.flaggedTx > 0) {
            s.flaggedTx -= 1;
        }
    }

    // Views for the dashboard
   

    //notice Single call that fills the whole dashboard header.
    function getStats()
        external
        view
        returns (
            uint256 totalTx,
            uint256 successTx,
            uint256 failedTx,
            uint256 flaggedTx,
            uint256 totalValue,
            uint64  lastUpdated
        )
    {
        Stats memory s = stats;
        return (
            s.totalTx,
            s.successTx,
            s.failedTx,
            s.flaggedTx,
            s.totalValue,
            s.lastUpdated
        );
    }

    function transactionCount() external view returns (uint256) {
        return _transactions.length;
    }

    function getTransaction(uint256 id)
        external
        view
        returns (Transaction memory)
    {
        require(id < _transactions.length, "TransactionMonitor: bad id");
        return _transactions[id];
    }

    /// @notice Newest-first page, for the dashboard's recent-activity table.
    function getRecentTransactions(uint256 count)
        external
        view
        returns (Transaction[] memory page)
    {
        uint256 len = _transactions.length;
        if (count > len) count = len;

        page = new Transaction[](count);
        for (uint256 k = 0; k < count; ++k) {
            page[k] = _transactions[len - 1 - k];
        }
    }

   
    // Admin


    function setFlagThreshold(uint256 newThreshold) external onlyOwner {
        emit FlagThresholdUpdated(flagThreshold, newThreshold);
        flagThreshold = newThreshold;
    }

    function setWatchlist(address account, bool flagged) external onlyOwner {
        watchlist[account] = flagged;
        emit WatchlistUpdated(account, flagged);
    }

    function withdraw(address to) payable external onlyOwner {
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "TransactionMonitor: withdraw failed");
    }
}
