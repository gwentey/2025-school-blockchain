import { useState } from "react";
import { ethers } from "ethers";
import "./Form.css"

const TransfererMoney=({state})=>{
    const [receiver, setReceiver] = useState('');
    const [montant, setMontant] = useState('');

    const transfererMoney = async(event)=>{
        event.preventDefault();
        const {contract} = state;

        try {
            const signer = state.signer || new ethers.BrowserProvider(window.ethereum).getSigner();
            const contractWithSigner = contract.connect(signer);

            //const receiver = document.querySelector("#receiver").value;
            //const montant = document.querySelector("#montant").value;

            const tx = await contractWithSigner.TransfererArgent(receiver, montant);
            await tx.wait();

            console.log("Transaction succefuly FOR MONEY")
            console.log(receiver, montant);
            console.log(state);

             // Step 4: Reset the state (and thus the input fields)
            setReceiver('');
            setMontant('');
            
        } catch (error) {
            console.error("Error transferring product:", error);
            alert("An error occurred while transferring the product.");
        }     
    };
    
    //const handleAddressChange = (event) => setReceiver(event.target.value);
    //const handleMontantChange = (event) => setMontant(event.target.value);

    return(
        <div className="center">
        <h1>TRANSFERER ARGENT </h1>
         <form onSubmit={transfererMoney}>
           <div className="inputbox">
                <input type="text"
                value={receiver} onChange={(e) => setReceiver(e.target.value)}
                required />
                <span>Address Receiver</span>
           </div>
           <div className="inputbox">
            <input type="number"
                value={montant}
                onChange={(e) => setMontant(e.target.value)}
                required />
            <span>Montant à Transferer Montant</span>
            </div>

           <div className="inputbox">
             <input type="submit" value="TRANSFER" disabled={!state.contract}/>
           </div>
         </form>
         </div>
    )
}
export default TransfererMoney;