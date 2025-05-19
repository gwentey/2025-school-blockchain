// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GestionDroitsPatient {

    address public ownerContrat; 

    struct Patient {
        string nom;
        string prenom;
        address adresseEthereum; 
        string adressePhysique; 
        bool estEnregistre;      
    }

    enum StatutErreur {
        Soumise,
        EnCoursDeValidation, 
        Validee,
        Invalidee,
        Resolue
    }

    struct ErreurMedicale {
        uint idErreur;
        address idHopital;       
        address idPatient;       
        uint date;               
        string description;
        StatutErreur statut;
    }

    mapping(address => Patient) public patients;
    address[] public listeAdressesPatients; 
    mapping(address => uint) private patientIndexInList;

    uint public prochainIdErreur;
    ErreurMedicale[] public toutesLesErreurs;

    mapping(address => uint[]) public erreursSoumisesParHopital; 
    mapping(address => uint[]) public erreursSoumisesParPatient; 

    event PatientEnregistre(address indexed patientAddress, string nom, string prenom, bool estOwnerContrat, uint timestamp);
    event PatientRevoque(address indexed patientAddress, uint timestamp);
    event ErreurMedicaleContestee(uint indexed idErreur, address indexed idHopital, address indexed idPatient, string description, uint timestamp);
    event StatutErreurModifie(uint indexed idErreur, StatutErreur nouveauStatut, uint timestamp);

    modifier onlyOwnerContrat() {
        require(msg.sender == ownerContrat, "Action reservee au proprietaire du contrat.");
        _;
    }

    modifier onlyPatientEnregistre() {
        require(patients[msg.sender].estEnregistre, "Action reservee aux patients enregistres.");
        _;
    }
    
    modifier patientNonEnregistre(address _patientAddress) {
        require(!patients[_patientAddress].estEnregistre, "Patient deja enregistre.");
        _;
    }

    modifier patientExiste(address _patientAddress) {
        require(patients[_patientAddress].estEnregistre, "Patient non enregistre.");
        _;
    }

    constructor() {
        ownerContrat = msg.sender; 
    }

    function _ajouterPatient(address _adresseEthereumPatient, string calldata _nom, string calldata _prenom, string calldata _adressePhysique) private patientNonEnregistre(_adresseEthereumPatient) {
        require(_adresseEthereumPatient != address(0), "Adresse patient invalide.");
        require(bytes(_nom).length > 0, "Nom requis.");
        require(bytes(_prenom).length > 0, "Prenom requis.");
        
        patients[_adresseEthereumPatient] = Patient({
            nom: _nom,
            prenom: _prenom,
            adresseEthereum: _adresseEthereumPatient,
            adressePhysique: _adressePhysique,
            estEnregistre: true
        });

        patientIndexInList[_adresseEthereumPatient] = listeAdressesPatients.length;
        listeAdressesPatients.push(_adresseEthereumPatient);
        
        bool estOwner = (_adresseEthereumPatient == ownerContrat);
        emit PatientEnregistre(_adresseEthereumPatient, _nom, _prenom, estOwner, block.timestamp);
    }

    function enregistrerPatient(string calldata _nom, string calldata _prenom, string calldata _adressePhysique) external {
        _ajouterPatient(msg.sender, _nom, _prenom, _adressePhysique);
    }

    function ajouterPatientParOwner(address _adresseEthereumPatient, string calldata _nom, string calldata _prenom, string calldata _adressePhysique) external onlyOwnerContrat {
        _ajouterPatient(_adresseEthereumPatient, _nom, _prenom, _adressePhysique);
    }
     
    function revoquerPatient(address _patientAddress) external onlyOwnerContrat patientExiste(_patientAddress) {
        require(_patientAddress != ownerContrat, "L owner du contrat ne peut pas etre revoque lui-meme.");
        
        uint indexASupprimer = patientIndexInList[_patientAddress];
        if (listeAdressesPatients.length > 0) { 
            address dernierPatientDansListe = listeAdressesPatients[listeAdressesPatients.length - 1];
            if (_patientAddress != dernierPatientDansListe) {
                 listeAdressesPatients[indexASupprimer] = dernierPatientDansListe; 
                 patientIndexInList[dernierPatientDansListe] = indexASupprimer;
            }
            listeAdressesPatients.pop();
        }
        
        patients[_patientAddress].estEnregistre = false; 
        delete patientIndexInList[_patientAddress];

        emit PatientRevoque(_patientAddress, block.timestamp);
    }

    function contesterErreur(address _idHopital, string calldata _description) external onlyPatientEnregistre {
        require(_idHopital != address(0), "ID Hopital invalide.");
        require(bytes(_description).length > 0, "Description requise.");

        uint erreurId = prochainIdErreur;
        toutesLesErreurs.push(ErreurMedicale({
            idErreur: erreurId,
            idHopital: _idHopital,
            idPatient: msg.sender,
            date: block.timestamp,
            description: _description,
            statut: StatutErreur.Soumise
        }));

        erreursSoumisesParHopital[_idHopital].push(erreurId);
        erreursSoumisesParPatient[msg.sender].push(erreurId);

        prochainIdErreur++;

        emit ErreurMedicaleContestee(erreurId, _idHopital, msg.sender, _description, block.timestamp);
    }

    function getErreursMedicalesParHopital(address _idHopital) external view returns (ErreurMedicale[] memory) {
        uint[] memory idsErreurs = erreursSoumisesParHopital[_idHopital];
        ErreurMedicale[] memory erreursResultat = new ErreurMedicale[](idsErreurs.length);

        for (uint i = 0; i < idsErreurs.length; i++) {
            if (idsErreurs[i] < toutesLesErreurs.length) {
                erreursResultat[i] = toutesLesErreurs[idsErreurs[i]];
            }
        }
        return erreursResultat;
    }

    function getErreursValideesParHopital(address _idHopital) external view returns (ErreurMedicale[] memory) {
        uint[] memory idsErreursPourHopital = erreursSoumisesParHopital[_idHopital];
        ErreurMedicale[] memory erreursValideesTemporaire = new ErreurMedicale[](idsErreursPourHopital.length);
        uint compteurValidees = 0;

        for (uint i = 0; i < idsErreursPourHopital.length; i++) {
            uint erreurId = idsErreursPourHopital[i];
            if (erreurId < toutesLesErreurs.length && toutesLesErreurs[erreurId].statut == StatutErreur.Validee) {
                erreursValideesTemporaire[compteurValidees] = toutesLesErreurs[erreurId];
                compteurValidees++;
            }
        }

        ErreurMedicale[] memory resultatFinal = new ErreurMedicale[](compteurValidees);
        for (uint i = 0; i < compteurValidees; i++) {
            resultatFinal[i] = erreursValideesTemporaire[i];
        }
        return resultatFinal;
    }
    
    function getErreursMedicalesParPatient(address _idPatient) external view patientExiste(_idPatient) returns (ErreurMedicale[] memory) {
        uint[] memory idsErreurs = erreursSoumisesParPatient[_idPatient];
        ErreurMedicale[] memory erreursResultat = new ErreurMedicale[](idsErreurs.length);

        for (uint i = 0; i < idsErreurs.length; i++) {
            if (idsErreurs[i] < toutesLesErreurs.length) {
                erreursResultat[i] = toutesLesErreurs[idsErreurs[i]];
            }
        }
        return erreursResultat;
    }

    function getPatientInfo(address _patientAddress) external view patientExiste(_patientAddress) returns (Patient memory) {
        return patients[_patientAddress];
    }
    
    function getListePatients() external view returns (address[] memory) {
        return listeAdressesPatients;
    }

    function modifierStatutErreur(uint _idErreur, StatutErreur _nouveauStatut) external onlyOwnerContrat { 
        require(_idErreur < toutesLesErreurs.length, "ID Erreur invalide.");
        toutesLesErreurs[_idErreur].statut = _nouveauStatut;
        emit StatutErreurModifie(_idErreur, _nouveauStatut, block.timestamp);
    }
}