// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ManagedRegistrar} from "../src/ManagedRegistrar.sol";
import {Unauthorized, LengthMismatch} from "../src/Errors.sol";

contract ManagedRegistrarTest is Test {
    ManagedRegistrar public registrar;

    uint256 public NUM; // Number of iterations to do

    function setUp() public {
        registrar = new ManagedRegistrar();

        NUM = vm.envOr("NUM", uint256(5));
    }

    function _genNodesAddrs(uint256 n) internal pure returns (bytes32[] memory nodes, address[] memory addrs) {
        nodes = new bytes32[](n);
        addrs = new address[](n);

        for (uint160 i = 0; i < n; i++) {
            nodes[i] = bytes32(abi.encode(i));
            addrs[i] = address(0x1000 ^ i);
        }

        return (nodes, addrs);
    }

    function test_Admin() public {
        assertEq(registrar.owner(), address(this));

        // No revert
        registrar.set(bytes32(abi.encodePacked("a")), address(0x42));
        registrar.setAdminSetter(address(0xdeadbeef));

        vm.prank(address(0x42));
        vm.expectRevert("Ownable: caller is not the owner"); // Violates Owned
        registrar.setAdminSetter(address(0x42));

        vm.prank(address(0x42));
        vm.expectRevert(Unauthorized.selector); // Violates adminSetter check
        registrar.set(bytes32(abi.encodePacked("b")), address(0x69));

        // No revert
        vm.prank(address(0xdeadbeef));
        registrar.set(bytes32(abi.encodePacked("c")), address(0x1234));

        assertEq(registrar.addr(bytes32(abi.encodePacked("c"))), address(0x1234));
    }

    function test_Set() public {
        (bytes32[] memory nodes, address[] memory addrs) = _genNodesAddrs(NUM);

        for (uint256 i = 0; i < NUM; i++) {
            registrar.set(nodes[i], addrs[i]);
            assertEq(registrar.addr(nodes[i]), addrs[i]);
        }

        // Invalid nodes return 0x0
        assertEq(registrar.addr(bytes32(abi.encodePacked("defg"))), address(0x0));
    }

    function test_Multiset() public {
        require(NUM > 1, "test_Multiset requires at least 2 node-address pairs");

        // Bulk set a bunch of nodes
        (bytes32[] memory nodes, address[] memory addrs) = _genNodesAddrs(NUM);

        // Make sure it's not set yet
        assertEq(registrar.addr(nodes[NUM-1]), address(0));

        registrar.multiset(nodes, addrs);

        assertEq(registrar.addr(nodes[NUM-1]), addrs[NUM-1]);
        assertNotEq(registrar.addr(nodes[0]), registrar.addr(nodes[1]));
    }

    function test_RevertIf_LengthMismatch() public {
        bytes32[] memory nodes = new bytes32[](2);
        nodes[0] = bytes32(abi.encode(1));
        nodes[1] = bytes32(abi.encode(2));

        address[] memory addrs = new address[](3);
        addrs[0] = address(0x1);
        addrs[1] = address(0x2);
        addrs[2] = address(0x3);

        vm.expectRevert(LengthMismatch.selector);
        registrar.multiset(nodes, addrs);
    }
}
