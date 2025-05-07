const {
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { expect } = require("chai");

  describe("Deploiement Distributeurs", function () { 
    async function deployManufacturerFixture() {
        const [owner, distrib2, pharmacy] = await ethers.getSigners();
        try {
            const manufacturer = await ethers.deployContract("Manufacturer"); 
            console.log("Manufacturer deployed at:", manufacturer.target);

            if (!manufacturer.target) {
            throw new Error("Manufacturer address is null or undefined"); }

            await manufacturer.connect(owner).ajouterMedicament(1, "Paracetamol", "SER12345", "01/01/2023", "01/01/2025");

            const distributor = await ethers.deployContract("Distributors", [manufacturer.target], {
                signer: owner
            });
            console.log("Distributor deployed at:", distributor.target);

            // Autoriser le distributeur dans le contrat Manufacturer
            await manufacturer.connect(owner).ajouterDistributeur(distributor.target);

            return { owner, distrib2, pharmacy, manufacturer, distributor };
        } catch (error) {
            console.error("Error deploying contracts:", error);
            throw error;
        }       
    }

    it("Assigner l'addresse du Fabricant", async function () {
        const { manufacturer, distributor } = await loadFixture(deployManufacturerFixture);
        const manufacturerAddress = await distributor.manufacturerContract(); 
        console.log("Manufacturer address in Distributor contract:", manufacturerAddress);
        expect(manufacturerAddress).to.equal(manufacturer.target);
      });
      
      it("Doit assigner le déployeur comme Distributeur autorisé", async function () {
        const { distributor, owner } = await loadFixture(deployManufacturerFixture);
        expect(await distributor.distributeurAutorise(owner.address)).to.equal(true);
      });

      it("Créer une expédition", async function () {
        const { distributor, owner, pharmacy } = await loadFixture(deployManufacturerFixture);
        await distributor.connect(owner).ajouterPharmacy(pharmacy);
        await distributor.connect(owner).creerExpedition(1, pharmacy, "Expedition Reussie");
        
        // Récupérer les détails de l'expédition
        const exp = await distributor.getExpeditionDetails(1);
        console.log("Info sur L'Expedition:", exp);
        
        expect(exp.idMedicament).to.equal(1);
        expect(exp.toPharmacy).to.equal(pharmacy.address);
      });

      it("Verifier Transfert Medicament", async function () {
        const { distributor, owner } = await loadFixture(deployManufacturerFixture);
        expect(await distributor.connect(owner).verifierTransfertMedicament(1))
          .to.equal(true);
      });

      it("Verifier si le produit est deja livré", async function () {
        const { distributor } = await loadFixture(deployManufacturerFixture);
        await distributor.markAsDelivered(1);
        
        await expect(distributor.markAsDelivered(1))
          .to.be.revertedWith("Produit deja delivre");
      });

  });