// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract MappingStudent{
    struct Student {
        uint studentId;
        string studentName;
    }

    // 0xaaaabbbbccccddddeeeeffffgggghhhhiiiijjjj -> (0, yuntian)
    mapping (address => Student) students; 
    address[] public studentAddresses;

    uint counter = 0;

    function register (address _studentAddress, string memory _name) public {
        address account = _studentAddress;
        students[account] = Student({
            studentId: counter, 
            studentName: _name
        });
        studentAddresses.push(_studentAddress);
        counter++;
    }

    function getStudentByAddress (address _studentAddress) public view returns (Student memory) {
        return students[_studentAddress];
    }

    function getStudentNameById (uint _studentId) public view returns (string memory) {
        for (uint i = 0; i < studentAddresses.length; i++) {
            if (students[studentAddresses[i]].studentId == _studentId) {
                return students[studentAddresses[i]].studentName;
            }
        }
        return "Student Not Found";
    }

    function getStudentList () public view returns (Student[] memory) {
        Student[] memory studentList = new Student[] (studentAddresses.length);

        for (uint i = 0; i < studentAddresses.length; i++) {
            studentList[i] = students[studentAddresses[i]];
        }
        return studentList;
    }
}