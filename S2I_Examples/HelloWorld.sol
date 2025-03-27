// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract HelloWorld {
    string myName = "Eddy";

    function getName() public view returns (string memory) {
        return myName;
    }

    function changeName (string memory _newName) public {
        myName = _newName;
    }

    function pureTest (string memory _name) public pure returns (string memory) {
        return _name;
    }
}