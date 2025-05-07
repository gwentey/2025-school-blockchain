// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//0xcAba93D84F9E1Eb8F90D38cBEad5f683F14c4b1b
//0xd9145CCE52D386f254917e481eB44e9943F39138 
contract Manufacturer {

    struct Medicament {
        uint256 idMedicament;
        string nom;
        string numeroSerie;
        string dateFabrication;
        string datePeremption;
        address fabricantsAddress;
        bool isActive;
    }
    //mappings
    mapping(uint256 => Medicament) public medicaments;
    mapping(address => bool) public fabricantAdmis;
    mapping(uint256 => address) public medicamentOwners;

    uint public medicamentCount = 0;
    address public distributeurAddress;

    //Events
    event MedicamentAjoute(uint256 indexed idMedicament,string nom, string numeroSerie);
    event FabricantAutorise(address indexed fabricants);
    event FabricantRevoque(address indexed fabricants);
    event AjoutDistributeur(address newDistributeur);
    event MedicamentTransfere(uint256 indexed idMedicament, address indexed from, address indexed to);

     //modifier pour vérifier si le fabricant est autorisé
    modifier onlyFabricant() {
        require(fabricantAdmis[msg.sender], "Fabricant non autorise");
        _;
    }
    
    //constructeur - La Personne qui déploie le contrat est autorisée
    constructor() {
        fabricantAdmis[msg.sender] = true;
        medicamentCount = 1;
    }

    //fonction pour authoriser un nouveau fabricants
    function autoriserFabricant(address _fabricantsAddress) public onlyFabricant {
        fabricantAdmis[_fabricantsAddress] = true;
        emit FabricantAutorise(_fabricantsAddress);
    }

    //function pour révoquer un fabricant
    function revoquerFabricant(address _fabricantsAddress) public onlyFabricant {
        fabricantAdmis[_fabricantsAddress] = false;
        emit FabricantRevoque(_fabricantsAddress);
    }

    // Ajouter un Distributeur
    function ajouterDistributeur(address _distributeur) public onlyFabricant {
        distributeurAddress = _distributeur;
        emit AjoutDistributeur(_distributeur);
    }

    function medicamentExists(uint256 _idMed) public view returns (bool) {
    return _idMed <= medicamentCount && medicamentOwners[_idMed] != address(0);
    }


    function ajouterMedicament (uint _id, string memory _nom, string memory _numSerie ,
        string memory _dateFab, string memory _datePeremption) public onlyFabricant returns(uint256){
        medicaments[medicamentCount] = Medicament({
            idMedicament: _id, 
            nom: _nom,
            numeroSerie: _numSerie,
            dateFabrication : _dateFab, 
            datePeremption : _datePeremption, 
            fabricantsAddress: msg.sender,
            isActive: true}); 
        medicamentOwners[medicamentCount] = msg.sender;
        medicamentCount ++;
        emit MedicamentAjoute(_id,_nom,_numSerie); 
        return medicamentCount;
        }

    function getMedicamentsInfo(uint256 _idMed) public view 
        returns (uint, string memory, string memory, string memory, string memory, address, bool) {
        require(_idMed <= medicamentCount, "ID du Medicament Invalide");
        Medicament memory medic = medicaments[_idMed];
        return (medic.idMedicament, medic.nom, medic.numeroSerie, medic.dateFabrication, medic.datePeremption, medic.fabricantsAddress, medic.isActive);
    }
    
    function rappelerMedicament(uint256 _idMed) public onlyFabricant{
        require(_idMed <= medicamentCount , "Numero de medicaments inexistants");
        require(medicaments[_idMed].fabricantsAddress == msg.sender, "Seul le fabricant peut rappeler le lot");
        require((bool)(medicaments[_idMed].isActive),"Medicament non present en stock");
        Medicament storage medicament = medicaments[_idMed];
        medicament.isActive=false;   
    }

    function transfererMedicament(uint256 _idMed, address _distributeur) public onlyFabricant {
        require(_idMed <= medicamentCount , "Numero de medicaments inexistants");
        require(medicamentOwners[_idMed] == msg.sender, "Vous n'etes pas le proprietaire du medicament");
        require((bool)(medicaments[_idMed].isActive),"Medicament non present en stock");
        
        medicaments[_idMed].fabricantsAddress = _distributeur; 
        medicamentOwners[_idMed] = _distributeur;
        emit MedicamentTransfere(_idMed, msg.sender,_distributeur);
    }
}