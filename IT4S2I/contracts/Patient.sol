// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Manufacture.sol";

contract Patient {
    Manufacture public manufacture;
    address public owner;
    mapping(uint256 => bool) public medicamentsPossedes;

    event MedicamentAchete(uint256 medicamentId, address patient);

    constructor(address _manufactureAddress) {
        manufacture = Manufacture(_manufactureAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut executer cette fonction");
        _;
    }

    function acheterMedicament(uint256 _medicamentId) public onlyOwner {
        (
            uint256 medicamentId,
            string memory numeroSerie,
            string memory nom,
            address adresseFabricant,
            uint256 dateFabrication,
            uint256 datePeremption,
            bool estVendu
        ) = manufacture.getMedicament(_medicamentId);

        require(medicamentId > 0, "Medicament non trouve");
        require(!estVendu, "Medicament deja vendu");
        require(block.timestamp < datePeremption, "Medicament perime");

        medicamentsPossedes[_medicamentId] = true;
        emit MedicamentAchete(_medicamentId, msg.sender);
    }

    function verifierMedicament(uint256 _medicamentId) public view returns (bool) {
        return medicamentsPossedes[_medicamentId];
    }

    function getDetailsMedicament(uint256 _medicamentId) public view returns (
        uint256 medicamentId,
        string memory numeroSerie,
        string memory nom,
        address adresseFabricant,
        uint256 dateFabrication,
        uint256 datePeremption,
        bool estVendu
    ) {
        return manufacture.getMedicament(_medicamentId);
    }
} 