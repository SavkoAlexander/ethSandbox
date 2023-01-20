pragma solidity ^0.8.7;

contract Notary{

    uint256[] private proovedValues;

    function notarize(string calldata _valueToProof) public {
        uint256[] storage values = proovedValues;
        values.push(uint256(keccak256(abi.encodePacked(_valueToProof))));
        
    }

    function proofFor(string calldata _valueToProof) public view returns(uint){
        return uint256(keccak256(abi.encodePacked(_valueToProof)));
    }
}
