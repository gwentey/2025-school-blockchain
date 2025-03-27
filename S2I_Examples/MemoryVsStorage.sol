// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract MemoryVSStorage {
 
   
    uint num1 = 1;
    uint[] nums;

    function add(uint num) public pure returns (uint) {
        num += 1;
        return num;
    }

    function push() public {
        uint[] storage array = nums;
        array.push(1);

    }

    function memoryTest(uint[] memory array) public pure returns (uint[] memory, uint[] memory) {
        uint[] memory newArray = array;
        newArray[0] = 100;
        return (array, newArray);
    }

    function storageTest() public returns (uint[] memory) {
        uint[] storage array = nums;
        array[0] = 100;
        return array;
    }
}