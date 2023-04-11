// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Open Zeppelin:

// Open Zeppelin NFT guide:
// https://docs.openzeppelin.com/contracts/4.x/erc721

// Open Zeppelin ERC721 contract implements the ERC-721 interface and provides
// methods to mint a new NFT and to keep track of token ids.
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol

// Open Zeppelin ERC721URIStorage extends the standard ERC-721 with methods
// to hold additional metadata.
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// TODO:
// Other openzeppelin contracts might be useful. Check the Utils!
// https://docs.openzeppelin.com/contracts/4.x/utilities

// MODIFYING FUNCTIONS see "Calling super" https://docs.openzeppelin.com/contracts/4.x/extending-contracts

// Local imports:

// TODO:
// You might need to adjust paths to import accordingly.

// Import BaseAssignment.sol
import "../BaseAssignment.sol";

// Import INFTMINTER.sol
import "./INFTMINTER.sol";

// You contract starts here:
// You need to inherit from multiple contracts/interfaces.
contract Assignment1 is INFTMINTER, ERC721URIStorage, BaseAssignment {
    // TODO:
    // Add the ipfs hash of an image that you uploaded to IPFS.
    string IPFSHash = "QmQFfsy2fwKrxryS3Y6Y3s1hG8Kr7LLso88TJZhKCwdUVL";

    // Total supply.
    uint256 public totalSupply;

    // Current price. See also: https://www.cryps.info/en/Gwei_to_ETH/1/
    uint256 private price = 0.001 ether;

    // TODO:
    // Add more state variables, as needed.
    bool private saleStatus; //true means active, false means inactive

    string baseURI = "My beautiful artwork #"";
    uint id; //increment after every mint


    // TODO:
    // Adjust the Token name and ticker as you like.
    // Very important! The validator address must be passed to the
    // BaseAssignment constructor (already inserted here).
    constructor()
    {   ERC721("Token", "TKN")
        BaseAssignment(0x80A2FBEC8E3a12931F68f1C1afedEf43aBAE8541)
    }

    //auskommentieren ->
    Inherited functions and properties from base assignment:
    ---------------------------------------------------------
    _owner
    _validator
    getOwner()
    isValidator(address _address) returns (bool)

    Inherited functions and properties from ERC721 (OpenZeppelin):
    ------------------------------------------------------------
    balanceOf(address owner) returns (uint256)
    ownerOf(uint256 tokenId) returns (address)

    tokenURI(uint256 tokenId) returns (string memory)
    //_setTokenURI(uint256 tokenId, string memory _tokenURI) //from ERC721URIStorage

    approve(address to, uint256 tokenId)
    safeTransferFrom(address from, address to, uint256 tokenId)

    _exists(uint256 tokenId)

    _isApprovedOrOwner (address spender, uint256 tokenId) //Idea: modifiy this so that also returns true for spender == _validator
    //alternative: use isValidator in require statement 

    _safeMint(address to, uint256 tokenId)
    _burn(uint256 tokenId)

    // <- auskommentieren

    // Mint a nft and send to _address.
    function mint(address _address) public payable returns (uint256) {
        // Your code here!
        // 1. First, check if the conditions for minting are met.
        // 2. Then increment total supply and price.
        // 3. Get the current token id, after incrementing it.
        // Hint: Open Zeppelin has methods for this.
        // 4. Mint the token.
        // Hint: Open Zeppelin has a method for this.
        // 5. Compose the token URI with metadata info.
        // You might use the helper function getTokenURI.
        // Make sure to keep the data in "memory."
        // Hint: Learn about data locations.
        // https://dev.to/jamiescript/data-location-in-solidity-12di
        // https://solidity-by-example.org/data-locations/
        // 6. Set encoded token URI to token.
        // Hint: Open Zeppelin has a method for this.
        // 7. Return the NFT id.

        //use _mint
        require(msg.value >= price);
        require(saleStatus);

        _safeMint(_address, id);

        string tokenURI = getTokenURI(id, msg.sender); //Set the new owner to the address of the current minter.

        _setTokenURI(tokenId, tokenURI); //inherited from ERC721URIStorage


        id ++;
        totalSupply++;
        price = price + 0.0001 ether; //task c); To be clarified: Price increases for everyone or individually? - as far as I understand it for everyone as price is stored in variable and not mapping of prices to owners. 
    }

    // TODO:
    // Other methods of the INFTMINTER interface to be added here.
    // Hint: all methods of an interface are external, but here you might
    // need to adjust them to public.

    // Burn a nft. DONE 
    function burn(uint256 tokenId) external payable{
        //modify _burn 
        require(msg.sender == ownerOf(tokenId));
        _burn(tokenId);
        totalSupply--;
    };
    

    // Withdraw all funds to owner.
    function withdraw(uint256 amount) external{
        receivingAddress = msg.sender;
        require(msg.sender == _owner || isValidator(msg.sender) );
        require(address(this).balance >= amount);
        (bool success, bytes memory data)= receivingAddress.call{value: amount}("");
    };

    // Flip sale status. 
    function flipSaleStatus() external {
        require(msg.sender == _owner || isValidator(msg.sender) );
        saleStatus = !saleStatus;
    };

    // Get sale status. DONE
    function getSaleStatus() external view returns (bool){
        return saleStatus;
    };

    // Get current price. DONE
    function getPrice() external view returns (uint256) {
        return price;
    };

    // Get total supply. DONE
    function getTotalSupply() external view returns (uint256){
        return totalSupply;
    };

    // Get IPFS hash. DONE  
    function getIPFSHash() external view returns (string memory){
        return IPFSHash;
    };


    //additional self-created functions
    resetId: set id back to 0

    /*=============================================
    =                   HELPER                  =
    =============================================*/

    // Get tokenURI for token id
    function getTokenURI(
        uint256 tokenId,
        address newOwner
    ) public view returns (string memory) {
        // Build dataURI.
        // string name = string.concat(baseURI, id.toString()); EVTL SCHRITT NICHT NOTWENDIG, SIEHE UNTEN
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "My beautiful artwork #',
            tokenId.toString(),
            '"', // Name of NFT with id.
            '"hash": "',
            IPFSHash,
            '",', // Define hash of your artwork from IPFS.
            '"by": "',
            getOwner(),
            '",', // Address of creator.
            '"new_owner": "',
            newOwner,
            '"', // Address of new owner.
            "}"
        );

        // Encode dataURI using base64 and return it.
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    /*=====         End of HELPER         ======*/
}
