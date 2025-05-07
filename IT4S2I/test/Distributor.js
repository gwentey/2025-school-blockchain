const { expect } = require("chai");

describe("Bank Test", function () {
    it("Should deploy Bank contract", async function () {
        const [owner] = await ethers.getSigners();
        const Bank = await ethers.deployContract("DefiBank"); 
    });

    it("Should Create Compte", async function () {
        const [owner] = await ethers.getSigners();
        const[,,newOwner] = await ethers.getSigners();

        const Bank = await ethers.deployContract("DefiBank"); 
        await Bank.connect(owner).creerCompte("John Doe", 1000);
   
        const compte = await Bank.comptes(owner.address);
        expect(compte.nom).to.equal("John Doe");
        expect(compte.solde).to.equal(1000);
    });

    it("Should deposit Money", async function () {
        const [owner] = await ethers.getSigners();
        const Bank = await ethers.deployContract("DefiBank"); 
        await Bank.connect(owner).creerCompte("John Doe", 1000);
        await Bank.connect(owner).DeposerArgent(500);
        
        const compte = await Bank.comptes(owner.address);
        expect(compte.solde).to.equal(2015);
    });

    it("Should withdraw Money", async function () {
        const [owner] = await ethers.getSigners();
        const Bank = await ethers.deployContract("DefiBank"); 

        await Bank.connect(owner).creerCompte("John Doe", 1000);
        await Bank.connect(owner).RetirerArgent(100);
        
        const compte = await Bank.comptes(owner.address);
        expect(compte.solde).to.equal(900);
    });

    it("Should consult solde", async function () {
        const [owner] = await ethers.getSigners();
        const Bank = await ethers.deployContract("DefiBank"); 

        await Bank.connect(owner).creerCompte("John Doe", 1000);
        await Bank.connect(owner).ConsulterSolde();
        
        const compte = await Bank.comptes(owner.address);
        expect(compte.solde).to.equal(1000);
    });

    it("Should Transfer Money", async function () {
        const [owner, newOwner] = await ethers.getSigners();

        const Bank = await ethers.deployContract("DefiBank"); 
        await Bank.connect(owner).creerCompte("John Doe", 1000);
        await Bank.connect(newOwner).creerCompte("Eddy Kiomba", 0);

        await Bank.connect(owner).TransfererArgent(newOwner.address, 500);
        const compte = await Bank.comptes(newOwner.address);
        expect(compte.solde).to.equal(500);
    });
});