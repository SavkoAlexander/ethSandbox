pragma solidity >=0.7.0 <0.9.0;

contract UniversityApply{

    uint groupQuan = 10;
    

    struct Student {
        string name;
        uint age;
        uint group;
    }


    Student[] public students;

    function _applyStudent(string memory _name, uint _age) public {
        uint group = _generateRandomGroupNumber();
        students.push(Student(_name, _age, group));
    }


    function _generateRandomGroupNumber() private view returns (uint){
        uint rand = uint(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
        );
        return (rand % groupQuan) + 1;
    }

}
