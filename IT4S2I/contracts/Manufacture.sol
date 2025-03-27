// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Manufacture {
    struct Medicament {
        uint256 medicamentId;
        string numeroSerie;
        string nom;
        address adresseFabricant;
        uint256 dateFabrication;
        uint256 datePeremption;
        bool estVendu;
    }

    mapping(uint256 => Medicament) public medicaments;
    uint256 public medicamentCount;

    event MedicamentCree(
        uint256 medicamentId,
        string numeroSerie,
        string nom,
        address adresseFabricant,
        uint256 dateFabrication,
        uint256 datePeremption
    );

    function creerMedicament(
        string memory _numeroSerie,
        string memory _nom,
        uint256 _datePeremption
    ) public {
        medicamentCount++;
        medicaments[medicamentCount] = Medicament(
            medicamentCount,
            _numeroSerie,
            _nom,
            msg.sender,
            block.timestamp,
            _datePeremption,
            false
        );

        emit MedicamentCree(
            medicamentCount,
            _numeroSerie,
            _nom,
            msg.sender,
            block.timestamp,
            _datePeremption
        );
    }

    function getMedicament(uint256 _medicamentId) public view returns (
        uint256 medicamentId,
        string memory numeroSerie,
        string memory nom,
        address adresseFabricant,
        uint256 dateFabrication,
        uint256 datePeremption,
        bool estVendu
    ) {
        Medicament memory m = medicaments[_medicamentId];
        return (
            m.medicamentId,
            m.numeroSerie,
            m.nom,
            m.adresseFabricant,
            m.dateFabrication,
            m.datePeremption,
            m.estVendu
        );
    }
} 