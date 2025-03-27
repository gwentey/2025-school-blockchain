// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ModifierExample {
    address public owner;
    uint public value;

    constructor() {
        owner = msg.sender;
    }

    // Modificateur pour vérifier que l'appelant est le propriétaire
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Fonction qui utilise le modificateur onlyOwner
    function setValue(uint _value) public onlyOwner {
        value = _value;
    }
}