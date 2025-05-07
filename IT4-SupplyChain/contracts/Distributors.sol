// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Manufacturers.sol";

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

     // Mappings
    mapping(uint => Expedition) public envoiMedicaments;
    mapping(address => bool) public distributeurAutorise;
    address public pharmacyAddress;

    // Variables
    uint256 public nbreExpedier;

    //Event
    event PackageEnvoye(uint256 indexed idEnvoi, address indexed fromFab, address indexed toDistr, uint256 envoiDate);
    event PackageRecu(uint256 indexed idEnvoi, address indexed distributeur);
    event DistributeurAutorise(address indexed distributeur);
    event DistributeurRevoke(address indexed distributeur);

    modifier onlyDistributeur{
        require (distributeurAutorise[msg.sender] == true, "Only the authorised distributeurs can call this function");
        _;
    }
    
    constructor(address _fabricantAddress) {
        manufacturerContract = Manufacturer(_fabricantAddress);
        distributeurAutorise[msg.sender] = true;
        nbreExpedier = 1;
    }

    //function pour autoriser les distributeurs
    function authorizeDistributeur(address _distributeur) public onlyDistributeur {
        require(_distributeur != address(0), "Invalid distributor address");
        distributeurAutorise[_distributeur] = true;
        emit DistributeurAutorise(_distributeur);
    }

    //function pour supprimer un distributeur
    function revokeDistributeur(address _distributeur) public onlyDistributeur {
        require(_distributeur != address(0), "Invalid distributor address");
        distributeurAutorise[_distributeur] = false;
        emit DistributeurRevoke(_distributeur);
    }

    // Ajouter un Distributeur
    function ajouterPharmacy(address _pharmacy) public onlyDistributeur {
        pharmacyAddress = _pharmacy;
    }

    function creerExpedition(uint256 _idMed, address _pharmacy, string memory _commentaire) public onlyDistributeur {
        require(_pharmacy != address(0), "Invalid pharmacy address");
        require(manufacturerContract.medicamentOwners(_idMed) != address(0), "Medicament does not exist");
        require(envoiMedicaments[_idMed].idExpedition == 0, "Expedition already exists");

        Expedition storage newEnvoi = envoiMedicaments[nbreExpedier];
        newEnvoi.idExpedition = nbreExpedier;
        newEnvoi.idMedicament = _idMed;
        newEnvoi.fromManufacturers = manufacturerContract.medicamentOwners(_idMed);
        newEnvoi.toPharmacy = _pharmacy;
        newEnvoi.commentaire = _commentaire;
        newEnvoi.produitRecu = false;


        emit PackageEnvoye(nbreExpedier, manufacturerContract.medicamentOwners(_idMed), _pharmacy, block.timestamp);
        nbreExpedier++;
         // Vérification du transfert
        bool transfertValide = verifierTransfertMedicament(_idMed);
        require(transfertValide, "Transfert du medicament non valide");
    }

    function markAsDelivered(uint256 _idExpedition) public {
        require(!envoiMedicaments[_idExpedition].produitRecu, "Produit deja delivre");
        envoiMedicaments[_idExpedition].produitRecu = true;
    }

    function verifierTransfertMedicament(uint256 _idMed) public view returns (bool) {
    // Vérifiez que l'ID du médicament est valide
    require(_idMed > 0 && _idMed <= manufacturerContract.medicamentCount(), "ID du medoc invalide");
    address distributeur = manufacturerContract.medicamentOwners(_idMed);
    return distributeur == msg.sender;
    }

    function getExpeditionDetails(uint256 _idExpedition) public view returns (
        uint256 idExpedition,
        uint256 idMedicament, address fromManufacturers,
        address toPharmacy, string memory commentaire, bool produitRecu) {
            require(_idExpedition > 0 && _idExpedition < nbreExpedier, "Invalid shipment ID");
            Expedition storage expedition = envoiMedicaments[_idExpedition];
            return (
                expedition.idExpedition, 
                expedition.idMedicament, 
                expedition.fromManufacturers, 
                expedition.toPharmacy, 
                expedition.commentaire, 
                expedition.produitRecu
            );
    }
}