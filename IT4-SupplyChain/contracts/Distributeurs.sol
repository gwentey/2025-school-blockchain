// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./Fabricants.sol";

contract DistributeurMedicament{
    FabricantMedicament public fabricantContrat;

    //Structure pour l'envoi du Médicament
    struct EnvoiMedicament {
        uint idEnvoi;
        uint256[] medicamentId;
        address fromDistributeurs;
        address toReceiver;
        string commentaire;
        bool produitRecu;
    }

    // Mappings
    mapping(uint => EnvoiMedicament) public envoisMedicaments;
    mapping(address => bool) distributeurAutorise;
    
     // Variables
    uint256 public nbreEnvoi;

    //Event
    event PackageEnvoye(uint256 indexed idEnvoi, address indexed fromFab, address indexed toDistr, uint256 envoiDate);
    event PackageRecu(uint256 indexed idEnvoi, address indexed distributeur);
    event DistributeurAutorise(address indexed distributeur);
    event DistributeurRevoke(address indexed distributeur);

    modifier DistributeurOK(){
        require(distributeurAutorise[msg.sender], "Not authorized");
        _;
    }

    constructor(address _fabricantAddress) {
        fabricantContrat = FabricantMedicament(_fabricantAddress);
        distributeurAutorise[msg.sender] = true;
    }

    //function pour autoriser les distributeurs
    function authorizeDistributeur(address _distributeur) public DistributeurOK {
        distributeurAutorise[_distributeur] = true;
        emit DistributeurAutorise(_distributeur);
    }

    //function pour supprimer un distributeur
    function revokeDistributeur(address _distributeur) public DistributeurOK {
        distributeurAutorise[_distributeur] = false;
        emit DistributeurRevoke(_distributeur);
    }

    // Function pour créer un envoi de médicament
    function EnvoiMedicaments(
        uint256[] calldata _medicamentId,
        address _toReceiver,
        string memory _commentaire
    ) public DistributeurOK {
        require(_toReceiver != address(0), "Addresse distributeur Invalide");        
        require(_medicamentId.length > 0, "Pas de Medicament pourvu");

        nbreEnvoi++;
        envoisMedicaments[nbreEnvoi] = EnvoiMedicament({
            idEnvoi: nbreEnvoi,
            medicamentId: _medicamentId,
            fromDistributeurs: msg.sender,
            toReceiver: _toReceiver,
            commentaire: _commentaire,
            produitRecu: false
        });
        emit PackageEnvoye(nbreEnvoi, msg.sender, _toReceiver, block.timestamp);
    }

    // Function pour confirmer la réception des médicaments
    function ReceptionMedicaments(uint256 _idEnvoi) public DistributeurOK {
        require(_idEnvoi <= nbreEnvoi, "ID Invalide");
        require(envoisMedicaments[_idEnvoi].toReceiver == msg.sender, "Pas le bon Distributeurs");
        require(envoisMedicaments[_idEnvoi].produitRecu, "Produit deja receptionne");

        envoisMedicaments[_idEnvoi].produitRecu = true;
        emit PackageRecu(_idEnvoi, msg.sender);
    }

    function ReceptionMedocs(uint256 _idEnvoi) public {
        EnvoiMedicament storage ev = envoisMedicaments[_idEnvoi];
        require(ev.toReceiver == msg.sender, "Not recipient");
        require(!ev.produitRecu, "Produit deja recu");
        //Transfert de Propriete

        fabricantContrat.transfererLotMedicament(_idEnvoi, msg.sender);
        ev.produitRecu = true;
        emit PackageRecu(_idEnvoi, msg.sender);
    } 

    // Avoir les detais de l'envoi
    function getEnvoiDetails(uint256 _idEnvoi) public view returns (
        uint256, uint256[] memory, address,  address, string memory, bool )
        {
        require(_idEnvoi <= nbreEnvoi, "ID Invalide");

        EnvoiMedicament memory envoi = envoisMedicaments[_idEnvoi];
        return (
            envoi.idEnvoi,
            envoi.medicamentId,
            envoi.fromDistributeurs,
            envoi.toReceiver,
            envoi.commentaire,
            envoi.produitRecu
        );
    }
}