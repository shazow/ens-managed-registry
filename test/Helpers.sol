// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Helpers {

    // Basic helper for generating a single-level namehash (does not recurse)
    function namehash(bytes memory _tld) internal pure returns (bytes32) {
        bytes32 base = bytes32(0x0);
        bytes32 node = keccak256(_tld);
        return keccak256(abi.encodePacked(base, node));
    }

    function namehash(bytes memory _domain, bytes memory _tld) internal pure returns (bytes32) {
        bytes32 base = namehash(_tld);
        bytes32 node = keccak256(_domain);
        return keccak256(abi.encodePacked(base, node));
    }

    function namehash(bytes memory _subdomain, bytes memory _domain, bytes memory _tld) internal pure returns (bytes32) {
        bytes32 base = namehash(_domain, _tld);
        bytes32 node = keccak256(_subdomain);
        return keccak256(abi.encodePacked(base, node));
    }
}
