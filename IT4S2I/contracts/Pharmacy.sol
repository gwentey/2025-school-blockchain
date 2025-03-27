// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Manufacture.sol";

contract Pharmacy {
    Manufacture public manufacture;
    address public owner;
    mapping(uint256 => bool) public medicamentsEnStock;

    event MedicamentVendu(uint256 medicamentId, address patient);

    constructor(address _manufactureAddress) {
        manufacture = Manufacture(_manufactureAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut executer cette fonction");
        _;
    }

    function ajouterMedicament(uint256 _medicamentId) public onlyOwner {
        medicamentsEnStock[_medicamentId] = true;
    }

    function vendreMedicament(uint256 _medicamentId, address _patient) public onlyOwner {
        require(medicamentsEnStock[_medicamentId], "Medicament non disponible");
        
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

        medicamentsEnStock[_medicamentId] = false;
        emit MedicamentVendu(_medicamentId, _patient);
    }

    function verifierStock(uint256 _medicamentId) public view returns (bool) {
        return medicamentsEnStock[_medicamentId];
    }
} 