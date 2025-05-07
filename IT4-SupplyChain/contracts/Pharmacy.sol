// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Distributors.sol";
//0x8461A3Ea5a60C5157F6887b830A25bA0D1cd044F
// 0x1bB5bf909d1200fb4730d899BAd7Ab0aE8487B0b
contract Pharmacy {
    Distributors public distributorsContract;

    struct Stock {
        uint256 idMedicament;
        uint256 quantite;
        bool isActive;
    }

    // Mappings
    mapping(uint256 => Stock) public stockMedicaments;
    mapping(address => bool) public pharmacieAutorisee;
    mapping(uint256 => address) public medicamentOwners;
    
    // Events
    event MedicamentRecu(uint256 indexed idMedicament, uint256 quantite, address indexed fromDistributeur);
    event MedicamentVendu(uint256 indexed idMedicament, uint256 quantite, address indexed toClient);
    event PharmacieAutorisee(address indexed pharmacie);
    event PharmacieRevoquee(address indexed pharmacie);

    modifier onlyPharmacie() {
        require(pharmacieAutorisee[msg.sender], "Pharmacie non autorisee");
        _;
    }

    constructor(address _distributeurAddress) {
        distributorsContract = Distributors(_distributeurAddress);
        pharmacieAutorisee[msg.sender] = true;
    }

    // Fonction pour recevoir un médicament
    function recevoirMedicament(uint256 _idMedicament, uint256 _quantite) public onlyPharmacie {
        require(_quantite > 0, "Quantite invalide");

        if (stockMedicaments[_idMedicament].quantite == 0) {
            stockMedicaments[_idMedicament] = Stock(_idMedicament, _quantite, true);
        } else {
            stockMedicaments[_idMedicament].quantite += _quantite;
        }

        medicamentOwners[_idMedicament] = msg.sender;
        distributorsContract.markAsDelivered(_idMedicament);
        emit MedicamentRecu(_idMedicament, _quantite, msg.sender);
    }

    // Fonction pour vendre un médicament
    function vendreMedicament(uint256 _idMedicament, uint256 _quantite, address _client) public {
        require(_quantite > 0, "Quantite invalide");
        require(stockMedicaments[_idMedicament].quantite >= _quantite, "Stock insuffisant");
        require(stockMedicaments[_idMedicament].isActive, "Medicament non disponible");

        stockMedicaments[_idMedicament].quantite -= _quantite;

        if (stockMedicaments[_idMedicament].quantite == 0) {
            stockMedicaments[_idMedicament].isActive = false;
        }

        emit MedicamentVendu(_idMedicament, _quantite, _client);
    }

    // Fonction pour obtenir les détails du stock d'un médicament
    function getStockDetails(uint256 _idMedicament) public view returns (uint256, uint256, bool) {
        require(stockMedicaments[_idMedicament].quantite > 0, "Medicament non disponible");
        Stock memory stock = stockMedicaments[_idMedicament];
        return (stock.idMedicament, stock.quantite, stock.isActive);
    }
}
