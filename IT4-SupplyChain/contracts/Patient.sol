// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pharmacy.sol";
import "./Distributors.sol";
import "./Manufacturers.sol";

contract Patient {

    Pharmacy public pharmacyContract;
    Distributors public distributorsContract;
    Manufacturer public manufacturerContract;

    struct Achat {
        uint256 idMedicament;
        uint256 quantite;
        address pharmacyAddress;
        uint256 dateAchat;
    }

    // Mappings
    mapping(address => bool) public patientAutorise;
    mapping(uint256 => Achat) public achats;
    mapping(uint256 => bool) public achatValide;

    // Variables
    uint256 public achatCount = 0;

    // Events
    event MedicamentAchete(uint256 indexed idMedicament, uint256 quantite, address indexed patient, address indexed pharmacy);
    event PatientAutorise(address indexed patient);
    event PatientRevoque(address indexed patient);

    modifier onlyPatient() {
        require(patientAutorise[msg.sender], "Patient non autorise");
        _;
    }

    constructor(address _pharmacyAddress, address _distributorAddress, address _manufacturerAddress) {
        pharmacyContract = Pharmacy(_pharmacyAddress);
        distributorsContract = Distributors(_distributorAddress);
        manufacturerContract = Manufacturer(_manufacturerAddress);
        patientAutorise[msg.sender] = true;
    }

    // Autoriser un patient
    function autoriserPatient(address _patient) public onlyPatient {
        patientAutorise[_patient] = true;
        emit PatientAutorise(_patient);
    }

    // Révoquer un patient
    function revoquerPatient(address _patient) public onlyPatient {
        patientAutorise[_patient] = false;
        emit PatientRevoque(_patient);
    }

    // Acheter un médicament
    function acheterMedicament(uint256 _idMedicament, uint256 _quantite) public onlyPatient {
        require(_quantite > 0, "Quantite invalide");

        (, uint256 quantite, bool isActive) = pharmacyContract.stockMedicaments(_idMedicament);
        require(quantite >= _quantite, "Stock insuffisant");
        require(isActive, "Medicament non disponible");

        pharmacyContract.vendreMedicament(_idMedicament, _quantite, msg.sender);

        achats[achatCount] = Achat({
            idMedicament: _idMedicament,
            quantite: _quantite,
            pharmacyAddress: pharmacyContract.medicamentOwners(_idMedicament),
            dateAchat: block.timestamp
        });

        achatValide[achatCount] = true;
        emit MedicamentAchete(_idMedicament, _quantite, msg.sender, pharmacyContract.medicamentOwners(_idMedicament));
        achatCount++;
    }

    // Vérifier la traçabilité d’un achat
    function verifierTracabilite(uint256 _idAchat) public view returns (bool, string memory) {
        require(achatValide[_idAchat], "Achat invalide");

        Achat memory achat = achats[_idAchat];
        uint256 idMedicament = achat.idMedicament;

        (,, bool isActive) = pharmacyContract.stockMedicaments(idMedicament);
        require(isActive, "Medicament non disponible");

        address pharmacy = achat.pharmacyAddress;
        (,, address fromManufacturers,,,) = distributorsContract.envoiMedicaments(idMedicament);
        address distributeur = fromManufacturers;
        address fabricant = manufacturerContract.medicamentOwners(idMedicament);

        string memory historique = string(
            abi.encodePacked(
                "Historique de transit:\n",
                "Fabricant: ", addressToString(fabricant), "\n",
                "Distributeur: ", addressToString(distributeur), "\n",
                "Pharmacie: ", addressToString(pharmacy), "\n"
            )
        );

        return (true, historique);
    }

    // Obtenir les détails d’un achat
    function getAchatDetails(uint256 _idAchat) public view returns (uint256, uint256, address, uint256) {
        require(achatValide[_idAchat], "Achat invalide");

        Achat memory achat = achats[_idAchat];
        return (achat.idMedicament, achat.quantite, achat.pharmacyAddress, achat.dateAchat);
    }

    // Utilitaire pour convertir une adresse en string
    function addressToString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';

        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }

        return string(str);
    }
}