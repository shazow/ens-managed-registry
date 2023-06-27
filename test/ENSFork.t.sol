// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ManagedENSResolver} from "../src/extended/ManagedENSResolver.sol";
import {ManagedRegistrarWithReverse} from "../src/extended/ManagedRegistrarWithReverse.sol";

import {Helpers} from "./Helpers.sol";

interface ENS {
    function resolver(bytes32 node) external view returns (address);
    function owner(bytes32 node) external view returns (address);

    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
}

// End-to-end forked ENS testing
contract ENSForkTest is Test {
    ManagedENSResolver public resolver;
    ManagedRegistrarWithReverse public registrar;

    function setUp() public {
        string memory rpcUrl = vm.envString("ETH_RPC_URL");
        vm.createSelectFork(rpcUrl);

        registrar = new ManagedRegistrarWithReverse();
        resolver = new ManagedENSResolver(
            registrar,
            registrar,
            Helpers.namehash("example", "eth"));

        registrar.setAdminSetter(address(resolver));
    }

    // TODO: Could also mock ENS altogether using https://github.com/ethereum/EIPs/blob/master/EIPS/eip-137.md#appendix-a-registry-implementation

    function testEndToEnd() public {
        bytes32 exampleNode = Helpers.namehash("example", "eth");

        ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        address currentOwner = ens.owner(exampleNode);

        // Impersonate currentOwner to change the resolver/owner
        vm.startBroadcast(currentOwner);

        // Replace the resolver
        ens.setResolver(exampleNode, address(resolver));
        ens.setOwner(exampleNode, address(resolver));

        vm.stopBroadcast();

        assertEq(ens.owner(exampleNode), address(resolver));

        bytes32 name = Helpers.namehash("batman", "example", "eth");
        bytes32 subdomain = keccak256("batman");
        address addr = address(0x42);

        // We set via the resolver, rather than the registrar.
        resolver.register(subdomain, addr);

        {
            address got = ens.resolver(name);
            assertEq(got, address(resolver));
        }
        {
            address got = resolver.addr(name);
            assertEq(got, addr);
        }
    }
}
