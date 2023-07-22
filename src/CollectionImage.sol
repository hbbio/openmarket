// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@erc721a/contracts/ERC721A.sol";

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Sample NFT collection for tests.
 * @dev A collection copy-mint for dev tests, that generates the tokenURI
 * onchain, but is using an external (IPFS or HTTPS) URL for images.
 *
 * We should add a description field in the constructor.
 */
contract CollectionImageCopy is ERC721A, Ownable {
    using Strings for uint256;

    bool public saleIsActive = true;
    string private imageUrl;

    uint256 public immutable MAX_SUPPLY;
    /// @custom:precision 18
    uint256 public currentPrice;
    uint256 public walletLimit;

    /**
     * @param _name NFT Name
     * @param _symbol NFT Symbol
     * @param _imageUrl Root image URL
     * @param price Initial Price | precision:18
     * @param maxSupply Maximum # of NFTs
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _imageUrl,
        uint256 price,
        uint256 maxSupply,
        uint256 premint
    ) payable Ownable(msg.sender) ERC721A(_name, _symbol) {
        require(premint <= maxSupply);
        imageUrl = _imageUrl;
        currentPrice = price;
        MAX_SUPPLY = maxSupply;
        _safeMint(msg.sender, premint);
    }

    /**
     * @dev An external method for users to purchase and mint NFTs. Requires that the sale
     * is active, that the minted NFTs will not exceed the `MAX_SUPPLY`, and that a
     * sufficient payable value is sent.
     * @param amount The number of NFTs to mint.
     */
    function mint(uint256 amount) external payable {
        uint256 ts = totalSupply();

        require(saleIsActive, "Sale must be active to mint tokens");
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(
            currentPrice * amount == msg.value,
            "Value sent is not correct"
        );

        _safeMint(msg.sender, amount);
    }

    /**
     * @dev A way for the owner to reserve a specifc number of NFTs without having to
     * interact with the sale.
     * @param to The address to send reserved NFTs to.
     * @param amount The number of NFTs to reserve.
     */
    function reserve(address to, uint256 amount) external onlyOwner {
        uint256 ts = totalSupply();
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens");
        _safeMint(to, amount);
    }

    /**
     * @dev A way for the owner to withdraw all proceeds from the sale.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /**
     * @dev Sets whether or not the NFT sale is active.
     * @param isActive Whether or not the sale will be active.
     */
    function setSaleIsActive(bool isActive) external onlyOwner {
        saleIsActive = isActive;
    }

    /**
     * @dev Sets the price of each NFT during the initial sale.
     * @param price The price of each NFT during the initial sale | precision:18
     */
    function setCurrentPrice(uint256 price) external onlyOwner {
        currentPrice = price;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory json = string(
            abi.encodePacked(
                '{"name":"',
                name(),
                " #",
                tokenId.toString(),
                '",',
                '"description":"My awesome NFT collection!",',
                '"image":"',
                imageUrl,
                "/",
                tokenId.toString(),
                '",',
                '"attributes":[{"trait_type":"Collection","value":"',
                name(),
                '"},',
                '{"trait_type":"Token ID","value":"',
                tokenId.toString(),
                '"}]}'
            )
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(json))
                )
            );
    }
}
