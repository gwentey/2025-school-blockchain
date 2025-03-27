// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MathLibrairie {
    function addition(uint a, uint b) internal pure returns (uint) {
        return a + b;
    }

    function soustraction(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "Subtraction Impossible");
        return a - b;
    }
}

contract MathExample {
    using MathLibrairie for uint;

    function calculate(uint a, uint b) public pure returns (uint, uint) {
        return (a.addition(b), a.soustraction(b));
    }
}

