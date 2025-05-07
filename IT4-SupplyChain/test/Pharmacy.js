const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("Deploiement Pharmacy", function () {
  async function deployPharmacyFixture() {
    const [owner, pharmacy2, patient] = await ethers.getSigners();
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
      const pharmacy = await ethers.deployContract("Pharmacy", [distributors.target], {
        signer: owner
      });
      console.log("Pharmacy deployed at:", pharmacy.target);

      // Créer une expédition pour un test ultérieur
      await distributors.connect(owner).ajouterPharmacy(pharmacy.target);
      await distributors.connect(owner).creerExpedition(1, pharmacy.target, "Expedition Reussie");

      return { owner, pharmacy2, patient, manufacturer, distributors, pharmacy };
    } catch (error) {
      console.error("Error deploying contracts:", error);
      throw error;
    }
  }

  it("Doit assigner l'adresse du Distributeur", async function () {
    const { pharmacy, distributors } = await loadFixture(deployPharmacyFixture);
    const distributorsAddress = await pharmacy.distributorsContract();
    console.log("Distributors address in Pharmacy contract:", distributorsAddress);
    expect(distributorsAddress).to.equal(distributors.target);
  });

  it("Doit assigner le déployeur comme Pharmacie autorisée", async function () {
    const { pharmacy, owner } = await loadFixture(deployPharmacyFixture);
    expect(await pharmacy.pharmacieAutorisee(owner.address)).to.equal(true);
  });

  it("Doit recevoir un médicament", async function () {
    const { pharmacy, owner } = await loadFixture(deployPharmacyFixture);
    
    // Réception initiale d'un médicament
    await pharmacy.connect(owner).recevoirMedicament(1, 50);
    
    // Vérifier que le stock a été créé
    const stock = await pharmacy.stockMedicaments(1);
    expect(stock.idMedicament).to.equal(1);
    expect(stock.quantite).to.equal(50);
    expect(stock.isActive).to.equal(true);
    
    // Vérifier que le propriétaire du médicament est bien enregistré
    expect(await pharmacy.medicamentOwners(1)).to.equal(owner.address);
  });

  it("Doit ajouter au stock existant lors d'une seconde réception", async function () {
    const { pharmacy, owner } = await loadFixture(deployPharmacyFixture);
    
    // Première réception
    await pharmacy.connect(owner).recevoirMedicament(1, 30);
    
    // Seconde réception
    await pharmacy.connect(owner).recevoirMedicament(1, 20);
    
    // Vérifier que le stock a été mis à jour
    const stock = await pharmacy.stockMedicaments(1);
    expect(stock.quantite).to.equal(50); // 30 + 20
  });

  it("Doit vendre un médicament", async function () {
    const { pharmacy, owner, patient } = await loadFixture(deployPharmacyFixture);
    
    // Réception d'un médicament
    await pharmacy.connect(owner).recevoirMedicament(1, 100);
    
    // Vente d'une partie du stock
    await pharmacy.connect(owner).vendreMedicament(1, 30, patient.address);
    
    // Vérifier que le stock a été mis à jour
    const stock = await pharmacy.stockMedicaments(1);
    expect(stock.quantite).to.equal(70); // 100 - 30
    expect(stock.isActive).to.equal(true);
  });

  it("Doit désactiver un médicament lorsque le stock atteint zéro", async function () {
    const { pharmacy, owner, patient } = await loadFixture(deployPharmacyFixture);
    
    // Réception d'un médicament
    await pharmacy.connect(owner).recevoirMedicament(1, 30);
    
    // Vente de tout le stock
    await pharmacy.connect(owner).vendreMedicament(1, 30, patient.address);
    
    // Vérifier que le stock a été désactivé
    const stock = await pharmacy.stockMedicaments(1);
    expect(stock.quantite).to.equal(0);
    expect(stock.isActive).to.equal(false);
  });

  it("Doit échouer si la quantité demandée est supérieure au stock disponible", async function () {
    const { pharmacy, owner, patient } = await loadFixture(deployPharmacyFixture);
    
    // Réception d'un médicament
    await pharmacy.connect(owner).recevoirMedicament(1, 20);
    
    // Tenter de vendre plus que le stock disponible
    await expect(pharmacy.connect(owner).vendreMedicament(1, 30, patient.address))
      .to.be.revertedWith("Stock insuffisant");
  });

  it("Doit retourner les détails du stock d'un médicament", async function () {
    const { pharmacy, owner } = await loadFixture(deployPharmacyFixture);
    
    // Réception d'un médicament
    await pharmacy.connect(owner).recevoirMedicament(1, 75);
    
    // Récupérer les détails du stock
    const [idMedicament, quantite, isActive] = await pharmacy.getStockDetails(1);
    
    expect(idMedicament).to.equal(1);
    expect(quantite).to.equal(75);
    expect(isActive).to.equal(true);
  });

  it("Doit échouer si on demande les détails d'un médicament non disponible", async function () {
    const { pharmacy } = await loadFixture(deployPharmacyFixture);
    
    // Tenter de récupérer les détails d'un médicament non disponible
    await expect(pharmacy.getStockDetails(2))
      .to.be.revertedWith("Medicament non disponible");
  });
});
