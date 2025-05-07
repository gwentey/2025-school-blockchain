const {
  loadFixture,
  expect,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("Deploy Fabricants", function () {
  async function deployManufacturerFixture() {

    const [owner, distributeurAdress] = await ethers.getSigners();
    const manufacturer = await ethers.deployContract("Manufacturer");
    await manufacturer.waitForDeployment();
    return { manufacturer, owner, distributeurAdress };
  }

  it("Doit assigner le déployeur comme frabricant", async function () {
    const { manufacturer, owner } = await loadFixture(deployManufacturerFixture);
    expect(await manufacturer.fabricantsAdmis(owner.address)).to.equal(true);
  });

  it("Doit ajouter un Medicament", async function () {
    const { manufacturer, owner } = await loadFixture(deployManufacturerFixture);
    await manufacturer.connect(owner).ajouterMedicament(1, "Medicament 1", "1234567890", "2021-01-01", "2021-01-01");
    
    const medicament = await manufacturer.medicaments(1);

    expect(medicament.idMedicament).to.equal(1);
    expect(medicament.nom).to.equal("Medicament 1");
    expect(medicament.numeroSerie).to.equal("1234567890");
    expect(medicament.dateFabrication).to.equal("2021-01-01");
    expect(medicament.datePeremption).to.equal("2021-01-01");
    expect(medicament.fabricantsAddress).to.equal(owner.address);
    expect(medicament.isActive).to.equal(true);

    expect(await manufacturer.medicaments(1)).to.equal(true);
  });

  it("Ajouter un distributeur", async function () {
    const { manufacturer, owner, distributeurAdress } = await loadFixture(deployManufacturerFixture);
    await manufacturer.connect(owner).ajouterDistributeur(distributeurAdress);
    expect(await manufacturer.distributeurs(distributeurAdress)).to.equal(true);
  });
  
  
  

});