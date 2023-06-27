// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

interface ENS {
    function resolver(bytes32 node) external view returns (address);
    function owner(bytes32 node) external view returns (address);

    function setResolver(bytes32 node, address resolver) external;
}

// FIXME: This isn't working with impersonate. Use the cast-based script instead for now.

// Override replaces the ENS resolver in a forked environment, for testing.
// We use --unlocked --sender "0x4863A39d26F8b2e40d2AAbFf1eEe55E4B5015C4f"
contract Override is Script {
    function run() public {
        address resolverAddress = vm.envAddress("RESOLVER_ADDRESS");

        ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

        bytes32 exampleNode = 0x3d5d2e21162745e4df4f56471fd7f651f441adaaca25deb70e4738c6f63d1224;
        address currentOwner = ens.owner(exampleNode);

        vm.startBroadcast(currentOwner);

        // Replace the resolver
        ens.setResolver(exampleNode, resolverAddress);

        console.log("New resolver: %s", ens.resolver(exampleNode));

        vm.stopBroadcast();

        // $ cast call --rpc-url "http://127.0.0.1:8545" 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e "resolver(bytes32) returns (address)" "0x3d5d2e21162745e4df4f56471fd7f651f441adaaca25deb70e4738c6f63d1224"
    }
}
