require("@nomicfoundation/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers");
require('dotenv').config();

const SEPOLIA_URL = process.env.SEPOLIA_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  paths:{
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts:'./front-end/src/artifacts'
  },
  defaultNetwork: "hardhatNetwork",
  networks: {
    hardhatNetwork: {
      url:"http://127.0.0.1:8545",
      chainId: 31337,
   }
  }
};
