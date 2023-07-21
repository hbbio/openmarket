// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./OpenMarket.sol";

contract NFTMarketplaceFactory is Ownable {
    mapping(address => address) private _collectionToMarketplace;
    address[] private _marketplaces;

    event MarketplaceCreated(
        address indexed collection,
        address indexed marketplace
    );

    function createMarketplace(address collection) external onlyOwner {
        require(collection != address(0), "Invalid collection address");
        require(
            _collectionToMarketplace[collection] == address(0),
            "Marketplace already exists"
        );

        NFTMarketplace marketplace = new NFTMarketplace(collection);
        _collectionToMarketplace[collection] = address(marketplace);
        _marketplaces.push(address(marketplace));

        emit MarketplaceCreated(collection, address(marketplace));
    }

    function getMarketplace(
        address collection
    ) external view returns (address) {
        return _collectionToMarketplace[collection];
    }

    function getAllMarketplaces() external view returns (address[] memory) {
        return _marketplaces;
    }
}
