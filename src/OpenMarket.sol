// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title OpenMarket is a public good onchain NFT marketplace.
 * @author Henri Binsztok
 * @notice This contract would usually be deployed by the OpenMarketsFactory.
 */
contract OpenMarket {
    uint256 public count;
    mapping(uint256 => uint256) public tokenPrice;
    mapping(uint256 => address) private _tokenSeller;
    IERC721Enumerable private _existingCollection;

    // fee and recipient must _both_ be set for fees to be in effect
    uint8 public fee = 0;
    address public recipient;

    // enable .toString()
    using Strings for uint256;

    /**
     * @dev NFTPriceUpdated is emitted when a seller updates the price of a token.
     * If the price is 0, the token is retired from sale.
     * @param tokenId token ID
     * @param seller address of seller
     * @param price new price
     */
    event NFTPriceUpdated(
        uint256 indexed tokenId,
        address seller,
        uint256 price
    );

    /**
     * @dev NFTSold is emitted when a sale happens. We didn't use Transfer
     * as many frontends do not interpret these events properly as they
     * differ in semantics from equivalent ERC20 token transfers.
     * @param tokenId token ID
     * @param seller address of seller
     * @param buyer address of buyer
     * @param price of sale
     */
    event NFTSold(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );

    constructor(address existingCollection) {
        _existingCollection = IERC721Enumerable(existingCollection);
    }

    // MODIFIERS

    /**
     * @dev approved requires the token to be approved for sale.
     * @param _id token ID.
     */
    modifier isApproved(uint256 _id) {
        require(
            _existingCollection.getApproved(_id) == address(this) ||
                _existingCollection.isApprovedForAll(
                    _existingCollection.ownerOf(_id),
                    address(this)
                ),
            "NFT not approved for sale"
        );
        _;
    }

    /**
     * @dev isOwner requires the given address to own the token.
     * @param _id token ID
     * @param _addr owner address
     */
    modifier isOwner(uint256 _id, address _addr) {
        require(_existingCollection.ownerOf(_id) == _addr, "Not the owner");
        _;
    }

    // FUNCTIONS

    /**
     * @dev getOwner retrieves the owner of an ownable collection, or returns
     * the null address otherwise.
     * @param _collection address of the collection
     */
    function getOwner(address _collection) private view returns (address) {
        (bool success, bytes memory result) = _collection.staticcall(
            abi.encodeWithSignature("owner()")
        );
        if (success) {
            address owner = abi.decode(result, (address));
            return owner;
        } else {
            return address(0);
        }
    }

    /**
     * @dev setFees updates the collection fee, and the recipient of these fees.
     * We should use ChainLink functions to make sure that only the deployer of the
     * NFT collection is able to set the fees.
     * @param uint8 fee in percentage points, e.g. 100 is 1% fee. Max fee is 2.56%.
     * @param recipient Address of the fee recipient.
     */
    // function setFees(uint8 fee, address recipient) public {}

    /**
     * @dev _setPrice is an internal function that changes an order price.
     * @param tokenId ID of the token to sell.
     * @param price The price at which a sale can be agreed on.
     * @param seller Address of the seller.
     */
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

    /**
     * @dev _setPrice changes an order price.
     * @param tokenId ID of the token to sell.
     * @param price The price at which a sale can be agreed on.
     */
    function setPrice(
        uint256 tokenId,
        uint256 price
    ) external isApproved(tokenId) isOwner(tokenId, msg.sender) {
        _setPrice(tokenId, price, msg.sender);
        emit NFTPriceUpdated(tokenId, msg.sender, price);
    }

    /**
     * @dev buyNFT buys an NFT.
     * @param tokenId ID of the token to buy.
     */
    function buyNFT(
        uint256 tokenId
    )
        external
        payable
        isApproved(tokenId)
        isOwner(tokenId, _tokenSeller[tokenId])
    {
        require(tokenPrice[tokenId] > 0, "NFT is not listed for sale");
        uint256 price = tokenPrice[tokenId];
        require(msg.value >= price, "Insufficient payment");

        address seller = _tokenSeller[tokenId];
        _existingCollection.safeTransferFrom(seller, msg.sender, tokenId);

        _setPrice(tokenId, 0, address(0));
        if (fee > 0) {
            payable(seller).transfer((price * (256 - fee)) / 256);
            payable(recipient).transfer((price * fee) / 256);
        } else {
            payable(seller).transfer(price);
        }
        emit NFTSold(tokenId, seller, msg.sender, price);
    }

    /**
     * @dev getTokenPrice returns the current token price sale.
     * @param tokenId ID of the token.
     */
    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        return tokenPrice[tokenId];
    }

    /**
     * @dev getCollection returns the address of the collection.
     */
    function getCollection() external view returns (address) {
        return address(_existingCollection);
    }

    /**
     * @dev getTokensOnSale generates a string containing all orders and their price
     * in a single call.
     */
    function getTokensOnSale() external view returns (string memory) {
        uint256 supply = _existingCollection.totalSupply();
        string memory text = "[";
        bool start = true;
        for (uint256 i = 0; i < supply; i++) {
            if (
                tokenPrice[i] > 0 &&
                _tokenSeller[i] == _existingCollection.ownerOf(i)
            ) {
                if (!start) {
                    text = string.concat(text, ",");
                }
                text = string.concat(text, i.toString());
                text = string.concat(text, ":");
                text = string.concat(text, tokenPrice[i].toString());
                start = false;
            }
        }
        return string.concat(text, "]");
    }
}
