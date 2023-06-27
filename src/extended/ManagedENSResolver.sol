// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

import {INameResolver} from "../interfaces/IResolver.sol";
import {IRegistrar} from "../interfaces/IRegistrar.sol";
import {Resolver} from "../Resolver.sol";

interface IENS {
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;
}

/// @notice ManagedENSResolver is a Resolver that has a register(...) helper
/// for setting subnode records on the root ENS instance. It's useful for cases
/// where wildcard resolving is unsupported.
contract ManagedENSResolver is Resolver, Ownable {
    /// @notice parentNode is the namehash of the node that this is the resolver for.
    /// @dev Used for doing setSubnodeRecord during set.
    bytes32 public parentNode;

    IENS constant internal ens = IENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    uint64 constant internal ttl = 0;

    constructor(IRegistrar _registrar, INameResolver _nameResolver, bytes32 _parentNode)
        Resolver(_registrar, _nameResolver)
    {
        parentNode = _parentNode;
    }

    /***********************/
    /*** admin functions ***/

    /// @notice Wrapper around registrar.set(...) but also does setSubnodeRecord.
    /// @param _subnode keccak256 hash of the subdomain label, *not* the namehash of the full domain
    /// @param _addr Ethereum address to map subdomain to.
    function register(bytes32 _subnode, address _addr) public onlyOwner {
        bytes32 node = keccak256(abi.encodePacked(parentNode, _subnode));
        registrar.set(node, _addr);

        ens.setSubnodeRecord(parentNode, _subnode, address(this), address(this), ttl);
    }
}
