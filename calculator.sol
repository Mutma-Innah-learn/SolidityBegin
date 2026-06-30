//SPDX-License-Identifier: MIT

pragma solidity ^0.8.34;

contract calculator{

    uint256 public result;

    function addCalc(uint256 num1, uint256 num2) internal {

        result = num1 + num2;
    }

    function subCalc(uint256 num1, uint256 num2) internal {
 
        result = num1 - num2;
    }
}

contract AdvancedCalc is calculator {

    function mulCalc(uint256 num1, uint256 num2) internal{

        result = num1 * num2;
    }

    function divCalc(uint256 num1, uint256 num2) internal{

        result = num1 / num2;
    }

    function perform(uint num1, uint num2, uint opcode) public{
        
        if(opcode == 1) addCalc(num1, num2);
        else if(opcode == 2) subCalc(num1, num2);
        else if(opcode == 3) mulCalc(num1, num2);
        else if(opcode == 4) divCalc(num1, num2);
        else revert("Invalid Operator");
    }
}

 
