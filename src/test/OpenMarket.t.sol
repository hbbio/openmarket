// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

import "ds-test/test.sol";

import "@erc721a/contracts/ERC721A.sol";

import "../OpenMarket.sol";

// Sample NFT collection.
contract Azuki is ERC721A {
    constructor() ERC721A("Azuki", "AZUKI") {}

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }
}

contract OpenMarketTest is DSTest {
    Azuki coll;

    // address user1;

    function setUp() public {
        coll = new Azuki();
        // user1 = address(new User(con));

        emit log_named_address("sender", msg.sender);
        // emit log_named_address("user1", user1);
    }

    function testCreateMarket() public {
        OpenMarket con = new OpenMarket(address(coll));
        assertEq(con.count(), 0);
        assertEq(string(con.getTokensOnSale()), "[]");
    }
}
