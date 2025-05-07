const { expect } = require("chai");

describe("Test de Connexion", function () {
    it("Should deploy Manufacturer contract", async function () {
        const [owner] = await ethers.getSigners();
        const Manufacturer = await ethers.deployContract("Manufacturer"); 
    });

    it("Doit assigner le déployeur comme fabricant autorisé", async function () {
        const [owner] = await ethers.getSigners();
        const Manufacturer = await ethers.deployContract("Manufacturer");
        expect(await Manufacturer.fabricantAdmis(owner.address)).to.equal(true);
      });

      it("Doit initialiser le compteur de médicaments à 1", async function () {
        const [owner] = await ethers.getSigners();
        const Manufacturer = await ethers.deployContract("Manufacturer");
        expect(await Manufacturer.medicamentCount()).to.equal(1);
      });     
})

describe("Test d'ajout", function(){
    it("Inserer un Medicament", async function () {
        const [owner] = await ethers.getSigners();
        const Manufacturer = await ethers.deployContract("Manufacturer"); 
        await Manufacturer.connect(owner).ajouterMedicament("", 1000);
    });
})

