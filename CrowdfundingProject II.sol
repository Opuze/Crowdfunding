// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract Crowdfunding{
    mapping(address => uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public numberOfContributors;


    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
        
    }

    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address _recipient, uint _value);

    mapping(uint => Request) public requests;

    uint public numRequests;

    constructor(uint _target, uint _deadline){
        target = _target* (1 ether);
        deadline= block.timestamp + _deadline;
        minimumContribution = 100 wei;
        manager = msg.sender;

    }

    function makeContribution() public payable{
        require(block.timestamp < deadline, "Deadline has passed");
        require(msg.value >= minimumContribution, "Minimum Contribution is not met");
        
        if(contributors[msg.sender] == 0){
            numberOfContributors++;
        }
        
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit ContributeEvent(msg.sender, msg.value);
    }

    receive () payable external{
        makeContribution();
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function refund() public{
        require(block.timestamp > deadline && raisedAmount < target, "You are not eligible");
        require(contributors[msg.sender]>0);
        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];
        recipient.transfer(value);

        contributors[msg.sender] = 0;
    }

        modifier onlyManager(){
            require(msg.sender == manager, "only manager can call this function");
            _;
        }
 // for the manager to withdraw the money
    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
        
        emit CreateRequestEvent(_description, _recipient, _value);
    }
    
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender] > 0, "You must be a contributor");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false, "You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount >= target);
        Request storage thisRequest= requests[_requestNo];
        require(thisRequest.completed== false, "The request has been completed");
        require(thisRequest.noOfVoters > numberOfContributors/2, "Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;

        emit MakePaymentEvent(thisRequest.recipient, thisRequest.value);
    }
}