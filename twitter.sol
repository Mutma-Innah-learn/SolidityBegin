//SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract twitter{
 
     address owner;

    uint256 public maxTweet = 280;

     struct tweetStruct{

        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
        uint256 id;
    }

    mapping(address => tweetStruct[])internal tweetmap;

    
    constructor(){
      owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Unauthorised access");
     _;
    }

    function creatTweet(string memory _tweet) public { //storing tweet parameter in temporary storage
        tweetStruct memory _tweetStruct = tweetStruct({
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0,
            id: tweetmap[msg.sender].length});

        tweetmap[msg.sender].push(_tweetStruct); //msg object with sender property rep your sddress
        require(bytes(_tweet).length <= maxTweet, "Tweet too long");
    }

    function getTweet(uint _i) public view returns(tweetStruct memory){
        return tweetmap[msg.sender][_i];

    }

    function getAllTweet()  internal /*public*/ view returns(tweetStruct[] memory){
        return tweetmap[msg.sender];
    }



    function changeTL(uint256 newTL) public onlyOwner {
        maxTweet = newTL;
    }

    function likeTweet(uint256 id, address author) external{
        require(msg.sender != author, "You cannot like your own tweet");
        require(tweetmap[author][id].id == id, "Tweet does not exist");
      tweetmap[author][id].likes++;
    }

    function unlikeTweet( uint256 id, address author) external{
        require(tweetmap[author][id].id == id, "Tweet does not exist");
         require(tweetmap[author][id].likes > 0, "tweet has no likes");
        tweetmap[author][id].likes--;
    }

}
