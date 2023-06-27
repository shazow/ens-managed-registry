// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IRegistrar} from "../interfaces/IRegistrar.sol";
import {INameResolver, IFullResolver} from "../interfaces/IResolver.sol";

import {Resolver} from "../Resolver.sol";


/// @notice ChildResolver a Resolver wrapper that proxies additional interfaces
/// from a parent resolver, to inherit attributes that have already been set.
/// @dev Parent takes precedence.
abstract contract ChildResolver is Resolver, IFullResolver {
    IFullResolver public immutable parentResolver;

    constructor(IFullResolver _parentResolver, IRegistrar _registrar, INameResolver _nameResolver)
        Resolver(_registrar, _nameResolver)
    {
        parentResolver = _parentResolver;
    }

    // Borrowed from https://github.com/ensdomains/ens-contracts/blob/883a0a2d64d07df54f3ebbb0e81cf2e9d012c14d/contracts/resolvers/profiles/AddrResolver.sol#L82
    // (MIT)
    function addressToBytes(address a) internal pure returns (bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }

    /************************/
    /*** public functions ***/

    // Overrides

    function addr(bytes32 nodeID) public view override(Resolver, IFullResolver) returns (address payable) {
        address payable r = parentResolver.addr(nodeID);
        if (r != address(0)) {
            return r;
        }
        return registrar.addr(nodeID);
    }

    function addr(bytes32 nodeID, uint256 coinType) external view override(IFullResolver) returns (bytes memory) {
        if (coinType == 60) {
            return addressToBytes(addr(nodeID));
        }
        return parentResolver.addr(nodeID, coinType);
    }

    function name(bytes32 reverseNodeID) external view override(Resolver, IFullResolver) returns (string memory) {
        string memory r = nameResolver.name(reverseNodeID);
        if (bytes(r).length > 0) {
            return r;
        }
        return parentResolver.name(reverseNodeID);
    }

    function supportsInterface(bytes4 interfaceID) public view override(IFullResolver, Resolver) returns (bool) {
        return parentResolver.supportsInterface(interfaceID) || super.supportsInterface(interfaceID);
    }

    // TODO: Override?
    // function resolve(bytes memory name, bytes memory data, bytes memory context) external view returns (bytes memory) { return parentResolver.resolve(name, data, context); }

    // IFullResolver Proxies
    // TODO: We may be able to do this in a more generic proxy router, but not sure how overrides would interract. Could research.

    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory) { return parentResolver.ABI(node, contentTypes); }
    function contenthash(bytes32 node) external view returns (bytes memory) { return parentResolver.contenthash(node); }
    function dnsRecord(bytes32 node, bytes32 _name, uint16 resource) external view returns (bytes memory) { return parentResolver.dnsRecord(node, _name, resource); }
    function zonehash(bytes32 node) external view returns (bytes memory) { return parentResolver.zonehash(node); }
    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address) { return parentResolver.interfaceImplementer(node, interfaceID); }
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y) { return parentResolver.pubkey(node); }
    function text(bytes32 node, string calldata key) external view returns (string memory) { return parentResolver.text(node, key); }
}
