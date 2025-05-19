const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SchoolBlockchain Suite", function () {
    let managerHopital, gestionDroitsPatient, gestionAuditeurs;
    let owner, hopital1, hopital2, patient1, patient2, auditeur1;

    // Redéfinition de l'enum EtatHopital et StatutErreur en JavaScript pour les comparaisons
    const EtatHopital = {
        Actif: 0,
        Suspendu: 1
    };

    const StatutErreur = {
        Soumise: 0,
        EnCoursDeValidation: 1,
        Validee: 2,
        Invalidee: 3,
        Resolue: 4
    };

    beforeEach(async function () {
        [owner, hopital1, hopital2, patient1, patient2, auditeur1] = await ethers.getSigners();

        const ManagerHopital = await ethers.getContractFactory("ManagerHopital");
        managerHopital = await ManagerHopital.deploy();
        await managerHopital.deployed();

        const GestionDroitsPatient = await ethers.getContractFactory("GestionDroitsPatient");
        gestionDroitsPatient = await GestionDroitsPatient.deploy(); // ownerContrat est owner
        await gestionDroitsPatient.deployed();

        const GestionAuditeurs = await ethers.getContractFactory("GestionAuditeurs");
        gestionAuditeurs = await GestionAuditeurs.deploy(); // ownerContrat est owner
        await gestionAuditeurs.deployed();

        // Configuration initiale : l'owner du ManagerHopital désigne un auditeur (adresse de l'auditeur1)
        // Et cet auditeur doit être enregistré dans GestionAuditeurs
        await managerHopital.connect(owner).setAuditeur(auditeur1.address);
        await gestionAuditeurs.connect(owner).enregistrerAuditeur(
            auditeur1.address,
            "Jean",
            "Audit",
            "AUD001",
            "Audit Corp"
        );
        
        // L'owner de GestionDroitsPatient (qui est `owner` ici) va aussi se définir comme patient pour certains tests.
        // await gestionDroitsPatient.connect(owner).enregistrerPatient("Admin", "User", "123 Admin Street");
    });

    describe("1. Gestion des Hopitaux (ManagerHopital)", function () {
        it("1.1 Doit permettre à un hôpital de s'enregistrer", async function () {
            await managerHopital.connect(hopital1).enregistrerHopital("Hopital Central", "1 Rue Principale");
            const hopitalInfo = await managerHopital.getHopitalInfo(hopital1.address);

            expect(hopitalInfo.nom).to.equal("Hopital Central");
            expect(hopitalInfo.adressePhysique).to.equal("1 Rue Principale");
            expect(hopitalInfo.score).to.equal(0);
            expect(hopitalInfo.etat).to.equal(EtatHopital.Actif); // 0 pour Actif
            expect(await managerHopital.estEnregistre(hopital1.address)).to.be.true;
        });

        it("1.2 Doit suspendre un hôpital après > 5 contestations validées", async function () {
            // Enregistrer l'hôpital
            await managerHopital.connect(hopital1).enregistrerHopital("Hopital à Suspendre", "10 Rue des Erreurs");
            
            // Simuler 6 contestations validées par l'auditeur désigné (auditeur1)
            for (let i = 0; i < 6; i++) {
                // L'auditeur (auditeur1) met à jour le score, validant la contestation
                await managerHopital.connect(auditeur1).mettreAJourScore(hopital1.address, true); 
            }

            const hopitalInfo = await managerHopital.getHopitalInfo(hopital1.address);
            expect(hopitalInfo.etat).to.equal(EtatHopital.Suspendu); // 1 pour Suspendu
            expect(hopitalInfo.score).to.equal(-6);
            expect(hopitalInfo.contestationsValideesCount).to.equal(6);
        });
    });

    describe("2. Gestion des Patients et Contestations (GestionDroitsPatient)", function () {
        it("2.1 Doit permettre à un patient de contester une erreur médicale", async function () {
            // Enregistrer patient1
            await gestionDroitsPatient.connect(patient1).enregistrerPatient("Alice", "Patientia", "101 Main St");
            expect(await gestionDroitsPatient.patients(patient1.address)).to.have.property('estEnregistre', true);

            // Enregistrer hopital1 pour la contestation
            await managerHopital.connect(hopital1).enregistrerHopital("Hopital de Test", "202 Test Ave");

            // Patient1 conteste une erreur concernant hopital1
            const descriptionErreur = "Mauvais diagnostic";
            await gestionDroitsPatient.connect(patient1).contesterErreur(hopital1.address, descriptionErreur);

            const erreursHopital1 = await gestionDroitsPatient.getErreursMedicalesParHopital(hopital1.address);
            expect(erreursHopital1.length).to.equal(1);
            expect(erreursHopital1[0].idPatient).to.equal(patient1.address);
            expect(erreursHopital1[0].description).to.equal(descriptionErreur);
            expect(erreursHopital1[0].statut).to.equal(StatutErreur.Soumise); // 0 pour Soumise

            const toutesLesErreurs = await gestionDroitsPatient.toutesLesErreurs(0); // Accès direct si public, sinon via getter
            expect(toutesLesErreurs.idErreur).to.equal(0);
        });
    });

    describe("3. Audit d'Erreur (Interaction entre contrats)", function () {
        it("3.1 Doit permettre à un auditeur de valider une erreur et mettre à jour le score de l'hôpital", async function () {
            // Enregistrement des acteurs
            await managerHopital.connect(hopital1).enregistrerHopital("Hopital pour Audit", "303 Audit Rd");
            await gestionDroitsPatient.connect(patient1).enregistrerPatient("Bob", "Contestataire", "1 Secure Zone");

            // Le patient1 conteste une erreur pour hopital1
            await gestionDroitsPatient.connect(patient1).contesterErreur(hopital1.address, "Erreur de médication");
            const idErreurAValider = 0; // La première erreur soumise aura l'ID 0

            // L'auditeur (via owner de GestionDroitsPatient pour modifier le statut)
            // et l'auditeur désigné (via managerHopital pour le score)
            // Idéalement, une fonction d'audit dans GestionAuditeurs appellerait ces deux fonctions.
            
            // Étape 1: Auditeur désigné par ManagerHopital met à jour le score de l'hôpital (erreur validée = true)
            await managerHopital.connect(auditeur1).mettreAJourScore(hopital1.address, true);
            const hopitalInfo = await managerHopital.getHopitalInfo(hopital1.address);
            expect(hopitalInfo.score).to.equal(-1);
            expect(hopitalInfo.contestationsValideesCount).to.equal(1);

            // Étape 2: L'owner de GestionDroitsPatient (ou un auditeur autorisé là) modifie le statut de l'erreur
            // Pour ce test, l'owner de GestionDroitsPatient (qui est `owner` des tests) le fait.
            await gestionDroitsPatient.connect(owner).modifierStatutErreur(idErreurAValider, StatutErreur.Validee); // 2 pour Validee
            
            const erreurInfo = await gestionDroitsPatient.toutesLesErreurs(idErreurAValider);
            expect(erreurInfo.statut).to.equal(StatutErreur.Validee);
        });
    });

    describe("4. Suivi de Réputation (ManagerHopital)", function () {
        it("4.1 Doit suivre l'historique des scores d'un hôpital", async function () {
            await managerHopital.connect(hopital1).enregistrerHopital("Hopital ScoreTrack", "707 Track St");
            let historique = await managerHopital.getHistoriqueScore(hopital1.address);
            expect(historique.length).to.equal(1);
            expect(historique[0]).to.equal(0); // Score initial

            // L'auditeur met à jour le score (contestation validée)
            await managerHopital.connect(auditeur1).mettreAJourScore(hopital1.address, true);
            historique = await managerHopital.getHistoriqueScore(hopital1.address);
            expect(historique.length).to.equal(2);
            expect(historique[1]).to.equal(-1);

            // L'auditeur met à jour le score (contestation invalidée)
            await managerHopital.connect(auditeur1).mettreAJourScore(hopital1.address, false);
            historique = await managerHopital.getHistoriqueScore(hopital1.address);
            expect(historique.length).to.equal(3);
            expect(historique[1]).to.equal(-1); // L'ancien -1 est toujours là
            expect(historique[2]).to.equal(0);  // -1 + 1 = 0
        });
    });
}); 