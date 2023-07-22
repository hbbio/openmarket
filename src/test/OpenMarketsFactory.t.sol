// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

import "ds-test/test.sol";

import "@erc721a/contracts/ERC721A.sol";

import "../OpenMarket.sol";
import "../OpenMarketsFactory.sol";

import "./Azuki.t.sol";
import "./User.t.sol";

contract OpenMarketsFactoryTest is DSTest {
    Azuki coll;
    OpenMarketsFactory fact;

    function setUp() public {
        fact = new OpenMarketsFactory();
        coll = new Azuki();
        coll.mint(10);
        emit log_named_address("sender", msg.sender);
    }

    function testCreateMarket() public {
        fact.createMarketplace(address(coll));
        address[] memory list = fact.getAllMarketplaces();
        assertEq(list.length, 1);
        assertEq(list[0], fact.getMarketplace(address(coll)));
    }

    function testFailMarketTwice() public {
        fact.createMarketplace(address(coll));
        fact.createMarketplace(address(coll));
    }
}
