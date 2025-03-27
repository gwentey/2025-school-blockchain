// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
//import "hardhat/console.sol";

contract DefiBank{

    address public owner;
    struct CompteBancaire {
        address titulaire;
        string nom;
        uint256 solde;
    }

    mapping(address => CompteBancaire) public comptes;

    modifier onlyOwner(){
        require(msg.sender == owner, "Access denied");
        _;
    }
    constructor(){
        owner = msg.sender;
    }

    event AccountCreated(address indexed user);
    event DepositMade(address indexed user, uint256 amount);
    event WithdrawalMade(address indexed user, uint256 amount);
    event TransferMade(address indexed sender, address indexed receiver, uint256 amount);
    event BonusApplied(address indexed user, uint256 interest);

    //Creer Compte Bancaire 
    function creerCompte(string memory _name, uint256 _montant) public {
        require(comptes[msg.sender].titulaire == address(0), "Compte existant");
        comptes[msg.sender] = CompteBancaire(msg.sender, _name, _montant);
        //emit AccountCreated(msg.sender);
    }

    // Deposer des fonds dans le comptes
    function DeposerArgent(uint256 _montant) public payable {
        require(comptes[msg.sender].titulaire != address(0), "Compte inexistant");
        comptes[msg.sender].solde += _montant;
        
        uint bonus = CalculBonus(_montant);
        if(bonus > 0){
            comptes[msg.sender].solde += bonus;
            //emit BonusApplied(msg.sender, bonus);
            }
        
        comptes[msg.sender].solde += _montant;
        emit DepositMade(msg.sender, _montant);
    }

    // Retirer des fonds du compte
    function RetirerArgent(uint256 _montant) public onlyOwner() {
        require(comptes[msg.sender].titulaire != address(0), "Compte inexistant");
        require(comptes[msg.sender].solde >= _montant, "Solde insuffisant");
        //console.log("Retirer %s de %s", _montant, msg.sender);
        comptes[msg.sender].solde -= _montant;
        //payable(msg.sender).transfer(_montant);
        emit WithdrawalMade(msg.sender, _montant);
    }

    //Consulter le solde bancaire
    function ConsulterSolde() public view returns(uint256) {
        require(comptes[msg.sender].titulaire != address(0), "Compte inexistant");
        //console.log("Le solde de %s est de %s", msg.sender, comptes[msg.sender].solde);
        return comptes[msg.sender].solde;
    }

    //Transferer d'un compte à un autre
    function TransfererArgent(address _receiver, uint256 _montant) public onlyOwner() {
        require(comptes[msg.sender].titulaire != address(0), "Compte inexistant");
        require(comptes[_receiver].titulaire != address(0), "Compte inexistant");
        require(comptes[msg.sender].solde >= _montant, "Solde insuffisant");
        //console.log("Transfering %s to %s",msg.sender, _montant, _receiver);
        comptes[msg.sender].solde -= _montant;
        comptes[_receiver].solde += _montant;
        emit TransferMade(msg.sender, _receiver, _montant);
    }

    function PretArgent(address _receiver, uint256 _montant) public {
        require(comptes[msg.sender].titulaire != address(0), "Compte inexistant");
        require(comptes[_receiver].titulaire != address(0), "Compte inexistant");
        require(comptes[msg.sender].solde >= _montant, "Solde insuffisant");
        comptes[msg.sender].solde -= _montant;
        comptes[_receiver].solde += _montant;
        emit TransferMade(msg.sender, _receiver, _montant);
    }

    function CalculBonus(uint256 _montant) public pure returns(uint256){
        if (_montant <=100){
            return (_montant * 5) / 100;
        }else if (_montant <= 500){
            return (_montant * 3) / 100;
        }else{
            return (_montant * 2) / 100;
        }
    }
}