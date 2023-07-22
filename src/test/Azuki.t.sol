// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

import "@erc721a/contracts/ERC721A.sol";

// Sample NFT collection.
contract Azuki is ERC721A {
    constructor() ERC721A("Azuki", "AZUKI") {}

    // Contract can receive value (for gas tests...).
    receive() external payable {
        // Code to handle the received Ether (optional)
        // For example, you can log events or update contract state.
    }

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }

    function approveAll(address _spender) external {
        setApprovalForAll(_spender, true);
    }
}
