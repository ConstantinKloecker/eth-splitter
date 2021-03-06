pragma solidity ^0.5.0;

import {Toggled} from "./Toggled.sol";  // Toggled is Owned
import {SafeMath} from "./SafeMath.sol";

contract Splitter is Toggled {

    using SafeMath for uint256;

    mapping (address => uint) public balances;

    event LogEthSplitted(
        address indexed from,
        address indexed toUser1,
        address indexed toUser2,
        uint preSplitAmount
    );

    event LogWithdrawal(
        address indexed to,
        uint amount
    );

    constructor(bool status) public {
        if (!status) {
            pauseContract();
        }
    }

    function withdraw() public {
        uint amount = balances[msg.sender];
        require(amount > 0, "No balance available");
        balances[msg.sender] = 0;
        emit LogWithdrawal(msg.sender, amount);
        msg.sender.transfer(amount);
    }

    function splitEth(address toUser1, address toUser2) public payable isActive {
        require(toUser1 != address(0), "Address of 'toUser1' cannot be empty");
        require(toUser2 != address(0), "Address of 'toUser2' cannot be empty");
        require(msg.value != 0, "Message value cannot be 0");
        uint amount = msg.value / 2;
        uint remainder = msg.value % 2;
        balances[toUser1] = balances[toUser1].add(amount);
        balances[toUser2] = balances[toUser2].add(amount);
        if (remainder != 0) {
            balances[msg.sender] = balances[msg.sender].add(remainder);
        }
        emit LogEthSplitted(msg.sender, toUser1, toUser2, msg.value);
    }

    function() external {
        revert("Please use functions");
    }
}