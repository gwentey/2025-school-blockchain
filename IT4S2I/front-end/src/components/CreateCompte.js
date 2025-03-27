import { useState } from "react";
import "./Form.css"

const CreateCompte=({state})=>{
    const [name, setName] = useState('');
    const [montant, setMontant] = useState('');

    const createCompte = async(event)=>{
        event.preventDefault();
        const {contract} = state;

        const name = document.querySelector("#name").value;
        const montant = document.querySelector("#montant").value;

        const tx = await contract.creerCompte(name, montant);
        await tx.wait();

        console.log("Transaction succefuly")
        console.log(name, montant);
        console.log(state);

        // Step 4: Reset the state (and thus the input fields)
        setName('');
        setMontant('');
    };

    const handleNameChange = (event) => setName(event.target.value);
    const handleMontantChange = (event) => setMontant(event.target.value);

    return(
        <div className="center">
        <h1>CREER COMPTE SUR LA BLOCKCHAIN - BANK </h1>
         <form onSubmit={createCompte}>
           <div className="inputbox">
                <input type="text" required="required" id="name" 
                value={name} onChange={handleNameChange} />
                <span>Person Name</span>
           </div>
           <div className="inputbox">
                <input type="text" required="required" id="montant"
                value={montant} onChange={handleMontantChange} />
                <span>Deposit Montant</span>
           </div>
           <div className="inputbox">
             <input type="submit" value="ADD"  disabled={!state.contract}/>
           </div>
         </form>
         </div>
    )
}
export default CreateCompte;