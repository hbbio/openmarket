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

contract User {
    OpenMarket market;
    Azuki public coll;

    constructor(OpenMarket _market, Azuki _coll) {
        market = _market;
        coll = _coll;
    }

    function mint() public payable {
        coll.mint(1);
    }

    function sell(uint256 _id, uint256 _price) public {
        market.setPrice(_id, _price);
    }
}

contract OpenMarketTest is DSTest {
    Azuki coll;

    User user1;

    function setUp() public {
        coll = new Azuki();
        emit log_named_address("sender", msg.sender);
    }

    function testCreateEmptyMarket() public {
        OpenMarket con = new OpenMarket(address(coll));
        user1 = new User(con, coll);
        emit log_named_address("user1", address(user1));
        assertEq(con.count(), 0);
        assertEq(string(con.getTokensOnSale()), "[]");
    }

    function testUserList() public {
        OpenMarket con = new OpenMarket(address(coll));
        user1 = new User(con, coll);
        emit log_named_address("user1", address(user1));
        user1.mint();
        user1.mint();
        user1.sell(0, 1000);
        user1.sell(1, 3000);
        assertEq(con.count(), 2);
        assertEq(string(con.getTokensOnSale()), "[0:1000,1:3000]");
    }
}
