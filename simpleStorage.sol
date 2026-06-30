// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0; 

contract simpleStorage {

    uint256 favouriteNumber; //access modiefier set to internal, similar to default in java
    uint256 leastNumber; //initialised to 0
    uint256 sumNumber;

    struct People{
        //struct defines new type, almost like creating  new objects
        uint256 favouriteNumber;
        string name;
    }

/*similar to instantiating an object of a non static class in java
     People public person = People({favouriteNumber: 2, name: "Nefer"}); */

    //way of storing a list of an object or type
    People[] public people; //dynamic array

    //takes a key and returns whatever variable it is mapped too
    mapping(string => uint256) public nameToFavouriteNumber;
    mapping(uint256 => string) public favouriteNumberToName;
    
    function store(uint256 _favouriteNumber, uint256 _leastNumber) public {
        favouriteNumber = _favouriteNumber;
        leastNumber = _leastNumber;
        sumNumber = favouriteNumber + leastNumber;
    }
    
    function retrieve() public view returns (uint256, uint256, uint256){ //view is read_only while pure is mathematical
      
        return (favouriteNumber, leastNumber, sumNumber);

    }

    function addPerson(string memory _name, uint256 _favouriteNumber) public { 
        //memory: data only stored during the execution of function, sstorage: data persists after execution
        people.push(People({favouriteNumber: _favouriteNumber, name: _name}));
        nameToFavouriteNumber[_name] = _favouriteNumber;
        favouriteNumberToName[_favouriteNumber] = _name;
    }

}
