const {
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { expect } = require("chai");

  describe("Bank Test", function () {   
    async function deployBankFixture() {
    const [owner, newOwner] = await ethers.getSigners();
    const bank = await ethers.deployContract("DefiBank");
    return { bank, owner, newOwner };
    }

    it("Should deploy Bank contract", async function () {
      const { bank } = await loadFixture(deployBankFixture);
    });

    it("Should Create Compte", async function () {
      const { bank, owner } = await loadFixture(deployBankFixture);
      await bank.connect(owner).creerCompte("John Doe", 1000);
      const compte = await bank.comptes(owner.address);
      expect(compte.nom).to.equal("John Doe");
      expect(compte.solde).to.equal(1000);
    });

    it("Should deposit Money", async function () {
      const { bank, owner } = await loadFixture(deployBankFixture);
      await bank.connect(owner).creerCompte("John Doe", 1000);
      await bank.connect(owner).DeposerArgent(200);
      const compte = await bank.comptes(owner.address);
      expect(compte.solde).to.equal(1406);
    });

    it("Should withdraw Money", async function () {
        const { bank, owner } = await loadFixture(deployBankFixture);
        await bank.connect(owner).creerCompte("John Doe", 1000);
        await bank.connect(owner).RetirerArgent(100);
        const compte = await bank.comptes(owner.address);
        expect(compte.solde).to.equal(900);
        });
    
        it("Should consult solde", async function () {
        const { bank, owner } = await loadFixture(deployBankFixture);
        await bank.connect(owner).creerCompte("John Doe", 1000);
        await bank.connect(owner).ConsulterSolde();
        const compte = await bank.comptes(owner.address);
        expect(compte.solde).to.equal(1000);
        });  

        it("Should Transfer Money", async function () {
        const { bank, owner, newOwner } = await loadFixture(deployBankFixture);
        await bank.connect(owner).creerCompte("John Doe", 1000);
        await bank.connect(newOwner).creerCompte("Eddy Kiomba", 0);
        await bank.connect(owner).TransfererArgent(newOwner.address, 500);
        const compte = await bank.comptes(newOwner.address);
        expect(compte.solde).to.equal(500);
        });
 });
