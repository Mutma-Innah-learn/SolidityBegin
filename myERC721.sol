//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract myERC721 is ERC721,Ownable{

    uint256 private _nextTokenID;
    constructor(address initialOwner)
        ERC721("myERC721","E721")
        Ownable(initialOwner)
        
        {}

    function safeMint(address to) public payable onlyOwner{
        uint256 tokenID = _nextTokenID++;
        _safeMint(to, tokenID);


    }   
}
