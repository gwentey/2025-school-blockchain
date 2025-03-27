// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Manufacture {
    struct Medicament {
        uint256 idMedicament;
        string nom;
        string numeroSerie;
        uint256 dateFabrication;
        uint256 datePeremption;
        address fabricantsAdress;
        bool isActive;
    }


    mapping(uint256 => Medicament) public medicaments;
    mapping (address => bool) public fabricantsAdmis;
    mapping (uint256 => address) public fabricantsAdmis;


} 