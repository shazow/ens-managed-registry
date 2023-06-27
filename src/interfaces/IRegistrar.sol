// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IRegistrar {
    /// @notice Removals are emitted with a set to 0
    /// @dev Event signature and behavior per EIP-137
    event AddrChanged(bytes32 indexed node, address a);

    function set(bytes32, address) external;
    function multiset(bytes32[] calldata, address[] calldata) external;

    function addr(bytes32 node) external view returns (address payable);
}
