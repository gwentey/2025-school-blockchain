// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ErrorHandlingExample {
    uint public value;

    function setValue(uint _value) public {
        require(_value > 0, "Value must be greater than 0");
        value = _value;
    }

    function doubleValue(uint _value) public pure returns (uint) {
        assert(_value * 2 > _value); // Vérifie que le double est plus grand que la valeur originale
        return _value * 2;
    }

    function revertExample(uint _value) public pure {
        if (_value == 0) {
            revert("Value cannot be zero");
        }
    }
}