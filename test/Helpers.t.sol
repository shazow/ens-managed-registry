// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {Helpers} from "./Helpers.sol";

contract HelpersTest is Test {
    function test_Namehash() public {
        // Just making sure it works correctly
        {
            // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-137.md#namehash-algorithm
            bytes32 got = Helpers.namehash("eth");
            bytes32 want = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
            assertEq(got, want);
        }

        {
            bytes32 got = Helpers.namehash("example", "eth");
            bytes32 want = 0x3d5d2e21162745e4df4f56471fd7f651f441adaaca25deb70e4738c6f63d1224;
            assertEq(got, want);
            // Can confirm in terminal:
            // $ cast namehash example.eth
            // 0x3d5d2e21162745e4df4f56471fd7f651f441adaaca25deb70e4738c6f63d1224
            // $ cast call --flashbots 0x4976fb03C32e5B8cfe2b6cCB31c09Ba78EBaBa41 "addr(bytes32) returns (address)" "0x3d5d2e21162745e4df4f56471fd7f651f441adaaca25deb70e4738c6f63d1224"
            // 0x51ABa267A6e8e1E76B44183a73E881D73A102F26
        }

        {
            // $ cast namehash batman.example.eth
            bytes32 got = Helpers.namehash("batman", "example", "eth");
            bytes32 want = 0x442674c8302a725b9d1969ae2a0e5c2364b684e84ad3ee8682b7ac82cd0c58e2;
            assertEq(got, want);
        }
    }
}
