// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// is Ownable?
contract NFTMarketplace {
    uint256 public count;
    mapping(uint256 => uint256) public tokenPrice;
    mapping(uint256 => address) private _tokenSeller;
    IERC721Enumerable private _existingCollection;

    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTPriceUpdated(
        uint256 indexed tokenId,
        address seller,
        uint256 price
    );
    event NFTSold(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );

    constructor(address existingCollection) {
        _existingCollection = IERC721Enumerable(existingCollection);
    }

    // function mintNFT(string memory tokenURI, uint256 price) external onlyOwner {
    //     uint256 tokenId = _tokenIdCounter.current();
    //     _tokenIdCounter.increment();
    //     _existingCollection.safeTransferFrom(
    //         msg.sender,
    //         address(this),
    //         tokenId
    //     );
    //     _tokenPrice[tokenId] = price;
    //     emit NFTListed(tokenId, price);
    // }

    function _setPrice(
        uint256 tokenId,
        uint256 price,
        address seller
    ) internal {
        if (tokenPrice[tokenId] == 0 && price > 0) {
            count++;
        }
        if (tokenPrice[tokenId] > 0 && price == 0) {
            count--;
        }
        tokenPrice[tokenId] = price;
        _tokenSeller[tokenId] = seller;
    }

    function setPrice(uint256 tokenId, uint256 price) external {
        // require(_tokenPrice[tokenId] > 0, "NFT is not listed for sale");
        require(
            _existingCollection.ownerOf(tokenId) == msg.sender,
            "You are not the owner"
        );
        _setPrice(tokenId, price, msg.sender);
        emit NFTPriceUpdated(tokenId, msg.sender, price);
    }

    function buyNFT(uint256 tokenId) external payable {
        require(tokenPrice[tokenId] > 0, "NFT is not listed for sale");
        require(
            _existingCollection.ownerOf(tokenId) == _tokenSeller[tokenId],
            "NFT ownership changed"
        );
        require(
            _existingCollection.getApproved(tokenId) == address(this) ||
                _existingCollection.isApprovedForAll(
                    _existingCollection.ownerOf(tokenId),
                    address(this)
                ),
            "NFT not approved for sale"
        );
        require(msg.value >= tokenPrice[tokenId], "Insufficient payment");

        address seller = _existingCollection.ownerOf(tokenId);
        _existingCollection.safeTransferFrom(seller, msg.sender, tokenId);
        uint256 price = tokenPrice[tokenId];
        _setPrice(tokenId, 0, address(0));
        payable(seller).transfer(price);
        emit NFTSold(tokenId, seller, msg.sender, price);
    }

    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        return tokenPrice[tokenId];
    }

    function getExistingCollection() external view returns (address) {
        return address(_existingCollection);
    }

    function getTokensOnSale() external view returns (bytes memory) {
        uint256[] memory tokenIds = new uint256[](count);
        uint256[] memory prices = new uint256[](count);
        uint256 supply = _existingCollection.totalSupply();
        uint256 pos = 0;
        for (uint256 i = 0; i < supply; i++) {
            if (tokenPrice[i] > 0) {
                tokenIds[pos] = i;
                prices[pos] = tokenPrice[i];
                pos++;
            }
        }
        // Encode the tokenIds and prices into a JSON format
        bytes memory jsonData = abi.encode(tokenIds, prices);
        return jsonData;
    }
}
