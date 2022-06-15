// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract crowdFund{
    address payable public owner;
    mapping (address => uint) public contributors;
    uint public contribution;

    string public nameOfCrowdFund;
    string public purpose;
    uint public target;
    bool public targetReached;
    bool public started;
    bool public ended;
    uint public endTime;
    
    modifier onlyOwner(){
      require(msg.sender==owner, "access denied");
      _;
    }

    function start(address payable _owner, string memory _name, string memory _purpose, uint _target,
    uint _end) external{
       owner= _owner;
       nameOfCrowdFund= _name;
       purpose= _purpose;
       target = _target;
       targetReached= false;
       started = true;
       ended = false;
       endTime= block.timestamp + _end;

    }

    function contribute() payable public{
        require(msg.sender !=owner, "owner cannot contribute");
        require(block.timestamp < endTime, "contribution have ended");
        contributors[msg.sender]+= msg.value;
        contribution +=msg.value;

    }
    function endCrowdFunding() public onlyOwner{
        require(block.timestamp >=endTime, "contributions are still on");
        require(contribution >=target, "your target or more not reached");
        targetReached=true;
        owner.transfer(contribution);
         contribution=0;
    }
    
}
