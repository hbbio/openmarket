// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// is Ownable?
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
        recipient = existingCollection;
    }

    // MODIFIERS

    modifier approved(uint256 _id) {
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

    modifier isOwner(uint256 _id, address _addr) {
        require(_existingCollection.ownerOf(_id) == _addr, "Not the owner");
        _;
    }

    // FUNCTIONS

    // @todo use ChainLink Functions
    function _setFees() public {}

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

    function setPrice(
        uint256 tokenId,
        uint256 price
    ) external approved(tokenId) isOwner(tokenId, msg.sender) {
        _setPrice(tokenId, price, msg.sender);
        emit NFTPriceUpdated(tokenId, msg.sender, price);
    }

    function buyNFT(
        uint256 tokenId
    )
        external
        payable
        approved(tokenId)
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

    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        return tokenPrice[tokenId];
    }

    function getExistingCollection() external view returns (address) {
        return address(_existingCollection);
    }

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
