// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Tableau {
    struct Person {
        string name;
        uint age;
    }

    uint public peopleCount=1;
    Person[] public people;
    mapping (uint => Person) public peopleMap;
  


    function addPerson(string memory _name, uint _age) public {
        //Ajout dans le Tableai
        people.push(Person(_name, _age));

        //Ajout dans le Mapping
        peopleMap[peopleCount] = Person(_name, _age);
        peopleCount++;

    }

    function getPerson(uint index) public view returns (string memory, uint) {
        require(index < people.length, "Index out of bounds");
        Person memory person = people[index];
        return (person.name, person.age);
    }

    // Lire une personne depuis le mapping
    function getPersonMap(uint id) public view returns (string memory, uint) {
        require(id < peopleCount, "ID not found");
        Person memory person = peopleMap[id];
        return (person.name, person.age);
    }
}