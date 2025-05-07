# Exercice 2 

### Créer 3 contrats :
manufacture
Distributor 
Patient 
Parmacy 


### Créer une structure de médicament dans manufacture : 
Medicament ID, numéro de série , nom, adresse fabricant, date de fabrication, date de préemption, créer une bool pour savoir si ca été vendu ou pas. 

### Créer des évents 
Ajouter produit 
Ajouter fabricant
Supprimer produit 


### Créer un modificateur pour n’autorisé que le fabricant a éxécuté des fonctions

### Créer 3 fonctions
autoriserFabricant
revoquerFabricant
ajouterMedicament

Aller sur Remix
Cliquer sur Deploy and Remix pour déployer
https://remix.ethereum.org/


### Connecter
```
    seopiola: {
      url:"https://sepolia.infura.io/v3/71a300bf32a24e07be782ad43a4e4ce1",
      accounts: ["ee4211451ea59419e90eae9f59ca30a4529f3e193402f19552dadc104dcf134b"]
    }
```

on lance avec la commande :
npx hardhat node (pour démarrer je ne sais pas quoi)
npx hardhat ignition deploy ignition/modules/DrugTracking.js