require("@nomicfoundation/hardhat-toolbox");
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
   },
    sepolia: {
      url:"https://sepolia.infura.io/v3/71a300bf32a24e07be782ad43a4e4ce1",
      accounts:[PRIVATE_KEY]
    }
  }
};
