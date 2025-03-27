// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Manufacture.sol";

contract Distributor {
    Manufacture public manufacture;
    address public owner;

    event MedicamentDistribue(uint256 medicamentId, address pharmacie);

    constructor(address _manufactureAddress) {
        manufacture = Manufacture(_manufactureAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut executer cette fonction");
        _;
    }

    function distribuerMedicament(uint256 _medicamentId, address _pharmacie) public onlyOwner {
        // Vérifier si le médicament existe et n'est pas vendu
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

        emit MedicamentDistribue(_medicamentId, _pharmacie);
    }
} 