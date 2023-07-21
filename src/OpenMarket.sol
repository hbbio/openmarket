// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint256) private _tokenPrice;

    address private _existingCollection;

    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTPriceUpdated(uint256 indexed tokenId, uint256 price);
    event NFTSold(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );

    constructor(
        string memory name,
        string memory symbol,
        address existingCollection
    ) ERC721(name, symbol) {
        _existingCollection = existingCollection;
    }

    function mintNFT(string memory tokenURI, uint256 price) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _tokenPrice[tokenId] = price;
        _tokenIdCounter.increment();
        emit NFTListed(tokenId, price);
    }

    function setPrice(uint256 tokenId, uint256 price) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        _tokenPrice[tokenId] = price;
        emit NFTPriceUpdated(tokenId, price);
    }

    function buyNFT(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        require(_tokenPrice[tokenId] > 0, "NFT is not listed for sale");
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "You are not approved to buy this NFT"
        );
        require(msg.value >= _tokenPrice[tokenId], "Insufficient payment");

        address seller = ownerOf(tokenId);
        safeTransferFrom(seller, msg.sender, tokenId);
        uint256 price = _tokenPrice[tokenId];
        _tokenPrice[tokenId] = 0; // Reset price after purchase
        payable(seller).transfer(price);
        emit NFTSold(tokenId, seller, msg.sender, price);
    }

    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenPrice[tokenId];
    }

    function getExistingCollection() external view returns (address) {
        return _existingCollection;
    }
}
