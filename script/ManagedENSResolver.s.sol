// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {ManagedENSResolver} from "../src/extended/ManagedENSResolver.sol";
import {ManagedRegistrarWithReverse} from "../src/extended/ManagedRegistrarWithReverse.sol";

import {Helpers} from "../test/Helpers.sol";

contract Deploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("ETH_PRIVATE_KEY");
        address ownerAddress = vm.envAddress("ETH_OWNER_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        ManagedRegistrarWithReverse registrar = new ManagedRegistrarWithReverse();
        new ManagedENSResolver(
            registrar, // IRegistrar
            registrar, // INameResolver
            Helpers.namehash("example", "eth") // parentNode
        );

        bytes32 ownerNode = Helpers.namehash("owner", "example", "eth");
        registrar.set(ownerNode, ownerAddress);

        if (ownerAddress != address(0)) {
            console.log("Changing registrar owner: %s -> %s", registrar.owner(), ownerAddress);
            registrar.transferOwnership(ownerAddress);
        }

        vm.stopBroadcast();
    }
}
