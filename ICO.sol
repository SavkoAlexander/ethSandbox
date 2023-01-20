// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ICO{

    event Mint(address indexed to, uint256 amount);
    
    address private owner;
    
    string public constant name = "someToken";
    uint32 public constant decimals = 18;
    bool public isFinished = false;
    uint256 totalSupply = 0;

    uint256 public hardCap;
    uint256 public rate;
    uint256 public stakingFinishDate;


    mapping(address => uint256) private balances;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(
        uint256 _rate,
        uint256 _durationInDays,
        uint256 _hardCap
    ){
        rate = _rate;
        stakingFinishDate = block.timestamp + _durationInDays * 1 days;
        hardCap = _hardCap;
        owner = msg.sender;
    }
    
    function finishIco() external payable onlyOwner {
        isFinished = true;
        (bool sent, ) = owner.call{value: totalSupply}("");
        require(sent);
    }

    function mint(address sender, uint256 amount) private {
        totalSupply += amount;
        balances[sender] += amount;
        emit Mint(sender, amount);
    }
    
    function buyToken() external payable {
        require(totalSupply + ((msg.value * rate) / decimals) * 18 < hardCap);
        require(!isFinished);
        mint(msg.sender, ((msg.value * rate) / decimals) * 18);
    }
}
