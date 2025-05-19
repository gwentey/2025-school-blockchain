// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GestionAuditeurs {

    address public ownerContrat; 

    struct Auditeur {
        string nom;
        string prenom;
        string numeroAuditeur;    
        string entreprise;
        address adresseEthereum;
        bool estActif;         
    }

    mapping(address => Auditeur) public auditeurs;
    mapping(string => address) private auditeurParNumero; 
    address[] public listeAdressesAuditeursActifs;
    mapping(address => uint) private auditeurIndexInList; // pour la supression

    event AuditeurEnregistre(address indexed auditeurAddress, string numeroAuditeur, string nom, string entreprise, uint timestamp);
    event AuditeurModifie(address indexed auditeurAddress, bool estActif, uint timestamp);
    event AuditeurSupprime(address indexed auditeurAddress, uint timestamp); // Si suppression complète

    modifier onlyOwnerContrat() {
        require(msg.sender == ownerContrat, "Reserve au proprietaire du contrat.");
        _;
    }

    modifier auditeurExiste(address _auditeurAddress) {
        require(auditeurs[_auditeurAddress].adresseEthereum != address(0), "L auditeur n existe pas.");
        _;
    }
    
    modifier auditeurNExistePas(address _auditeurAddress) {
        require(auditeurs[_auditeurAddress].adresseEthereum == address(0), "L auditeur existe deja a cette adresse.");
        _;
    }

    constructor() {
        ownerContrat = msg.sender;
    }

    function enregistrerAuditeur(
        address _auditeurAddress,
        string calldata _nom,
        string calldata _prenom,
        string calldata _numeroAuditeur,
        string calldata _entreprise
    ) external onlyOwnerContrat auditeurNExistePas(_auditeurAddress) {
        require(_auditeurAddress != address(0), "Adresse auditeur invalide.");
        require(bytes(_nom).length > 0, "Nom requis.");
        require(bytes(_prenom).length > 0, "Prenom requis.");
        require(bytes(_numeroAuditeur).length > 0, "Numero Auditeur requis.");
        require(auditeurParNumero[_numeroAuditeur] == address(0), "Ce numero d auditeur est deja utilise.");

        auditeurs[_auditeurAddress] = Auditeur({
            nom: _nom,
            prenom: _prenom,
            numeroAuditeur: _numeroAuditeur,
            entreprise: _entreprise,
            adresseEthereum: _auditeurAddress,
            estActif: true
        });

        auditeurParNumero[_numeroAuditeur] = _auditeurAddress;
        
        auditeurIndexInList[_auditeurAddress] = listeAdressesAuditeursActifs.length;
        listeAdressesAuditeursActifs.push(_auditeurAddress);

        emit AuditeurEnregistre(_auditeurAddress, _numeroAuditeur, _nom, _entreprise, block.timestamp);
    }

    function desactiverAuditeur(address _auditeurAddress) external onlyOwnerContrat auditeurExiste(_auditeurAddress) {
        require(auditeurs[_auditeurAddress].estActif, "L auditeur est deja inactif.");
        auditeurs[_auditeurAddress].estActif = false;

        // Supprimer de la liste des actifs
        uint indexASupprimer = auditeurIndexInList[_auditeurAddress];
        address dernierAuditeurActif = listeAdressesAuditeursActifs[listeAdressesAuditeursActifs.length - 1];
        listeAdressesAuditeursActifs[indexASupprimer] = dernierAuditeurActif;
        auditeurIndexInList[dernierAuditeurActif] = indexASupprimer;
        listeAdressesAuditeursActifs.pop();
        delete auditeurIndexInList[_auditeurAddress];

        emit AuditeurModifie(_auditeurAddress, false, block.timestamp);
    }

    function reactiverAuditeur(address _auditeurAddress) external onlyOwnerContrat auditeurExiste(_auditeurAddress) {
        require(!auditeurs[_auditeurAddress].estActif, "L auditeur est deja actif.");
        auditeurs[_auditeurAddress].estActif = true;

        // Ajouter à la liste des actifs
        auditeurIndexInList[_auditeurAddress] = listeAdressesAuditeursActifs.length;
        listeAdressesAuditeursActifs.push(_auditeurAddress);

        emit AuditeurModifie(_auditeurAddress, true, block.timestamp);
    }
    
    // Option pour supprimer complètement un auditeur (plus drastique que désactiver)
    function supprimerAuditeur(address _auditeurAddress) external onlyOwnerContrat auditeurExiste(_auditeurAddress) {
        if (auditeurs[_auditeurAddress].estActif) {
            // S'il est actif, le retirer de la liste des actifs d'abord
            uint indexASupprimer = auditeurIndexInList[_auditeurAddress];
            address dernierAuditeurActif = listeAdressesAuditeursActifs[listeAdressesAuditeursActifs.length - 1];
            listeAdressesAuditeursActifs[indexASupprimer] = dernierAuditeurActif;
            auditeurIndexInList[dernierAuditeurActif] = indexASupprimer;
            listeAdressesAuditeursActifs.pop();
            delete auditeurIndexInList[_auditeurAddress];
        }

        delete auditeurParNumero[auditeurs[_auditeurAddress].numeroAuditeur];
        delete auditeurs[_auditeurAddress];
        
        emit AuditeurSupprime(_auditeurAddress, block.timestamp);
    }

    function getAuditeurInfo(address _auditeurAddress) external view auditeurExiste(_auditeurAddress) returns (Auditeur memory) {
        return auditeurs[_auditeurAddress];
    }

    function getListeAuditeursActifs() external view returns (address[] memory) {
        return listeAdressesAuditeursActifs;
    }
    
    function estAuditeurActif(address _auditeurAddress) external view returns (bool) {
        return auditeurs[_auditeurAddress].adresseEthereum != address(0) && auditeurs[_auditeurAddress].estActif;
    }
} 