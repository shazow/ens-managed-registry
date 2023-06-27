// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ExtendedResolver} from "ens-contracts/resolvers/profiles/ExtendedResolver.sol";

import {IRegistrar} from "./interfaces/IRegistrar.sol";
import {IResolver, INameResolver} from "./interfaces/IResolver.sol";

// References:
// - https://github.com/ensdomains/resolvers/blob/master/contracts/profiles/AddrResolver.sol
// - https://eips.ethereum.org/EIPS/eip-137#appendix-b-sample-resolver-implementations
// - https://github.com/ensdomains/subdomain-registrar/blob/1ffde8a296a071358fd2811e51a9df2ffcd72616/contracts/SubdomainRegistrar.sol

/// @notice Resolver is a basic resolver wrapper around a ManagedRegistrar which
/// maintains the stored state of subdomain node-to-address mappings.
abstract contract Resolver is IResolver, INameResolver, ExtendedResolver {
    // FIXME: Do we want this resolver to support other functions for the parent node?

    /// @notice IRegistrar manages the subdomain assignment mappings.
    IRegistrar public registrar;

    /// @notice INameResolver manages reverseNode -> name lookups, it can be
    /// the same contract as the registrar, or it can be a procedural resolver in
    /// the future.
    INameResolver public nameResolver;

    constructor(IRegistrar _registrar, INameResolver _nameResolver)
    {
        registrar = _registrar;
        nameResolver = _nameResolver;
    }

    /************************/
    /*** public functions ***/

    function supportsInterface(bytes4 interfaceID) public view virtual returns (bool) {
        return interfaceID == 0x3b3b57de || // addr(bytes32 node) returns (address)
               interfaceID == 0x691f3431 || // name(bytes32 node) returns (string memory);
               interfaceID == 0x9061b923 || // resolve(bytes calldata name, bytes calldata data) returns(bytes);
               interfaceID == 0x0178b8bf || // resolver(bytes32 node) returns (address)
               interfaceID == 0x01ffc9a7;   // supportsInterface
    }

    function addr(bytes32 nodeID) external view virtual returns (address payable) {
        return registrar.addr(nodeID);
    }

    function name(bytes32 node) external view virtual returns (string memory) {
        return nameResolver.name(node);
    }

    function resolver(bytes32) external view virtual returns (address) {
        // This resolver handles all subnodes.
        return address(this);
    }

    // Per Resolver specification: https://eips.ethereum.org/EIPS/eip-137#resolver-specification
    // "Resolvers MUST specify a fallback function that throws."
    fallback() external {
        revert();
    }
}
