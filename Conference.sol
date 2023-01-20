pragma solidity ^0.8.7;

contract Conference{

    address private owner;
    uint256 public price;
    uint256 private userLimit;
    uint256 private usersCurrent = 0;
    
    mapping (address => bool) public usersInConference;

    constructor(
        uint256 _price,
        uint256 _userLimit
    ){
        price = _price;
        userLimit = _userLimit;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function buyTicket() external payable{
        require(msg.value > price);
        require(usersCurrent < userLimit);
        usersInConference[msg.sender] = true;
        usersCurrent += 1;
    }

    function refund() external{
        require(usersInConference[msg.sender]);
        usersInConference[msg.sender] = false;
    }

    function refund(address userToRefund) internal onlyOwner{
        require(usersInConference[msg.sender]);
        usersInConference[msg.sender] = false;
    }
}
