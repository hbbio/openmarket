// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

import "@erc721a/contracts/ERC721A.sol";

import "./Azuki.t.sol";
import "../OpenMarket.sol";

contract User is ERC721A__IERC721Receiver {
    OpenMarket market;
    Azuki public coll;

    constructor(OpenMarket _market, Azuki _coll) payable {
        market = _market;
        coll = _coll;
    }

    // Contract can receive value.
    receive() external payable {
        // Code to handle the received Ether (optional)
        // For example, you can log events or update contract state.
    }

    function mint() public payable {
        coll.mint(1);
    }

    function sell(uint256 _id, uint256 _price) public {
        market.setPrice(_id, _price);
    }

    function buy(uint256 _id) public payable {
        market.buyNFT{value: msg.value}(_id);
    }

    function approveAll() public {
        coll.approveAll(address(market));
    }

    event ReceivedERC721(
        address indexed operator,
        address indexed from,
        uint256 tokenId
    );

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        // Handle the received ERC721 token here (optional)
        emit ReceivedERC721(operator, from, tokenId);

        // Return the ERC721_RECEIVED selector to indicate the contract supports ERC721 token transfers
        return this.onERC721Received.selector;
    }
}
