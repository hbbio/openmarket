// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

// import "@openzeppelin/contracts/access/Ownable.sol";

import "./OpenMarket.sol";

// is Ownable
contract OpenMarketsFactory {
    mapping(address => address) private _collectionToMarketplace;
    address[] private _marketplaces;

    event MarketplaceCreated(
        address indexed collection,
        address indexed marketplace
    );

    function isNFT(address _collection) public view returns (bool) {
        (bool success, ) = _collection.staticcall(
            abi.encodeWithSignature("tokenURI(uint256)", 0)
        );
        return success;
    }

    // @todo onlyOwner?
    function createMarketplace(address collection) external {
        // require(isNFT(collection));
        require(collection != address(0), "Invalid collection address");
        require(
            _collectionToMarketplace[collection] == address(0),
            "Marketplace already exists"
        );

        OpenMarket marketplace = new OpenMarket(collection);
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
