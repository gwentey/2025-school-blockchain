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
        EnCoursDeValidation, // Par un auditeur externe par exemple
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
    address[] public listeAdressesPatients; // Pour lister les patients enregistrés
    mapping(address => uint) private patientIndexInList; // Pour aider à la suppression dans listeAdressesPatients

    uint public prochainIdErreur;
    ErreurMedicale[] public toutesLesErreurs;

    mapping(address => uint[]) public erreursSoumisesParHopital; // Stocke les idErreur (index de toutesLesErreurs)
    mapping(address => uint[]) public erreursSoumisesParPatient; // Stocke les idErreur (index de toutesLesErreurs)

    event PatientEnregistre(address indexed patientAddress, string nom, string prenom, uint timestamp);
    event PatientRevoque(address indexed patientAddress, uint timestamp);
    event ErreurMedicaleContestee(uint indexed idErreur, address indexed idHopital, address indexed idPatient, string description, uint timestamp);
    event StatutErreurModifie(uint indexed idErreur, StatutErreur nouveauStatut, uint timestamp);

// nos decorateurs qui check les droit 
    modifier onlyOwnerContrat() {
        require(msg.sender == ownerContrat, "Reservé au propriétaire/administrateur du contrat patients.");
        _;
    }

    modifier onlyPatientEnregistre() {
        require(patients[msg.sender].estEnregistre, "L'expéditeur doit être un patient enregistré.");
        _;
    }
    
    modifier patientNonEnregistre(address _patientAddress) {
        require(!patients[_patientAddress].estEnregistre, "Le patient est déjà enregistré.");
        _;
    }

    modifier patientExiste(address _patientAddress) {
        require(patients[_patientAddress].estEnregistre, "Le patient n'existe pas ou n'est pas enregistré.");
        _;
    }

    constructor() {
        ownerContrat = msg.sender;
    }

    function _ajouterPatient(address _adresseEthereumPatient, string calldata _nom, string calldata _prenom, string calldata _adressePhysique) private patientNonEnregistre(_adresseEthereumPatient) {
        require(_adresseEthereumPatient != address(0), "Adresse patient invalide.");
        require(bytes(_nom).length > 0, "Nom requis.");
        require(bytes(_prenom).length > 0, "Prénom requis.");
        
        patients[_adresseEthereumPatient] = Patient({
            nom: _nom,
            prenom: _prenom,
            adresseEthereum: _adresseEthereumPatient,
            adressePhysique: _adressePhysique,
            estEnregistre: true
        });

        patientIndexInList[_adresseEthereumPatient] = listeAdressesPatients.length;
        listeAdressesPatients.push(_adresseEthereumPatient);
        
        emit PatientEnregistre(_adresseEthereumPatient, _nom, _prenom, block.timestamp);
    }

    // Fonction pour que n'importe qui (nouveau patient) puisse s'enregistrer
    function enregistrerPatient(string calldata _nom, string calldata _prenom, string calldata _adressePhysique) external {
        // Le msg.sender devient l'adresseEthereum du patient
        _ajouterPatient(msg.sender, _nom, _prenom, _adressePhysique);
    }


    function revoquerPatient() public onlyPatientEnregistre {
        address patientARevoquer = msg.sender;

        uint indexASupprimer = patientIndexInList[patientARevoquer];
        
        if (listeAdressesPatients.length > 0) {
            address dernierPatientDansListe = listeAdressesPatients[listeAdressesPatients.length - 1];
            if (patientARevoquer != dernierPatientDansListe) {
                listeAdressesPatients[indexASupprimer] = dernierPatientDansListe; 
                patientIndexInList[dernierPatientDansListe] = indexASupprimer;
            }
            listeAdressesPatients.pop();
        }

        patients[patientARevoquer].estEnregistre = false; 
        delete patientIndexInList[patientARevoquer];

        emit PatientRevoque(patientARevoquer, block.timestamp);
    }

    function contesterErreur(address _idHopital, string calldata _description) external onlyPatientEnregistre {
        require(_idHopital != address(0), "ID Hôpital invalide.");
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
            erreursResultat[i] = toutesLesErreurs[idsErreurs[i]];
        }
        return erreursResultat;
    }

    function getErreursValideesParHopital(address _idHopital) external view returns (ErreurMedicale[] memory) {
        uint[] memory idsErreursPourHopital = erreursSoumisesParHopital[_idHopital];
        ErreurMedicale[] memory erreursValidees = new ErreurMedicale[](idsErreursPourHopital.length);
        uint compteurValidees = 0;

        for (uint i = 0; i < idsErreursPourHopital.length; i++) {
            uint erreurId = idsErreursPourHopital[i];
            if (erreurId < toutesLesErreurs.length && toutesLesErreurs[erreurId].statut == StatutErreur.Validee) {
                erreursValidees[compteurValidees] = toutesLesErreurs[erreurId];
                compteurValidees++;
            }
        }

        ErreurMedicale[] memory resultatFinal = new ErreurMedicale[](compteurValidees);
        for (uint i = 0; i < compteurValidees; i++) {
            resultatFinal[i] = erreursValidees[i];
        }

        return resultatFinal;
    }
    

    function getPatientInfo(address _patientAddress) external view patientExiste(_patientAddress) returns (Patient memory) {
        return patients[_patientAddress];
    }
    
    function getListePatients() external view returns (address[] memory) {
        return listeAdressesPatients;
    }

    // TODO
    function modifierStatutErreur(uint _idErreur, StatutErreur _nouveauStatut) external onlyOwnerContrat {
        require(_idErreur < toutesLesErreurs.length, "ID Erreur invalide.");
        toutesLesErreurs[_idErreur].statut = _nouveauStatut;
        emit StatutErreurModifie(_idErreur, _nouveauStatut, block.timestamp);
    }
} 