// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ManagedRegistrarWithReverse} from "./ManagedRegistrarWithReverse.sol";
import {Unauthorized, PermitExpired, InvalidSignature} from "../Errors.sol";

// TODO: Should this be a wrapper with a ManagedRegistrarWithReverse composited into it?

/// @notice Registrar that works with EIP-2612-style permits
/// https://eips.ethereum.org/EIPS/eip-2612
contract PermitRegistrarWithReverse is ManagedRegistrarWithReverse {
    /// @notice Address of authorized permit signer.
    address public adminSigner;

    /// @notice Namehash of parent ENS node of this registrar.
    bytes32 public immutable parentNode;

    /// @dev keccak256("PermitRegistrarWithReverse") of version used for verifying permit signature.
    bytes32 private constant nameHash = 0x7f02f7f18bbf0266296c6dbd6c9de3c0aeb5ca7f38822c459c5e7ea81764e77f;

    /// @dev keccak256("1") of version used for verifying permit signature.
    bytes32 private constant versionHash = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    /// @dev keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)",
    bytes32 private constant domainTypeHash = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev keccak256("Register(string name,address addr,uint256 deadline)");
    bytes32 public constant PERMIT_REGISTER_TYPEHASH = 0x7e293f4c92597470e19ac449a798010419e7caa79b4187b4268bfcc2b10bd474;


    constructor(bytes32 _parentNode)
        ManagedRegistrarWithReverse()
    {
        adminSigner = msg.sender;
        parentNode = _parentNode;
    }

    /************************/
    /*** internal helpers ***/

    /// @dev Helper for setting the address, node, and reverse node lookup at once.
    function _register(string calldata _name, address _addr) internal {
        bytes32 node = keccak256(abi.encodePacked(parentNode, keccak256(abi.encodePacked(_name))));

        _setNode(node, _addr);
        _setName(node, _name);
    }


    /***************************/
    /*** onlyOwner functions ***/

    /// @dev Owner controls the address that is allowed to set values.
    function setAdminSigner(address _adminSigner) external onlyOwner {
        adminSigner = _adminSigner;
    }


    /*********************************/
    /*** public external functions ***/

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return keccak256(
            abi.encode(
                domainTypeHash,
                nameHash,
                versionHash,
                block.chainid,
                address(this)
            ));
    }

    /// @notice Encode a permitted register request for signing by adminSigner.
    /// @dev This is a helper that can be made private or inlined.
    function digestRegister(
        string calldata name,
        address addr,
        uint256 deadline
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(
            '\x19\x01', DOMAIN_SEPARATOR(),
            keccak256(abi.encode(PERMIT_REGISTER_TYPEHASH, name, addr, deadline))
        ));
    }

    /// @notice Register a subdomain to an address, with a permit signature.
    /// @dev We don't have a nonce because each register can only be performed once (can't be replayed)
    /// @param addr Address to map the subdomain to
    /// @param name Subdomain to register
    /// @param deadline Permit expiration
    /// @param v secp256k1 signature component
    /// @param r secp256k1 signature component
    /// @param s secp256k1 signature component
    function permitRegister(
        string calldata name,
        address addr,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (block.timestamp > deadline) {
            revert PermitExpired();
        }

        // TODO: Switch to @openzeppelin-contracts/contracts/utils/cryptography's ECDSA/EIP712?

        // Provided signature should cover this payload
        bytes32 digest = digestRegister(name, addr, deadline);

        // TODO: Add ERC-1271 support? (If we need a smart contract signer)
        address recoveredAddress = ecrecover(digest, v, r, s);

        if (recoveredAddress == address(0)) {
            revert InvalidSignature();
        }
        if (recoveredAddress != adminSigner) {
            // Signer must be adminSigner
            revert Unauthorized();
        }

        _register(name, addr);
    }


}
