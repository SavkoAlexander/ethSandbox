// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error StakingFinished();

contract Staker {
    event Pay(address payer, uint256 amount);
    event Withdraw(address withdrawer, uint256 amount);

    mapping(address => uint256) private balances;

    address private owner;
    BronzeTier public bronzeTier;
    SilverTier public silverTier;
    GoldTier public goldTier;

    uint256 public goldTierAmount;
    uint256 public silverTierAmount;
    uint256 public bronzeTierAmount;
    uint256 public stakingFinishDate;
    bool public stakingFinished = false;
    bool public isFullAmountStaked = false;
    uint256 public amountStaked = 0;
    uint256 public amountGoal;

    ExampleExternalContract private exampleExternalContract;


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(
        uint256 _amountGoal,
        uint256 _bronzeTierAmount,
        uint256 _silverTierAmount,
        uint256 _goldTierAmount,
        uint _durationInDays
    ) {
        stakingFinishDate = block.timestamp + _durationInDays * 1 days;
        amountGoal = _amountGoal;
        bronzeTierAmount = _bronzeTierAmount;
        silverTierAmount = _silverTierAmount;
        goldTierAmount = _goldTierAmount;
        owner = msg.sender;
    }

    function pay() public payable {
        require(!stakingFinished && !isFullAmountStaked);
        if (block.timestamp > stakingFinishDate) {
            complete();
            revert StakingFinished();
        }
        balances[msg.sender] += msg.value;
        amountStaked += msg.value;
        emit Pay(msg.sender, msg.value);
    }

    function complete() internal {
        stakingFinished = true;
        isFullAmountStaked = (amountStaked > amountGoal ? true : false);
        if (isFullAmountStaked){
            (bool success, ) = address(exampleExternalContract).call{value: amountStaked}("");
            require(success);
        }
    }

    function withdraw() public {
        require(!isFullAmountStaked && !stakingFinished);
        require(balances[msg.sender] > 0);
        uint256 value = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: value}("");
        require(success);
        emit Withdraw(msg.sender, value);
    }

    function sendNft() public {
        require(isFullAmountStaked && stakingFinished);
        require(balances[msg.sender] > 0);
        if (balances[msg.sender] >= goldTierAmount){
            goldTier.mintNft(msg.sender);
        }
        else if (balances[msg.sender] >= silverTierAmount){
            silverTier.mintNft(msg.sender);
        }
        else if (balances[msg.sender] >= bronzeTierAmount){
            bronzeTier.mintNft(msg.sender);
        }
    }

    function getBalance(address staker) public view returns (uint256) {
        return balances[staker];
    }

}

contract BronzeTier is ERC721 {

    uint256 private tokenQuan;

    constructor() ERC721("Bronze NFT", "BNFT") {
        tokenQuan = 0;
    }

    function mintNft(address _staker) public {
        tokenQuan += 1;
        _safeMint(_staker, tokenQuan);
    }

    function getTokenQuan() public view returns (uint256) {
        return tokenQuan;
    }
}

contract SilverTier is ERC721 {
    uint256 private tokenQuan;

    constructor() ERC721("Silver NFT", "SNFT") {
        tokenQuan = 0;
    }

    function mintNft(address _staker) public {
        tokenQuan += 1;
        _safeMint(_staker, tokenQuan);
    }

    function getTokenQuan() public view returns (uint256) {
        return tokenQuan;
    }
}

contract GoldTier is ERC721 {
    uint256 private tokenQuan;

    constructor() ERC721("Gold NFT", "GNFT") {
        tokenQuan = 0;
    }

    function mintNft(address _staker) public {
        tokenQuan += 1;
        _safeMint(_staker, tokenQuan);
    }

    function getTokenQuan() public view returns (uint256) {
        return tokenQuan;
    }
}

contract ExampleExternalContract {

    receive() external payable {}

    fallback() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
