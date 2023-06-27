// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IResolver {
    function addr(bytes32 node) external view returns (address payable);
    function resolver(bytes32 node) external view returns (address);
}

// EIP-181
interface INameResolver {
    event NameChanged(bytes32 indexed node, string name);

    function name(bytes32 node) external view returns (string memory);
}

interface IFullResolver {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);

    // ens-contracts/resolvers/profiles/I*.sol
    function addr(bytes32 node) external view returns (address payable);
    function addr(bytes32 node, uint256 coinType) external view returns (bytes memory);
    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory);
    function contenthash(bytes32 node) external view returns (bytes memory);
    function dnsRecord(bytes32 node, bytes32 name, uint16 resource) external view returns (bytes memory);
    function zonehash(bytes32 node) external view returns (bytes memory);
    function resolve(bytes memory name, bytes memory data, bytes memory context) external view returns (bytes memory);
    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address);
    function name(bytes32 node) external view returns (string memory);
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y);
    function text(bytes32 node, string calldata key) external view returns (string memory);
}
