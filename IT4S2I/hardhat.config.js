require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  paths:{
    artifacts:'./front-end/src/artifacts'
  },
  defaultNetwork: "seopiola",
  networks: {
    hardhatNetwork: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
    },
    seopiola: {
      url:"https://sepolia.infura.io/v3/71a300bf32a24e07be782ad43a4e4ce1",
      accounts: ["ee4211451ea59419e90eae9f59ca30a4529f3e193402f19552dadc104dcf134b"]
    }
  }
};

//BankModule#DefiBank - 0x5FbDB2315678afecb367f032d93F642f64180aa3
//0x5FbDB2315678afecb367f032d93F642f64180aa3