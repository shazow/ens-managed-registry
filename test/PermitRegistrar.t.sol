// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {PermitRegistrarWithReverse } from "../src/extended/PermitRegistrarWithReverse.sol";
import {Unauthorized, InvalidSignature, PermitExpired} from "../src/Errors.sol";

import {Helpers} from "./Helpers.sol";

contract PermitRegistrarTest is Test {
    PermitRegistrarWithReverse public registrar;

    uint256 internal signerKey = 12345;
    address internal signer;

    function setUp() public {
        signer = vm.addr(signerKey);

        registrar = new PermitRegistrarWithReverse(
            Helpers.namehash("example", "eth") // parentNode
        );
        registrar.setAdminSigner(signer);
    }

    function test_RegisterWithPermit() public {
        bytes32 node = Helpers.namehash("foo", "example", "eth");

        string memory name = "foo";
        address caller = address(0x42);
        uint256 deadline = block.timestamp + 1;

        bytes32 digest = registrar.digestRegister(name, caller, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, digest);

        assertEq(registrar.addr(node), address(0));
        assertEq(registrar.name(node), "");

        vm.prank(caller);
        registrar.permitRegister(name, caller, deadline, v, r, s);

        assertEq(registrar.addr(node), caller);
        assertEq(registrar.name(node), name);
    }

    function test_RevertIf_PermitExpired() public {
        string memory name = "foo";
        address caller = address(0x42);
        uint256 deadline = block.timestamp + 1;

        bytes32 digest = registrar.digestRegister(name, caller, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, digest);

        vm.warp(deadline + 42);

        vm.prank(caller);
        vm.expectRevert(PermitExpired.selector);
        registrar.permitRegister(name, caller, deadline, v, r, s);
    }

    function test_RevertIf_Unauthorized() public {
        uint256 wrongSignerKey = 42;

        string memory name = "foo";
        address caller = address(0x42);
        uint256 deadline = block.timestamp + 1;

        bytes32 digest = registrar.digestRegister(name, caller, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongSignerKey, digest);

        vm.prank(caller);
        vm.expectRevert(Unauthorized.selector);
        registrar.permitRegister(name, caller, deadline, v, r, s);
    }

    function test_RevertIf_Unauthorized_Args() public {
        string memory name = "foo";
        address caller = address(0x42);
        uint256 deadline = block.timestamp + 1;

        bytes32 digest = registrar.digestRegister(name, caller, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, digest);

        // Invalid name
        vm.expectRevert(Unauthorized.selector);
        registrar.permitRegister("bar", caller, deadline, v, r, s);

        // Invalid caller
        vm.expectRevert(Unauthorized.selector);
        registrar.permitRegister(name, address(0x69), deadline, v, r, s);

        // Invalid deadline
        vm.expectRevert(Unauthorized.selector);
        registrar.permitRegister(name, caller, deadline + 1, v, r, s);

        // Confirm again everything works when it is valid
        registrar.permitRegister(name, caller, deadline, v, r, s);
    }


    function test_RevertIf_InvalidSignature() public {
        string memory name = "foo";
        address caller = address(0x42);
        uint256 deadline = block.timestamp + 1;

        bytes32 digest = registrar.digestRegister(name, caller, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, digest);

        // Invalid signature component
        r = bytes32(0);
        vm.expectRevert(InvalidSignature.selector);
        registrar.permitRegister(name, caller, deadline, v, r, s);
    }
}
