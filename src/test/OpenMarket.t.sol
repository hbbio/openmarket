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

    function approveAll(address _spender) external {
        setApprovalForAll(_spender, true);
    }
}

contract User is ERC721A__IERC721Receiver {
    OpenMarket market;
    Azuki public coll;

    constructor(OpenMarket _market, Azuki _coll) payable {
        market = _market;
        coll = _coll;
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

    function testListAndBuy() public {
        OpenMarket con = new OpenMarket(address(coll));
        User user1 = new User(con, coll);
        User user2 = new User{value: 2000}(con, coll);
        emit log_named_address("user1", address(user1));
        user1.mint();
        user1.approveAll();
        user1.sell(0, 1000);
        assertEq(con.count(), 1);
        assertEq(address(user2).balance, 2000);
        user2.buy{value: 1000}(0);
    }
}
