// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract Manufacturer{
    struct Medicament {
        uint256 idMedicament;
        string nom;
        string numeroSerie;
        string dateFabrication;
        string datePeremption;
        address fabricantsAddress;
        bool isActive;
    }

    mapping(uint256 => Medicament) public medicaments;
    mapping(address => bool) public fabricantAdmis;
    mapping(uint256 => address) public medicamentOwners;

    uint256 public medicamentCount = 0;
    address public distributeurAddress;

    event MedicamentAjoute(uint256 indexed idMedicament, string nom, string numeroSerie);
    event FabricantAutorise(address indexed fabricants);
    event FabricantRevoque(address indexed fabricants);

    modifier onlyFabricant() {
        require(fabricantAdmis[msg.sender], "Fabricant non autorise");
        _;
    }

    constructor() {
        fabricantAdmis[msg.sender] = true;
        medicamentCount = 1;
    }

    function autoriserFabricant(address _fabricatantsAdress) public onlyFabricant {
        fabricantAdmis[_fabricatantsAdress] = true;
        emit FabricantAutorise(_fabricatantsAdress);
    }
    
    function revoquerFabricant(address _fabricatantsAdress) public onlyFabricant {
        fabricantAdmis[_fabricatantsAdress] = false;
        emit FabricantRevoque(_fabricatantsAdress);
    }

    function ajouterMedicament(uint256 _id, string memory _nom, string memory _numSerie, string memory _dateFab, string memory _datePeremption) public onlyFabricant returns(uint256) {
        medicaments[medicamentCount] = Medicament({
            idMedicament: _id,
            nom: _nom,
            numeroSerie: _numSerie,
            dateFabrication: _dateFab,
            datePeremption: _datePeremption,
            fabricantsAddress: msg.sender,
            isActive: true
        });
        medicamentOwners[medicamentCount] = msg.sender;
        medicamentCount ++;
        emit MedicamentAjoute(_id, _nom, _numSerie);
        return medicamentCount;
    }

    function getMedicamentsInfo(uint256 _idMed) public view returns (uint, string memory, string memory, string memory, string memory, address, bool) {
        require(_idMed <= medicamentCount, "Id du Medicamen Invalide");
        Medicament memory medic = medicaments[_idMed];
        return (medic.idMedicament, medic.nom, medic.numeroSerie, medic.dateFabrication, medic.datePeremption, medic.fabricantsAddress, medic.isActive);
    }
}