const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const SupplyChainModule = buildModule("SupplyChainModule", (m) => {
  const manufacturer = m.contract("Manufacturer");
  const distributor = m.contract("Distributors", [manufacturer]);
  const pharmacy = m.contract("Pharmacy");
  const patient = m.contract("Patient");
  return { manufacturer, distributor, pharmacy, patient };
});

module.exports = SupplyChainModule;