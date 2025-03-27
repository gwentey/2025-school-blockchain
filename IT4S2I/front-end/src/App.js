import React from 'react';
import { Wallet } from 'lucide-react'
import { useState, useEffect} from 'react'
import { ethers } from "ethers";
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import contractJsonABI from './artifacts/contracts/Bank.sol/DefiBank.json'
import HomePage from './components/HomePage';
import NavBar  from './components/NavBar';  
import CreateCompte from './components/CreateCompte';
import DepositMoney from './components/DepositMoney';
import RetirerArgent from './components/RetirerArgent';
import TransfertArgent from './components/TransfertArgent';

import './App.css';

function App() {
  const [state, setState] = useState({ 
      provider:null, 
      signer:null, 
      contract:null })
  const [account, setAccount] = useState("MetaMask is Not connected");
    
  const[balance, setBalance] = useState("");
  const [txAddress, setTxAddress] = useState("");

  useEffect(()=>{
    const template = async() => {
      const contractAddress="0x5FbDB2315678afecb367f032d93F642f64180aa3";
      const contractABI= contractJsonABI.abi;
      
      try {
        const {ethereum} = window;
        if (!ethereum) {
          console.log("MetaMask is not installed");
          return; 
        }
        
        const Account = await ethereum.request({
          method:"eth_requestAccounts" // get the currently connected address
        })
        window.ethereum.on("accountsChanged",()=>{
          window.location.reload()
         })
        //change the state of the account.
        setAccount(Account[0]);
      
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        const contract = new ethers.Contract(
          contractAddress, 
          contractABI, 
          signer
        );
        setState({ contract, provider, signer });
        console.log("state:", state);  
        
        const balance = await provider.getBalance(Account[0]);
        setBalance(ethers.formatEther(balance) + ' ETH');
        console.log("balance", balance);

        //Get transaction address.
        const txAddress = await contract.getAddress()
        setTxAddress(txAddress);
        console.log("Tx address is", txAddress)

    } catch (error) {
        alert(error);
    }
  } 
    template();
  }, [])


  return (
    <div className="App">
      {/* Header stylé */}
      <header className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-4 flex justify-between items-center shadow-md rounded-b-xl sticky top-0 z-50">
        <div className="flex items-center space-x-3">
          <Wallet className="w-8 h-8" />
          <h1 className="text-xl font-semibold">S2I IT4-Course</h1>
        </div>
        <p className="text-sm">🔗 Connected MetaMask Address: {account}</p>
      </header>

      {/* Infos principales */}
      <div className="p-4">
        <ul className="space-y-2 text-gray-700 text-md">
          <li>💰 MetaMask balance: <span className="font-semibold">{balance}</span></li>
          <li>📍 Contract address: <span className="font-mono">{txAddress}</span></li>
        </ul>
      </div>

      <Router>
        <div>
          <NavBar />

          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/CreateCompte" element={<CreateCompte state={state} /> } />
            <Route path="/DepositMoney" element={<DepositMoney state={state} /> } />
            <Route path="/RetirerArgent" element={<RetirerArgent state={state} />} />
            <Route path="/TransfertArgent" element={<TransfertArgent state={state} />} />
          </Routes>
        </div>
      </Router>
    </div>
  );
}

export default App;