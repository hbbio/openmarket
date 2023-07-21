// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketplace is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint256) private _tokenPrice;
    IERC721Enumerable private _existingCollection;

    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTPriceUpdated(uint256 indexed tokenId, uint256 price);
    event NFTSold(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );

    constructor(address existingCollection) {
        _existingCollection = IERC721Enumerable(existingCollection);
    }

    function mintNFT(string memory tokenURI, uint256 price) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _existingCollection.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        _tokenPrice[tokenId] = price;
        emit NFTListed(tokenId, price);
    }

    function setPrice(uint256 tokenId, uint256 price) external {
        require(_tokenPrice[tokenId] > 0, "NFT is not listed for sale");
        require(
            _existingCollection.ownerOf(tokenId) == msg.sender,
            "You are not the owner"
        );
        _tokenPrice[tokenId] = price;
        emit NFTPriceUpdated(tokenId, price);
    }

    function buyNFT(uint256 tokenId) external payable {
        require(_tokenPrice[tokenId] > 0, "NFT is not listed for sale");
        require(
            _existingCollection.ownerOf(tokenId) != address(this),
            "NFT is not listed for sale"
        );
        require(
            _existingCollection.getApproved(tokenId) == address(this) ||
                _existingCollection.isApprovedForAll(
                    _existingCollection.ownerOf(tokenId),
                    address(this)
                ),
            "You are not approved to buy this NFT"
        );
        require(msg.value >= _tokenPrice[tokenId], "Insufficient payment");

        address seller = _existingCollection.ownerOf(tokenId);
        _existingCollection.safeTransferFrom(seller, msg.sender, tokenId);
        uint256 price = _tokenPrice[tokenId];
        _tokenPrice[tokenId] = 0; // Reset price after purchase
        payable(seller).transfer(price);
        emit NFTSold(tokenId, seller, msg.sender, price);
    }

    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        return _tokenPrice[tokenId];
    }

    function getExistingCollection() external view returns (address) {
        return address(_existingCollection);
    }
}
