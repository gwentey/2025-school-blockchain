const {
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { expect } = require("chai");

  describe("Deploiement Fabricants", function () { 
    async function deployManufacturerFixture() {
        const [owner, distributeurAddress] = await ethers.getSigners();
        const manufacturer = await ethers.deployContract("Manufacturer"); 
        await manufacturer.waitForDeployment();
        //console.log("Manufacturer deployed at:", manufacturer.target);
        return { manufacturer, owner, distributeurAddress };
    }

    it("Doit assigner le déployeur comme fabricant autorisé", async function () {
        const { manufacturer, owner } = await loadFixture(deployManufacturerFixture);
        expect(await manufacturer.fabricantAdmis(owner.address)).to.equal(true);
      });
    
    it("Doit initialiser le compteur de médicaments à 1", async function () {
        const { manufacturer } = await loadFixture(deployManufacturerFixture);
        expect(await manufacturer.medicamentCount()).to.equal(1);
      });
    
    it("Doit ajouter un Medicament", async function () {
        const { manufacturer, owner } = await loadFixture(deployManufacturerFixture);
        await manufacturer.connect(owner).ajouterMedicament(1, "Paracetamol", "SER12345", "01/01/2023", "01/01/2025");
        
        const medicament = await manufacturer.medicaments(1);
        
        //console.log("Info sur Le Medicament:", medicament);
        expect(medicament.idMedicament).to.equal(1);
        expect(medicament.nom).to.equal("Paracetamol");
        expect(medicament.numeroSerie).to.equal("SER12345");
      });
    
      it("Doit Retourner les infos un Medicament", async function () {
        const { manufacturer, owner } = await loadFixture(deployManufacturerFixture);
        await manufacturer.connect(owner).ajouterMedicament(1, "Paracetamol", "SER12345", "01/01/2023", "01/01/2025");
        
        const [id, nom, numSerie, dateFab, datePeremp, fabricantAddr, isActive] = 
        await manufacturer.getMedicamentsInfo(1);

        expect(id).to.equal(1);
        expect(nom).to.equal("Paracetamol");
        expect(numSerie).to.equal("SER12345");
        expect(dateFab).to.equal("01/01/2023");
        expect(datePeremp).to.equal("01/01/2025");
        expect(fabricantAddr).to.equal(owner);
        expect(isActive).to.equal(true);;
      });
    
    it("Ajouter un Distributeur", async function () {
        const { manufacturer, owner, distributeurAddress } = await loadFixture(deployManufacturerFixture);
        await manufacturer.connect(owner).ajouterDistributeur(distributeurAddress);
        expect(await manufacturer.distributeurAddress()).to.equal(distributeurAddress);
      });
    
      it("Transferer un Medicament", async function () {
        const { manufacturer, owner, distributeurAddress } = await loadFixture(deployManufacturerFixture);
        await manufacturer.connect(owner).ajouterMedicament(1, "Paracetamol", "SER12345", "01/01/2023", "01/01/2025")
        await manufacturer.connect(owner).ajouterDistributeur(distributeurAddress);
        await manufacturer.connect(owner).transfererMedicament(1, distributeurAddress);
        
        const medicament = await manufacturer.medicaments(1);
        expect(medicament.fabricantsAddress).to.equal(distributeurAddress);
      });
});