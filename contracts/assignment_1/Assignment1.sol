// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Import BaseAssignment.sol
import "../BaseAssignment.sol";

// Import INFTMINTER.sol
import "./INFTMINTER.sol";

// Create contract > define Contract Name
contract Assignment1 is INFTMINTER, ERC721URIStorage, BaseAssignment {
    // META VARIABLES
    using Counters for Counters.Counter;
    using Strings for uint256;
    using Strings for address;

    Counters.Counter private _tokenIds;

    // META VARIABLES
    string IPFSHash = "QmNMpYHLW3VKiTSb76yWDmwJsaKxqncyUaDxqLNDz3Ejp4"; // IPFS hash of the image

    uint256 private price = 0.001 ether; // Current price // = 0.001 ETH (https://www.cryps.info/en/Gwei_to_ETH/1/)
    bool public isSaleActive = true; // Is sale active

    uint256 public totalSupply; // Total supply

    // Make sure to set the validator address in the BaseAssignment constructor
    constructor()
        ERC721("Token", "TKN")
        BaseAssignment(0x80A2FBEC8E3a12931F68f1C1afedEf43aBAE8541)
    {}

    // mint a nft and send to _address
    function mint(address _address) public payable returns (uint256) {
        require(isSaleActive, "Sale is not active");
        require(msg.value >= price, "Paid price is not enough"); // paid price must be equal or greater than current price

        totalSupply++;
        price += 0.0001 ether; // increase price after each mint by 0.0001 ETH (100000 Gwei)

        // Get current token id, after incrementing it.
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        // Return token URI
        string memory tokenURI = getTokenURI(newItemId, _address);

        // Mint token
        _safeMint(_address, newItemId);
        // Set encoded token URI to token
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    // burn a nft
    function burn(uint256 tokenId) public payable {
        require(
            msg.sender == _owner || msg.sender == ownerOf(tokenId),
            "Only contract owner or NFT owner can burn tokens!"
        );

        require(msg.value >= 0.0001 ether, "Burn fee not paid"); // burn fee = 0.0001 ETH (100000 Gwei)

        totalSupply--;
        price -= 0.0001 ether; // decrease price after each burn by 0.0001 ETH (100000 Gwei)

        _burn(tokenId);
    }

    // flip sale status
    function flipSaleStatus() public {
        require(
            msg.sender == _owner || isValidator(msg.sender),
            "Only owner or assignment validator contract can flip sale status!"
        );

        isSaleActive = !isSaleActive;
    }

    // get sale status
    function getSaleStatus() public view returns (bool) {
        return isSaleActive;
    }

    // withdraw funds to msg.sender
    function withdraw(uint256 amount) public {
        require(
            msg.sender == _owner || isValidator(msg.sender),
            "Only owner or assignment validator contract can withdraw funds!"
        );

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // get current price
    function getPrice() public view returns (uint256) {
        return price;
    }

    // Get IPFS hash
    function getIPFSHash() public view returns (string memory) {
        return IPFSHash;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    /*=============================================
    =                   HELPER                  =
    =============================================*/

    // Get tokenURI for token id
    function getTokenURI(uint256 tokenId, address newOwner)
        public
        view
        returns (string memory)
    {
        // Build dataURI
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "My beautiful artwork #',
            tokenId.toString(),
            '"', // Name of NFT with id
            '"hash": "',
            IPFSHash,
            '",', // Define hash of your artwork from IPFS
            '"by": "',
            getOwner(),
            '",', // Address of creator
            '"new_owner": "',
            newOwner,
            '"', // Address of new owner
            "}"
        );

        // Encode dataURI using base64 and return
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
