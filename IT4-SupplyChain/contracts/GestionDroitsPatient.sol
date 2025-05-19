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

    // MODIFIÉ: Permet à un patient de révoquer son propre enregistrement.
    // Le patient (msg.sender) doit être enregistré.
    function revoquerPatient() public onlyPatientEnregistre {
        address patientARevoquer = msg.sender;

        // Logique de suppression de la liste `listeAdressesPatients`
        // Le modificateur onlyPatientEnregistre garantit que le patient existe et est dans la liste.
        uint indexASupprimer = patientIndexInList[patientARevoquer];
        
        // Cette condition est une sécurité supplémentaire, bien que `onlyPatientEnregistre` implique que la liste n'est pas vide
        // et que patientARevoquer y est.
        if (listeAdressesPatients.length > 0) {
            address dernierPatientDansListe = listeAdressesPatients[listeAdressesPatients.length - 1];
            // Cas où le patient à supprimer n'est pas le dernier élément
            if (patientARevoquer != dernierPatientDansListe) {
                listeAdressesPatients[indexASupprimer] = dernierPatientDansListe; 
                patientIndexInList[dernierPatientDansListe] = indexASupprimer;
            }
            // Dans tous les cas (seul élément, dernier élément, ou élément au milieu après swap), on retire le dernier.
            listeAdressesPatients.pop();
        }

        // Marquer le patient comme non enregistré
        patients[patientARevoquer].estEnregistre = false; 
        // Supprimer l'index de la liste pour cet ancien patient
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
        ErreurMedicale[] memory erreursValidees = new ErreurMedicale[](idsErreursPourHopital.length); // Taille max potentielle
        uint compteurValidees = 0;

        for (uint i = 0; i < idsErreursPourHopital.length; i++) {
            uint erreurId = idsErreursPourHopital[i];
            if (erreurId < toutesLesErreurs.length && toutesLesErreurs[erreurId].statut == StatutErreur.Validee) {
                erreursValidees[compteurValidees] = toutesLesErreurs[erreurId];
                compteurValidees++;
            }
        }

        // Redimensionner le tableau pour n'inclure que les erreurs validées
        ErreurMedicale[] memory resultatFinal = new ErreurMedicale[](compteurValidees);
        for (uint i = 0; i < compteurValidees; i++) {
            resultatFinal[i] = erreursValidees[i];
        }

        return resultatFinal;
    }
    
    function getErreursMedicalesParPatient(address _idPatient) external view patientExiste(_idPatient) returns (ErreurMedicale[] memory) {
        uint[] memory idsErreurs = erreursSoumisesParPatient[_idPatient];
        ErreurMedicale[] memory erreursResultat = new ErreurMedicale[](idsErreurs.length);

        for (uint i = 0; i < idsErreurs.length; i++) {
            erreursResultat[i] = toutesLesErreurs[idsErreurs[i]];
        }
        return erreursResultat;
    }

    function getPatientInfo(address _patientAddress) external view patientExiste(_patientAddress) returns (Patient memory) {
        return patients[_patientAddress];
    }
    
    function getListePatients() external view returns (address[] memory) {
        return listeAdressesPatients;
    }

    // Fonction pour modifier le statut d'une erreur (par exemple, par un auditeur ou l'hôpital)
    // Pour l'instant, supposons un rôle externe (non défini ici) ou l'ownerContrat pour la simplicité
    function modifierStatutErreur(uint _idErreur, StatutErreur _nouveauStatut) external onlyOwnerContrat { // Pourrait être un autre rôle
        require(_idErreur < toutesLesErreurs.length, "ID Erreur invalide.");
        // Ajouter plus de logique de validation si nécessaire (qui peut changer quel statut, etc.)
        toutesLesErreurs[_idErreur].statut = _nouveauStatut;
        emit StatutErreurModifie(_idErreur, _nouveauStatut, block.timestamp);
    }
} 