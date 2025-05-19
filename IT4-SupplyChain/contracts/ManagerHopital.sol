// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ManagerHopital {

    address public owner;
    address public auditeurAddress;

    enum EtatHopital {
        Actif,
        Suspendu
    }

    struct Hopital {
        address idHopital;
        string nom;
        string adressePhysique;
        int score;
        EtatHopital etat;
        uint contestationsValideesCount;
        int[] historiqueDesScores;
    }

    mapping(address => Hopital) public hopitaux;
    mapping(address => bool) public estEnregistre;
    address[] public listeHopitauxIds;
    mapping(address => uint) private hopitalIndexInList;

    event HopitalEnregistre(address indexed idHopital, string nom, string adressePhysique, uint timestamp);
    event HopitalSupprime(address indexed idHopital, uint timestamp);
    event HopitalSuspendu(address indexed idHopital, uint timestamp);
    event ScoreMisAJour(address indexed idHopital, int nouveauScore, int ancienScore, string raison, uint timestamp);
    event AuditeurModifie(address indexed nouvelAuditeur, address indexed ancienAuditeur, uint timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Reserve au proprietaire du contrat");
        _;
    }

    modifier onlyAuditeur() {
        require(msg.sender == auditeurAddress, "Reserve a l auditeur");
        _;
    }

    modifier hopitalDoitExister(address _idHopital) {
        require(estEnregistre[_idHopital], "L hopital n est pas enregistre");
        _;
    }
    
    modifier hopitalNeDoitPasExister(address _idHopital) {
        require(!estEnregistre[_idHopital], "L hopital est deja enregistre");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setAuditeur(address _nouvelAuditeur) external onlyOwner {
        require(_nouvelAuditeur != address(0), "L adresse de l auditeur ne peut pas etre nulle");
        address ancienAuditeur = auditeurAddress;
        auditeurAddress = _nouvelAuditeur;
        emit AuditeurModifie(_nouvelAuditeur, ancienAuditeur, block.timestamp);
    }

    function enregistrerHopital(string calldata _nom, string calldata _adressePhysique) external hopitalNeDoitPasExister(msg.sender) {

        // juste pour ontroler les champ 
        require(bytes(_nom).length > 0, "Le nom ne peut pas etre vide");
        require(bytes(_adressePhysique).length > 0, "L adresse physique ne peut pas etre vide");

        hopitaux[msg.sender] = Hopital({
            idHopital: msg.sender,
            nom: _nom,
            adressePhysique: _adressePhysique,
            score: 0,
            etat: EtatHopital.Actif,
            contestationsValideesCount: 0,
            historiqueDesScores: new int[](0) // Initialise avec un tableau vide
        });
        hopitaux[msg.sender].historiqueDesScores.push(0); // Ajoute le score initial à l'historique

        estEnregistre[msg.sender] = true;

        //on donne un ticket pour garder la position
        hopitalIndexInList[msg.sender] = listeHopitauxIds.length;
        listeHopitauxIds.push(msg.sender);

        emit HopitalEnregistre(msg.sender, _nom, _adressePhysique, block.timestamp);
    }

    function supprimerHopitalParOwner(address _idHopital) external onlyOwner hopitalDoitExister(_idHopital) {
        uint indexASupprimer = hopitalIndexInList[_idHopital];
        address dernierHopitalDansListe = listeHopitauxIds[listeHopitauxIds.length - 1];

        // rempalce l'element à sup par le dernier élement 
        listeHopitauxIds[indexASupprimer] = dernierHopitalDansListe;
        // Met à jour l'index du dernier élément (qui a été déplacé)
        hopitalIndexInList[dernierHopitalDansListe] = indexASupprimer;

        // Supprime le dernier élément (qui est maintenant soit l'élément à supprimer, soit un duplicata)
        listeHopitauxIds.pop();

        delete hopitaux[_idHopital];
        delete estEnregistre[_idHopital];
        delete hopitalIndexInList[_idHopital];

        emit HopitalSupprime(_idHopital, block.timestamp);
    }
    
    function mettreAJourScore(address _idHopital, bool _contestationValidee) external onlyAuditeur hopitalDoitExister(_idHopital) {
        Hopital storage hopital = hopitaux[_idHopital];

        int ancienScore = hopital.score;
        string memory raison;

        if (_contestationValidee) {
            hopital.score -= 1;
            hopital.contestationsValideesCount += 1;
            raison = "Contestation validee";

            // on rempalce notre fonction susprendreHopital par ce bloc 
            if (hopital.contestationsValideesCount > 5 && hopital.etat == EtatHopital.Actif) {
                hopital.etat = EtatHopital.Suspendu;
                emit HopitalSuspendu(_idHopital, block.timestamp);
            }
        } else {
            hopital.score += 1;
            raison = "Contestation invalidee";
        }

        hopital.historiqueDesScores.push(hopital.score);
        emit ScoreMisAJour(_idHopital, hopital.score, ancienScore, raison, block.timestamp);
    }

    function getHopitalInfo(address _idHopital) external view hopitalDoitExister(_idHopital) returns (Hopital memory) {
        return hopitaux[_idHopital];
    }

    function getHistoriqueScore(address _idHopital) external view hopitalDoitExister(_idHopital) returns (int[] memory) {
        return hopitaux[_idHopital].historiqueDesScores;
    }

    function getListeHopitaux() external view returns (address[] memory) {
        return listeHopitauxIds;
    }

} 