// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OpenMarket is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint256) private _tokenPrice;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

    function mintNFT(string memory tokenURI, uint256 price) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _tokenPrice[tokenId] = price;
        _tokenIdCounter.increment();
    }

    function setPrice(uint256 tokenId, uint256 price) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        _tokenPrice[tokenId] = price;
    }

    function buyNFT(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "You are not approved to buy this NFT"
        );
        require(msg.value >= _tokenPrice[tokenId], "Insufficient payment");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);
        _tokenPrice[tokenId] = 0; // Reset price after purchase
        payable(seller).transfer(msg.value);
    }

    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenPrice[tokenId];
    }
}
