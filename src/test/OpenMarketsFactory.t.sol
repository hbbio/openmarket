// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

import "ds-test/test.sol";

import "@erc721a/contracts/ERC721A.sol";

import "./Azuki.t.sol";
import "./User.t.sol";
import "../OpenMarket.sol";
import "../OpenMarketsFactory.sol";

contract OpenMarketsFactoryTest is DSTest {
    Azuki coll;
    OpenMarketsFactory fact;

    function setUp() public {
        fact = new OpenMarketsFactory();
        coll = new Azuki();
        emit log_named_address("sender", msg.sender);
    }

    function testCreateMarket() public {
        fact.createMarketplace(address(coll));
        address[] memory list = fact.getAllMarketplaces();
        assertEq(list.length, 1);
        assertEq(list[0], fact.getMarketplace(address(coll)));
    }
}
