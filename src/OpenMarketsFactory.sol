// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

import "./OpenMarket.sol";

/**
 * @title OpenMarketsFactory is the factory for OpenMarkets.
 * @author Henri Binsztok
 * @notice NFT, Marketplace, Factory
 */
contract OpenMarketsFactory {
    mapping(address => address) private _collectionToMarketplace;
    address[] private _marketplaces;

    /**
     * MarketplaceCreated is emitted when a new marketplace is created.
     * @param collection address
     * @param marketplace address
     */
    event MarketplaceCreated(
        address indexed collection,
        address indexed marketplace
    );

    /**
     * @dev isNFT returns true if the address seems to be an NFT collection. We only
     * check the presence of `totalSupply` since it has no parameters and consumes
     * less gas. We opted for this to prevent people from adding wrong addresses in
     * the marketplace creation.
     * @param _collection address of the collection
     */
    function isNFT(address _collection) private view returns (bool) {
        (bool success, ) = _collection.staticcall(
            abi.encodeWithSignature("totalSupply()")
        );
        return success;
    }

    /**
     * @dev createMarketplace creates a new marketplace for a NFT collection.
     * It is permissionless, anyone can sponsor the creation of the marketplace
     * by paying the gas, since it gives no specific rights to the caller.
     * @param _collection address of the collection
     */
    function createMarketplace(address _collection) external {
        require(isNFT(_collection));
        require(_collection != address(0), "Invalid collection address");
        require(
            _collectionToMarketplace[_collection] == address(0),
            "Marketplace already exists"
        );

        OpenMarket marketplace = new OpenMarket(_collection);
        _collectionToMarketplace[_collection] = address(marketplace);
        _marketplaces.push(address(marketplace));

        emit MarketplaceCreated(_collection, address(marketplace));
    }

    /**
     * @dev getMarketplace retrieves the marketplace address for a given NFT collection.
     * @param collection address
     */
    function getMarketplace(
        address collection
    ) external view returns (address) {
        return _collectionToMarketplace[collection];
    }

    /**
     * @dev getAllMarketplaces returns the list of all marketplaces created by the factory.
     */
    function getAllMarketplaces() external view returns (address[] memory) {
        return _marketplaces;
    }
}
