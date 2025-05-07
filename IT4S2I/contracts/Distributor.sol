// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./Manufacturer.sol";

contract Distributors {
    Manufacturer public manufacturerContract;

    struct Expedition {
        uint256 idExpedition;
        uint256 idMedicament;
        address fromManufacturers;
        address toPharmacy;
        string commentaire;
        bool produitRecu;
    }

    mapping(uint256 => Expedition) public expeditionMedicaments;
    mapping(address => bool) distributeurAutorise;
    
    address public pharmacyAddress;
    uint256 public nbExpedie;

    event CommandeEnvoyee(uint256 indexed idEnvoi, address indexed fromManufacturers, address indexed );
    event CommandeRecue(uint256 indexed idEnvoi, address indexed ditributeur);
    event DistributeurAutorise(address indexed ditributeur);
    event DistributeurRevoque(address indexed ditributeur);
        // indexed permet de rechercher plus rapidement => on parcourt pas tout mais on va directement Ã l'index

    modifier onlyDistributeur() {
        require(distributeurAutorise[msg.sender] == true,"Distributeur non autorise");
        _; // = break
    }

    constructor(address _fabriquantAdress) {
        manufacturerContract = Manufacturer(_fabriquantAdress);
        distributeurAutorise[msg.sender] = true;
        nbExpedie = 1;
    }

    function autoriserDistributeur(address _distributeur) public onlyDistributeur {
        require(_distributeur != address(0), "Adresse distributeur invalide");
        distributeurAutorise[_distributeur] = true;
        emit DistributeurAutorise(_distributeur);
    }

    function revoquerDistributeur(address _distributeur) public onlyDistributeur {
        require(_distributeur != address(0), "Adresse distributeur invalide");
        distributeurAutorise[_distributeur] = false;
        emit DistributeurRevoque(_distributeur);
    }

    function verifierTransferMedicament(uint256 _idMed) public view returns (bool) {
        require(_idMed > 0 && _idMed <= manufacturerContract.medicamentCount(), "ID du medicament invalide");
        address distributeur = manufacturerContract.medicamentOwners(_idMed);
        return distributeur == msg.sender;
    }

    function creerExpedition(uint256 _idMed, address _pharmacyAddress, string memory _commentaires) public {
        require(_pharmacyAddress != address(0), "Adresse de la pharmacie invalide");
        require(manufacturerContract.medicamentOwners(_idMed) != address(0), "Le medicament n'appartient pas a la pharmacie");
        require(expeditionMedicaments[_idMed].idExpedition == 0, "L'expedition existe deja");

        Expedition storage nouvelEnvoi = expeditionMedicaments[nbExpedie];
        nouvelEnvoi.idExpedition = nbExpedie;
        nouvelEnvoi.idMedicament = _idMed;
        nouvelEnvoi.fromManufacturers = manufacturerContract.medicamentOwners(_idMed);
        nouvelEnvoi.toPharmacy = _pharmacyAddress;
        nouvelEnvoi.commentaire = _commentaires;
        nouvelEnvoi.produitRecu = false;

        emit CommandeEnvoyee(nbExpedie, manufacturerContract.medicamentOwners(_idMed), _pharmacyAddress);
        nbExpedie ++;
        bool transfertValide = verifierTransferMedicament(_idMed);
        require(transfertValide, "Transfert du medicament non valide");
    }
}