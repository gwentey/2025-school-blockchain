import { useState } from "react";
import "./Form.css"

const RetirerArgent=({state})=>{
    const [montant, setMontant] = useState('');

    const retirerArgent = async(event)=>{
        event.preventDefault();
        const {contract} = state;
        const montant = document.querySelector("#montant").value;

        const tx = await contract.RetirerArgent(montant);
        await tx.wait();

        console.log("Transaction succefuly")
        console.log(montant);
        console.log(state);

        // Step 4: Reset the state (and thus the input fields)
        setMontant('');
    };
    const handleMontantChange = (event) => setMontant(event.target.value);

    return(
        <div className="center">
        <h1>Retirer argent </h1>
         <form onSubmit={retirerArgent}>
           <div className="inputbox">
                <input type="text" required="required" id="montant"
                value={montant} onChange={handleMontantChange} />
                <span>Montant À RETIRER</span>
           </div>
           <div className="inputbox">
             <input type="submit" value="RETIRER"  disabled={!state.contract}/>
           </div>
         </form>
         </div>
    )
}
export default RetirerArgent;