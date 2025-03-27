// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventExample {
    event ValueChanged(address indexed changer, uint newValue);

    uint public value;

    function setValue(uint _value) public {
        value = _value;
        emit ValueChanged(msg.sender, _value);
    }
}