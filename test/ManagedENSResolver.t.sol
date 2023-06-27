// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ManagedENSResolver} from "../src/extended/ManagedENSResolver.sol";
import {ManagedRegistrarWithReverse} from "../src/extended/ManagedRegistrarWithReverse.sol";

import {Helpers} from "./Helpers.sol";

contract ManagedENSResolverTest is Test {
    ManagedENSResolver public resolver;
    ManagedRegistrarWithReverse public registrar;

    function setUp() public {
        registrar = new ManagedRegistrarWithReverse();
        resolver = new ManagedENSResolver(
            registrar,
            registrar,
            Helpers.namehash("example", "eth"));
    }

    function testResolve() public {
        bytes32 name = Helpers.namehash("batman", "example", "eth");
        address addr = address(0x42);

        registrar.set(name, addr);

        address got = resolver.addr(name);
        assertEq(got, addr);
    }
}
