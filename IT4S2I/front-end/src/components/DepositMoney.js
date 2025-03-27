import { useState } from "react";
import "./Form.css"

const DepositMoney=({state})=>{
    const [montant, setMontant] = useState('');

    const deposerMoney = async(event)=>{
        event.preventDefault();
        const {contract} = state;
        
        const montant = document.querySelector("#montant").value;

        const tx = await contract.DeposerArgent(montant);
        await tx.wait();

        console.log("Transaction succefuly")
        console.log(montant);
        console.log(state);

        // Step 4: Reset the state (and thus the input fields)
        alert(`Vous avez déposé ${montant} Wei`);
        setMontant('');
    };
    const handleMontantChange = (event) => setMontant(event.target.value);

    return(
        <div className="center">
        <h1>DEPOSER ARGENT SUR LA BLOCKCHAIN</h1>
         <form onSubmit={deposerMoney}>
           <div className="inputbox">
                <input type="text" required="required" id="montant"
                value={montant} onChange={handleMontantChange} />
                <span>Montant À DEPOSER</span>
           </div> 
           <div className="inputbox">
             <input type="submit" value="DEPOSER"  disabled={!state.contract}/>
           </div>
         </form>
         </div>
    )
}
export default DepositMoney;