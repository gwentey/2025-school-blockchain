// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract Vehicule {
    uint public speed; 

    function setSpeed(uint _speed) public {
        speed = _speed;
    }

    function getSpeed() public view returns (uint) {
        return (speed);
    }
}

contract Automobile is Vehicule {
    uint public numberOfWheels;

    function setNumberOfWheels(uint _numberOfWheels) public {
        numberOfWheels = _numberOfWheels;
    }

    function getNumberOfWheels() public view returns (uint) {
        return numberOfWheels;
    }
}

contract PublicTransportation is Vehicule{ 
    uint public numberOfPlaces;

    function setNumberOfPlaces(uint _numberOfPlaces) public {
        numberOfPlaces = _numberOfPlaces;
    }

    function getNumberOfPlaces() public view returns (uint) {
        return numberOfPlaces;
    }
}

contract Bus is Automobile, PublicTransportation{
    string[] public stops;

    constructor (string[] memory _stops) {
        stops = _stops;
    }

    function setStops (string[] memory _stops) public {
        stops = _stops;
    }

    function getBusInfo() public view returns (uint, uint, uint, string[] memory) {
        return (speed, numberOfWheels, numberOfPlaces, stops);
    }
} 