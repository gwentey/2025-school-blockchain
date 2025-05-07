const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("Deploiement Patient", function () {
  async function deployPatientFixture() {
    const [owner, patient2, pharmacy, distributor] = await ethers.getSigners();
    try {
      // Déployer le contrat Manufacturer
      const manufacturer = await ethers.deployContract("Manufacturer");
      console.log("Manufacturer deployed at:", manufacturer.target);

      if (!manufacturer.target) {
        throw new Error("Manufacturer address is null or undefined");
      }

      // Ajouter un médicament
      await manufacturer.connect(owner).ajouterMedicament(1, "Paracetamol", "SER12345", "01/01/2023", "01/01/2025");

      // Déployer le contrat Distributors
      const distributors = await ethers.deployContract("Distributors", [manufacturer.target], {
        signer: owner
      });
      console.log("Distributor deployed at:", distributors.target);

      // Autoriser le distributeur dans le contrat Manufacturer
      await manufacturer.connect(owner).ajouterDistributeur(distributors.target);

      // Déployer le contrat Pharmacy
      const pharmacyContract = await ethers.deployContract("Pharmacy", [distributors.target, manufacturer.target], {
        signer: owner
      });
      console.log("Pharmacy deployed at:", pharmacyContract.target);

      // Déployer le contrat Patient
      const patient = await ethers.deployContract("Patient", 
        [pharmacyContract.target, distributors.target, manufacturer.target], {
        signer: owner
      });
      console.log("Patient deployed at:", patient.target);

      // Ajouter un médicament dans la pharmacie
      await pharmacyContract.connect(owner).ajouterMedicament(1, 100, true);

      return { owner, patient2, pharmacy, distributor, manufacturer, distributors, pharmacyContract, patient };
    } catch (error) {
      console.error("Error deploying contracts:", error);
      throw error;
    }
  }

  it("Doit assigner les adresses des contrats correctement", async function () {
    const { patient, pharmacyContract, distributors, manufacturer } = await loadFixture(deployPatientFixture);
    
    expect(await patient.pharmacyContract()).to.equal(pharmacyContract.target);
    expect(await patient.distributorsContract()).to.equal(distributors.target);
    expect(await patient.manufacturerContract()).to.equal(manufacturer.target);
  });

  it("Doit assigner le déployeur comme Patient autorisé", async function () {
    const { patient, owner } = await loadFixture(deployPatientFixture);
    expect(await patient.patientAutorise(owner.address)).to.equal(true);
  });

  it("Doit autoriser un nouveau patient", async function () {
    const { patient, owner, patient2 } = await loadFixture(deployPatientFixture);
    await patient.connect(owner).autoriserPatient(patient2.address);
    expect(await patient.patientAutorise(patient2.address)).to.equal(true);
  });

  it("Doit révoquer un patient autorisé", async function () {
    const { patient, owner, patient2 } = await loadFixture(deployPatientFixture);
    await patient.connect(owner).autoriserPatient(patient2.address);
    await patient.connect(owner).revoquerPatient(patient2.address);
    expect(await patient.patientAutorise(patient2.address)).to.equal(false);
  });

  it("Doit permettre l'achat d'un médicament", async function () {
    const { patient, owner, pharmacyContract } = await loadFixture(deployPatientFixture);
    
    // Vérifier le stock initial
    const stockInitial = (await pharmacyContract.stockMedicaments(1))[1];
    
    // Acheter le médicament
    await patient.connect(owner).acheterMedicament(1, 10);
    
    // Vérifier que l'achat a été enregistré
    const achat = await patient.achats(0);
    expect(achat.idMedicament).to.equal(1);
    expect(achat.quantite).to.equal(10);
    
    // Vérifier que le stock a été mis à jour
    const stockFinal = (await pharmacyContract.stockMedicaments(1))[1];
    expect(stockFinal).to.equal(stockInitial - 10);
  });

  it("Doit échouer si la quantité demandée est supérieure au stock disponible", async function () {
    const { patient, owner } = await loadFixture(deployPatientFixture);
    
    // Tenter d'acheter plus que le stock disponible
    await expect(patient.connect(owner).acheterMedicament(1, 101))
      .to.be.revertedWith("Stock insuffisant");
  });

  it("Doit permettre de vérifier la traçabilité d'un achat", async function () {
    const { patient, owner } = await loadFixture(deployPatientFixture);
    
    // Acheter un médicament
    await patient.connect(owner).acheterMedicament(1, 5);
    
    // Vérifier la traçabilité
    const [estValide, _] = await patient.verifierTracabilite(0);
    expect(estValide).to.equal(true);
  });

  it("Doit retourner les détails d'un achat", async function () {
    const { patient, owner, pharmacyContract } = await loadFixture(deployPatientFixture);
    
    // Acheter un médicament
    await patient.connect(owner).acheterMedicament(1, 8);
    
    // Obtenir les détails de l'achat
    const [idMedicament, quantite, pharmacyAddress] = await patient.getAchatDetails(0);
    
    expect(idMedicament).to.equal(1);
    expect(quantite).to.equal(8);
    expect(pharmacyAddress).to.equal(await pharmacyContract.medicamentOwners(1));
  });
});
