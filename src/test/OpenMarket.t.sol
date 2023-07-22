// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

import "ds-test/test.sol";

import "../OpenMarket.sol";

import "./Azuki.t.sol";
import "./User.t.sol";

contract OpenMarketTest is DSTest {
    Azuki coll;

    function setUp() public {
        coll = new Azuki();
        emit log_named_address("sender", msg.sender);
    }

    function testCreateEmptyMarket() public {
        OpenMarket con = new OpenMarket(address(coll));
        User user1 = new User(con, coll);
        emit log_named_address("user1", address(user1));
        assertEq(con.count(), 0);
        assertEq(string(con.getTokensOnSale()), "[]");
    }

    function testUserList() public {
        OpenMarket con = new OpenMarket(address(coll));
        User user1 = new User(con, coll);
        emit log_named_address("user1", address(user1));
        user1.mint();
        user1.mint();
        user1.approveAll();
        // @todo test fails without approval
        user1.sell(0, 1000);
        user1.sell(1, 3000);
        assertEq(con.count(), 2);
        assertEq(string(con.getTokensOnSale()), "[0:1000,1:3000]");
    }
}

contract OpenMarketGasTestSell is DSTest {
    Azuki coll;
    User def;
    User buyer;

    function setUp() public {
        coll = new Azuki();
        OpenMarket main = new OpenMarket(address(coll));
        def = new User(main, coll);
        buyer = new User(main, coll);
        def.mint();
        def.approveAll();
        emit log_named_address("sender", msg.sender);
    }

    function testSell() public {
        def.sell(0, 1000);
    }
}

contract OpenMarketGasTestBuy is DSTest {
    Azuki coll;
    User def;
    User buyer;

    function setUp() public {
        coll = new Azuki();
        OpenMarket main = new OpenMarket(address(coll));
        def = new User(main, coll);
        buyer = new User(main, coll);
        def.mint();
        def.approveAll();
        def.sell(0, 1000);
    }

    function testBuy() public {
        buyer.buy{value: 1000}(0);
    }
}
