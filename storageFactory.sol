// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./simpleStorage.sol"; //need all functionality to import, but ddont need to interact
contract storageFactory{
  
  simpleStorage[] public simpleStorageArray;

  function createSimpleStorage() public {
    simpleStorage ssContract = new simpleStorage();
    simpleStorageArray.push(ssContract);
  }

  function sfStore(uint256 _ssIndex, uint256 _ssNumber) public { 
    //interacting with store function in ss
    //Adress
    //Application Binary Interface
   simpleStorage ssContract = simpleStorage(address(simpleStorageArray[_ssIndex]));
   ssContract.store(_ssNumber, _ssNumber);
 
  }

  function sfGet(uint256 _ssIndex) public view returns(uint256, uint256, uint256){
    return simpleStorage(address(simpleStorageArray[_ssIndex])).retrieve();
    
  }
}