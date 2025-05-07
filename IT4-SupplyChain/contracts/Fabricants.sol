// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract FabricantMedicament {
     
    // Structure pour représenter un lot de produits
     struct LotMedicament {
        uint256 idLot;
        string nom;
        string description;
        string dateFabrication;
        string datePeremption;
        string numeroLot;
        address fabricantsAddress;
        bool isRecalled;
     }
    //structure pour représenter un Médicament
    struct Medicament {
        uint256 idMedicament;
        uint256 idLot;
        string numeroSerie;
        bool isActive;
    }

    //mapping pour stocker les lots de médicaments
    mapping(uint256 => LotMedicament) public lotmedicaments;
    mapping(uint256 => Medicament) public medicaments;
    mapping(address => bool) public fabricantAdmis;
    mapping(uint256 => address) public medicamentOwners;


    uint public medicamentCount = 0;
    uint public lotCount = 0;
    address public distributeurAddress;

    //Events
    event LotMedicamentAjoute(uint indexed idLot, string nom, string dateFabrication,address indexed fabricants);
    event MedicamentAjoute(uint256 indexed idMedicament, uint idLot, string numeroSerie);
    event LotMedicamentRappel(uint256 indexed idLot, address indexed fabricants);
    event FabricantAutorise(address indexed fabricants);
    event FabricantRevoque(address indexed fabricants);
    event AjoutDistributeur(address newDistributeur);
    event MedicamentTransfere(uint256 indexed idMedicament, address indexed from, address indexed to);

    //modifier pour vérifier si le fabricant est autorisé
    modifier fabricantAutorise() {
        require(fabricantAdmis[msg.sender], "Fabricant non autorise");
        _;
    }
    
    //constructeur - La Personne qui déploie le contrat est autorisée
    constructor() {
        fabricantAdmis[msg.sender] = true;
    }

    //fonction pour authoriser un nouveau fabricants
    function autoriserFabricant(address _fabricantsAddress) public fabricantAutorise {
        fabricantAdmis[_fabricantsAddress] = true;
        emit FabricantAutorise(_fabricantsAddress);
    }

    //function pour révoquer un fabricant
    function revoquerFabricant(address _fabricantsAddress) public fabricantAutorise {
        fabricantAdmis[_fabricantsAddress] = false;
        emit FabricantRevoque(_fabricantsAddress);
    }

    //function pour créer un nouveau lot de médicaments
    function ajouterLotMedicament(string memory _nom, 
    string memory _description, 
    string memory _dateFabrication, 
    string memory _datePeremption, 
    string memory _numeroLot) public fabricantAutorise returns (uint256) {
        lotCount++;
        lotmedicaments[lotCount] = LotMedicament(lotCount, _nom, _description, _dateFabrication, _datePeremption, _numeroLot, msg.sender, false);
        emit LotMedicamentAjoute(lotCount, _nom, _dateFabrication, msg.sender);
        return lotCount;
    }

    //function pour ajouter un médicament dans un loT
    function ajouterMedicament(uint256 _idLot, string[] memory _numeroSerie) public fabricantAutorise {
        require(_idLot <= lotCount, "Lot Inexistant");
        require(!lotmedicaments[_idLot].isRecalled, "Lot deja rappele");

        // Complete
        for (uint i = 0; i < _numeroSerie.length; i++) {
            medicamentCount++;
            medicaments[medicamentCount] = Medicament(medicamentCount, _idLot, _numeroSerie[i], true);
            medicamentOwners[medicamentCount] = msg.sender;
            emit MedicamentAjoute(medicamentCount, _idLot, _numeroSerie[i]);
        }
    }

    //function pour rappeler un lot de médicaments
    function rappelerLotMedicament(uint256 _idLot) public fabricantAutorise {
        require(_idLot <= lotCount, "Invalid batch ID");
        require(lotmedicaments[_idLot].fabricantsAddress == msg.sender, "Seul le fabricant peut rappeler le lot");
        lotmedicaments[_idLot].isRecalled = true;

        //Desactiver tous les médicaments dans le lot
        for (uint i = 1; i <= medicamentCount; i++) {
            if (medicaments[i].idLot == _idLot) {
                medicaments[i].isActive = false;
            }
        }
        emit LotMedicamentRappel(_idLot, msg.sender);
    }

    //function pour afficher les détails d'un lot de médicaments
    function getLotMedicament(uint256 _idLot) public view returns (LotMedicament memory) {
        return lotmedicaments[_idLot];
    }

    //function pour afficher les détails d'un médicament
    function getMedicament(uint256 _idMedicament) public view returns (uint, uint, string memory, bool) {
        require(_idMedicament <= medicamentCount, "Invalid product ID");
        Medicament memory medicament = medicaments[_idMedicament];
        return (medicament.idMedicament, medicament.idLot, medicament.numeroSerie, medicament.isActive);
    }

    // Ajouter un Distributeur
    function ajouterDistributeur(address _distributeur) public fabricantAutorise {
        distributeurAddress = _distributeur;
        emit AjoutDistributeur(_distributeur);
    }

    // Fonction pour transférer un lot de médicaments
    function transfererLotMedicament(uint256 _idLot, address _nouveauDestinataire) public fabricantAutorise {
        require(_idLot <= lotCount, "Lot Inexistant");
        require(lotmedicaments[_idLot].fabricantsAddress == msg.sender, "Seul le fabricant peut transferer le lot");
        require(_nouveauDestinataire != address(0), "Adresse du destinataire invalide");

        lotmedicaments[_idLot].fabricantsAddress = _nouveauDestinataire;

        for (uint i = 1; i <= medicamentCount; i++) {
            if (medicaments[i].idLot == _idLot) {
                medicaments[i].isActive = true;
            }
        }
        emit MedicamentTransfere(_idLot, msg.sender, _nouveauDestinataire);
    }

    //Trasfert du Medicament de facon Individuelle
    function transfererMedicament(uint256 _idMedicament, address _nouveauProprietaire) public {
        require(medicamentOwners[_idMedicament] == msg.sender, "Vous n'etes pas le proprietaire du medicament");
        require(medicaments[_idMedicament].isActive, "Medicament inactif ou rappele");

        medicamentOwners[_idMedicament] = _nouveauProprietaire;
        emit MedicamentTransfere(_idMedicament, msg.sender, _nouveauProprietaire);
    }
}