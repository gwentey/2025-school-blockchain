const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const BankModule = buildModule("BankModule", (m) => {
    const bank = m.contract("DefiBank");
    return { bank };
});

module.exports = BankModule;
// Compare this snippet from IT4S2I/ignition/modules/Bank.js:
//0x5FbDB2315678afecb367f032d93F642f64180aa3