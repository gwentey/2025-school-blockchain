// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contrat de base
contract Animal {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }

    function speak() public pure virtual returns (string memory) {
        return "Animal sound";
    }
}

// Contrat dérivé
contract Dog is Animal {
    constructor(string memory _name) Animal(_name) {}

    function speak() public pure override returns (string memory) {
        return "Woof!";
    }
}

// Contrat dérivé
contract Cat is Animal {
    constructor(string memory _name) Animal(_name) {}

    function speak() public pure override returns (string memory) {
        return "Meow!";
    }
}