// SPDX-License-Identifier: GPL
pragma solidity 0.8.19;

library GetOwner {
    function getOwner(
        address nftCollectionAddress
    ) public view returns (address) {
        (bool success, bytes memory result) = nftCollectionAddress.staticcall(
            abi.encodeWithSignature("owner()")
        );
        if (success) {
            // Use call to get the return value if the function exists
            address owner = abi.decode(result, (address));
            return owner;
        } else {
            // Function does not exist
            revert("Owner unknown");
        }
    }
}
